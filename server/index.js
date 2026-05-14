const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();
const path = require('path');
const app = express();

const validatePassword = (pwd) => {
  const hasUpper = /[A-Z]/.test(pwd); // Tartalmaz nagybetűt?
  const hasLower = /[a-z]/.test(pwd); // Tartalmaz kisbetüt?
  const hasNumber = /\d/.test(pwd);   // Tartalmaz számot?
  const hasSpecial = /[!@#$%^&*(),.?":{}|<>/]/.test(pwd); // Tartalmaz speciális karaktert?
  const minLength = pwd.length >= 8; // Megvan a minimum 8 karakter?
  const maxLength = pwd.length <=20; // Maximum 20 karakter osszú jelszó.
  return hasUpper && hasLower && hasNumber && hasSpecial && minLength && maxLength;
};

const isValidEmail = (email) => {
  // Alapszintű ellenőrzés: van benne @ és legalább egy pont utána
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  host: "mailhog",
  port: 1025,
  secure: false,
  debug: true,
  logger: true
});

transporter.verify((error, success) => {
  if (error) {
    console.log("MailHog hiba:", error);
  } else {
    console.log("🚀 MailHog készen áll a levelek fogadására!");
  }
});

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');
const crypto = require('crypto');


app.use(cors({
  // Ha production-ben vagyunk, a valódi URL-t használjuk, egyébként a localhostot
  origin: process.env.NODE_ENV === 'production' 
          ? process.env.FRONTEND_URL 
          : ['http://localhost:3000', 'http://localhost:5000'],
  credentials: true
}));
app.use(express.json());
app.use(cookieParser());


async function authMiddleware(req, res, next) {
  const token = req.cookies.token;
  if (!token) return res.status(401).json({ error: "Unauthorized" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const result = await pool.query(
      "SELECT id, role, is_verified FROM users WHERE id = $1",
      [decoded.id]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: "User no longer exists" });
    }

    const user = result.rows[0];
    req.user = user;

    const newToken = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    res.cookie("token", newToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 2 * 60 * 60 * 1000
    });

    next();
  } catch (err) {
    res.clearCookie("token");
    res.status(401).json({ error: "Hibás vagy lejárt munkamente." });
  }
}
function roleMiddleware(allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: "Bejelentkezés szükséges!" });
    }
    const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ 
        error: "Nincs jogosultságod ehhez a művelethez!" 
      });
    }
    next(); 
  };
}
function verifiedMiddleware(req, res, next) {
  if (!req.user) {
    return res.status(401).json({ error: "Bejelentkezés szükséges!" });
  }

  // Ha a user be van lépve, de nem igazolta vissza az emailt
  if (!req.user.is_verified) {
    return res.status(403).json({ 
      error: "Kérlek, erősítsd meg az email címedet a funkció használatához!" 
    });
  }

  next();
}

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});
//------------------------------------------------------------------------------------------------------------------
/*
* Tantárgy tematika
*/
const rateLimit = require('express-rate-limit');

// Speciális limiter a tematika lekéréshez
const tematikaLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, 
  max: 20, 
  message: {
    error: "Túl sok lekérdezés! Kérjük, várj 15 percet, mielőtt újra próbálkozol."
  },
  standardHeaders: true,
  legacyHeaders: false,
});
const axios = require("axios");
const TTR_API_KEY = process.env.TTR_API_KEY;

app.get("/api/ttr/tematika", async (req, res) => {
  const { code } = req.query;
  const cleanCode = code?.trim();
  if (!cleanCode) return res.status(400).json({ error: "Missing code" });

  try {
    const ttrBase = "https://ttr.sze.hu";
    const apiKey = TTR_API_KEY;

    const searchRes = await axios.get(`${ttrBase}/api/getSearchedSubjects`, {
      params: { subjectCode: cleanCode },
      headers: { "api-key": apiKey }
    });

    const subject = searchRes.data.subjects?.[0];
   if (!subject || !subject.pdfs?.length) {
  return res.json({
    notFound: true
  });
}

    const targetSemester = subject.pdfs[0]; 
    const formattedSemester = targetSemester.replace(/\//g, "_");
    const manualUrl = `${ttrBase}/api/tmp/tematika/${formattedSemester}${cleanCode}.pdf`;

    console.log(`🚀 Poking ${cleanCode} for semester ${targetSemester}`);
    
    await axios.post(
      `${ttrBase}/api/downloadPdf`,
      { code: cleanCode, felev: targetSemester }, // Send as Object (Axios converts to JSON)
      {
        headers: {
          "api-key": apiKey,
          "Content-Type": "application/json", // Changed to JSON
          "Accept": "application/json, text/plain, */*",
          "Referer": "https://ttr.sze.hu/",
          "Origin": "https://ttr.sze.hu"
        }
      }
    ).catch(() => {});
/*
    let isReady = false;
for (let i = 0; i < 15; i++) {
  try {
    const check = await axios.head(manualUrl, { timeout: 3000 });
    
    const contentType = check.headers['content-type'];
    const contentLength = parseInt(check.headers['content-length'] || "0");

    if (check.status === 200 && contentType?.includes('pdf') && contentLength > 1000) {
      isReady = true;
      break;
    }
    throw new Error("Még nem kész"); // Ha 200 de nem PDF, menjünk a catch-re
  } catch (e) {
    console.log(`...várakozás a fájlra (Próbálkozás ${i+1})`);
    await new Promise(r => setTimeout(r, 2000)); 
  }
}*/    // 3. THE VERIFIER - The "Wait until it exists" loop

    let isReady = false;
    for (let i = 0; i < 15; i++) {
      try {
        const check = await axios.get(manualUrl, { timeout: 3000 });
        if (check.status === 200) {
          isReady = true;
          break;
        }
      } catch (e) {
        console.log(`...waiting for server to finish writing file (Attempt ${i+1})`);
        await new Promise(r => setTimeout(r, 1500));
      }
    }


    return res.json({
      file: isReady ? `${manualUrl}?t=${Date.now()}` : manualUrl,
      isFallback: !isReady,
      subjectName: subject.F3
    });

  } catch (err) {
    res.status(500).json({ error: "Internal Error" });
  }
});


//------------------------------------------------------------------------------------------------------------------

app.get('/api/me', authMiddleware, async (req, res) => {
  const token = req.cookies.token;
  
  if (!token) return res.json(null);

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const result = await pool.query(
      `SELECT id, first_name, last_name, email, role, is_verified FROM users WHERE id=$1`,
      [decoded.id]
    );

    res.json(result.rows[0] || null);
  } catch (err) {
    res.json(null);
  }
});


app.delete('/api/delete-account', authMiddleware, verifiedMiddleware, async (req, res) => {
  const userId = req.user.id;

  try {
    await pool.query('BEGIN');

    await pool.query(`DELETE FROM colors WHERE user_id=$1`, [userId]);
    await pool.query(`DELETE FROM user_saves WHERE user_id=$1`, [userId]);
    await pool.query(`DELETE FROM tokens WHERE user_id=$1`, [userId]);
    await pool.query(`DELETE FROM users WHERE id=$1`, [userId]);

    await pool.query('COMMIT');

    res.clearCookie("token", { httpOnly: true, sameSite: "strict", secure: process.env.NODE_ENV === "production" });
    res.json({ message: "Account and all associated data deleted successfully" });
  } catch (err) {
    await pool.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: "Failed to delete account" });
  }
});

app.post("/api/register", async (req, res) => {
  const { first_name, last_name, email, password } = req.body;

  if (!first_name || !last_name || !email || !password) {
    return res.status(400).json({ error: "Minden mező kitöltése kötelező!" });
  }
  if (!isValidEmail(email)) {
    return res.status(400).json({ error: "Érvénytelen email formátum!" });
  }
  if (first_name.length > 100 || last_name.length > 100 || email.length > 100) {
    return res.status(400).json({ error: "A név vagy az email túl hosszú." });
  }
  if (!validatePassword(password)) {
    return res.status(400).json({ error: "A jelszó nem felel meg a biztonsági követelményeknek" });
  }

  try {
    const existing = await pool.query("SELECT id FROM users WHERE email=$1", [email]);
    
    if (existing.rows.length) {
      return res.json({ 
        message: "A regisztrációs folyamat elindult. Kérjük, ellenőrizze az e-mail fiókját!", 
        alreadyExists: true 
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const userResult = await pool.query(
      `INSERT INTO users (first_name, last_name, email, password_hash)
       VALUES ($1,$2,$3,$4) RETURNING id`,
      [first_name, last_name, email, hashedPassword]
    );

    const userId = userResult.rows[0].id;
    const token = crypto.randomUUID();

    await pool.query(
      `INSERT INTO tokens (user_id, token, type, expires_at)
       VALUES ($1,$2,'verification', NOW() + INTERVAL '10 minutes')`,
      [userId, token]
    );

    const verificationLink = `${process.env.FRONTEND_URL}/verify/${token}`;

    await transporter.sendMail({
      from: '"Szakdolgozat Rendszer" <noreply@kredithid.hu>',
      to: email,
      subject: "Email hitelesítés",
      html: `<p>Kérlek erősítsd meg az emailed:</p><a href="${verificationLink}">Email megerősítése</a>`
    });

    res.json({ message: "A regisztrációs folyamat elindult. Kérjük, ellenőrizze az e-mail fiókját!" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Regisztráció sikertelen szerverhiba miatt." });
  }
});
app.post("/api/resend-verification", async (req, res) => {
  const { email } = req.body;

  try {
    const user = await pool.query(
      "SELECT id, is_verified FROM users WHERE email=$1",
      [email]
    );

   if (!user.rows.length || user.rows[0].is_verified) {
      return res.json({ message: "Hitelesítő e-mail elküldve." }); 
    }

    const userId = user.rows[0].id;
    await pool.query(
      "DELETE FROM tokens WHERE user_id=$1 AND type='verification'",
      [userId]
    );
    const token = crypto.randomUUID();

    await pool.query(
      `INSERT INTO tokens (user_id, token, type, expires_at)
       VALUES ($1,$2,'verification', NOW() + INTERVAL '10 minutes')`,
      [userId, token]
    );

    const verificationLink = `${process.env.FRONTEND_URL}/verify/${token}`;

    await transporter.sendMail({
      from: '"Szakdolgozat Rendszer" <noreply@kredithid.hu>',
      to: email,
      subject: "Verification email (again)",
      html: `
        <p>Új megerősítő link:</p>
        <a href="${verificationLink}">Email megerősítése</a>
      `
    });

    res.json({ message: "Verification email resent" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to resend email" });
  }
});
/*app.post("/api/verify", async (req, res) => {
  const { email, code } = req.body;

  try {
    const user = await pool.query(
      "SELECT id FROM users WHERE email=$1",
      [email]
    );

    if (!user.rows.length)
      return res.status(400).json({ error: "User not found" });

    const userId = user.rows[0].id;

    const tokenResult = await pool.query(
      `SELECT * FROM tokens 
       WHERE user_id=$1 AND type='verification'
       ORDER BY expires_at DESC
       LIMIT 1`,
      [userId]
    );

    if (!tokenResult.rows.length)
      return res.status(400).json({ error: "No verification code found" });

    const tokenRow = tokenResult.rows[0];

    if (new Date(tokenRow.expires_at) < new Date())
      return res.status(400).json({ error: "Code expired" });

    const valid = await bcrypt.compare(code, tokenRow.token);

    if (!valid)
      return res.status(400).json({ error: "Invalid code" });

    await pool.query(
      "UPDATE users SET is_verified=true WHERE id=$1",
      [userId]
    );

    await pool.query(
      "DELETE FROM tokens WHERE user_id=$1 AND type='verification'",
      [userId]
    );

    res.json({ message: "Account verified successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Verification failed" });
  }
});
*/
app.get('/api/verify/:token', async (req, res) => {
  const { token } = req.params;

  try {
    const result = await pool.query(
      `SELECT * FROM tokens WHERE token=$1 AND type='verification'`,
      [token]
    );

    if (!result.rows.length) {
      return res.status(400).json({ error: "Hibás vagy lejárt munkamenet!" });
    }

    const tokenData = result.rows[0];
    if (new Date(tokenData.expires_at) < new Date()) {
       return res.status(400).json({ error: "Lejárt munkamenet!" });
    }

    const userId = tokenData.user_id;

    await pool.query('BEGIN');
    await pool.query(`UPDATE users SET is_verified=true WHERE id=$1`, [userId]);

    await pool.query(`DELETE FROM tokens WHERE user_id=$1 AND type='verification'`, [userId]);

    const userRes = await pool.query(
      `SELECT id, role, email, first_name, last_name FROM users WHERE id=$1`, 
      [userId]
    );
 
    const user = userRes.rows[0];

    const jwtToken = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    await pool.query('COMMIT');

    res.cookie("token", jwtToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 2 * 60 * 60 * 1000
    });

    res.json({ 
      message: "E-mail hitelesítve.",
      user: {
        id: user.id,
        role: user.role,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        is_verified: true
      }
    });

  } catch (err) {
    await pool.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: "Hitelesítési hiba!" });
  }
});
app.post("/api/login", async (req, res) => {
  const { email, password, guestSessionId } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: "Email és jelszó megadása kötelező!" });
  }
  if (!isValidEmail(email)) {
    return res.status(400).json({ error: "Érvénytelen email formátum!" });
  }

  if (email.length > 100 || password.length > 100) { 
    return res.status(400).json({ error: "Érvénytelen bejelentkezési adatok." });
  }
  try {
    const user = await pool.query(
      "SELECT * FROM users WHERE email=$1",
      [email]
    );

    if (!user.rows.length)
      return res.status(400).json({ error: "Hibás e-mail cím, vagy jelszó!" });

    if (!user.rows[0].is_verified)
      return res.status(400).json({ error: "Kérem, hitelesítse az e-mail címét!" });

    const valid = await bcrypt.compare(
      password,
      user.rows[0].password_hash
    );

    if (!valid)
      return res.status(400).json({ error: "Hibás e-mail cím, vagy jelszó!" });

    const token = jwt.sign(
      { id: user.rows[0].id, role: user.rows[0].role },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    res.cookie("token", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict"
    });

    res.json({ message: "Bejelentkezve." });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Hibás e-mai cím vagy jelszó!" });
  }
});

app.post("/api/request-reset", async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ error: "Email megadása kötelező!" });
  }
  if (!isValidEmail(email)) {
    return res.status(400).json({ error: "Érvénytelen email formátum!" });
  }
  if (email.length > 100) { 
    return res.status(400).json({ error: "Érvénytelen adat." });
  }

  try {
    const user = await pool.query(
      "SELECT id FROM users WHERE email=$1",
      [email]
    );

    if (!user.rows.length) {
      return res.json({ message: "Ha az email cím létezik, a jelszó-visszaállító linket elküldtük." });
    }

    const userId = user.rows[0].id;
    await pool.query(
      "DELETE FROM tokens WHERE user_id=$1 AND type='password_reset'",
      [userId]
    );
    const token = crypto.randomUUID();

    await pool.query(
      `INSERT INTO tokens (user_id, token, type, expires_at)
       VALUES ($1, $2, 'password_reset', NOW() + INTERVAL '1 hour')`,
      [userId, token]
    );

    const resetLink = `${process.env.FRONTEND_URL}/reset/${token}`;

    await transporter.sendMail({
      from: '"Szakdolgozat Rendszer" <noreply@kredithid.hu>',
      to: email,
      subject: "Jelszó visszaállítás",
      html: `<p>Kattints a linkre a jelszó visszaállításához:</p><a href="${resetLink}">Jelszó visszaállítása</a>`
    });

    res.json({ message: "Ha az email cím létezik, a jelszó-visszaállító linket elküldtük." });
    
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Szerverhiba történt" });
  }
});

app.post("/api/reset/:token", async (req, res) => {
  const { token } = req.params;
  const { newPassword } = req.body;

  if (!newPassword || newPassword.length < 8) {
    return res.status(400).json({ error: "A jelszónak legalább 8 karakternek kell lennie." });
  }

  try {
    const tokenResult = await pool.query(
      "SELECT * FROM tokens WHERE token=$1 AND type='password_reset'",
      [token]
    );

    if (!tokenResult.rows.length) {
      return res.status(400).json({ error: "Érvénytelen vagy lejárt munkamenet." });
    }

    const tokenData = tokenResult.rows[0];
    if (new Date(tokenData.expires_at) < new Date()) {
      return res.status(400).json({ error: "Érvénytelen munkamenet." });
    }

    const userId = tokenData.user_id;
    const hashed = await bcrypt.hash(newPassword, 10);

    await pool.query('BEGIN');

    await pool.query("UPDATE users SET password_hash=$1 WHERE id=$2", [hashed, userId]);
    
    await pool.query("DELETE FROM tokens WHERE user_id=$1 AND type='password_reset'", [userId]);

    const userRes = await pool.query(
      "SELECT id, role, email, first_name, last_name FROM users WHERE id=$1", 
      [userId]
    );
    const user = userRes.rows[0];

    const jwtToken = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    await pool.query('COMMIT');

    res.cookie("token", jwtToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 2 * 60 * 60 * 1000 // 2 óra
    });

    res.json({ 
      message: "A jelszó vissazállítás siekres!",
      user: {
        id: user.id,
        role: user.role,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name
      }
    });

  } catch (err) {
    await pool.query('ROLLBACK');
    console.error("Reset password error:", err);
    res.status(500).json({ error: "Szerverhiba a jelszó visszaállítása során." });
  }
});

app.post('/api/change-password', authMiddleware, verifiedMiddleware, async (req, res) => {
  const { old_password, new_password } = req.body;
  if (!old_password || !new_password) {
    return res.status(400).json({ error: "Régi és új jelszó megadása kötelező" });
  }

  if (old_password.length > 100 || new_password.length > 100) {
    return res.status(400).json({ error: "Túl hosszú jelszó." });
  }

  if (!validatePassword(new_password)) {
    return res.status(400).json({ error: "Az új jelszó nem felel meg a biztonsági követelményeknek (8-20 karakter, stb.)" });
  }

  try {
    const result = await pool.query("SELECT password_hash FROM users WHERE id=$1", [req.user.id]);
    if (!result.rows.length) return res.status(404).json({ error: "Felhasználó nem található!" });

    const user = result.rows[0];

    const valid = await bcrypt.compare(old_password, user.password_hash);
    if (!valid) return res.status(400).json({ error: "Helytelen régi jelszó!" });

    const hashed = await bcrypt.hash(new_password, 10);
    await pool.query("UPDATE users SET password_hash=$1 WHERE id=$2", [hashed, req.user.id]);

    res.json({ message: "Jelszó frissítve." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Jelszóváltozatatás nem sikerült!" });
  }
});



app.post('/api/logout', authMiddleware, (req, res) => {
  res.clearCookie("token", {
    httpOnly: true,
    sameSite: "strict",
    secure: process.env.NODE_ENV === "production"
  });

  res.json({ message: "Kijelentkezve!" });
});


//---------------------------------------------------------------------------------------------
// Mentés logika
app.post("/api/save", authMiddleware, verifiedMiddleware, async (req, res) => {
  const { slotNumber, saveName, data, majorId } = req.body;
  const userId = req.user.id;
  // 1. Slot név ellenőrzése
  if (saveName && saveName.length > 50) {
    return res.status(400).json({ error: "A mentés neve túl hosszú (max 50 karakter)!" });
  }

  // 2. A data objektumon belüli hallgatói adatok ellenőrzése
  if (data?.userData) {
    if (data.userData.field1?.length > 200 || 
        data.userData.field2?.length > 200 || 
        data.userData.field3?.length > 200) {
      return res.status(400).json({ error: "A hallgatói adatok hossza meghaladja a limitet!" });
    }
  }

  if (![1, 2, 3, 4].includes(slotNumber)) {
    return res.status(400).json({ error: "Hibás slot szám" });
  }

  if (!data) {
    return res.status(400).json({ error: "Nincs adat" });
  }

  if (!majorId) {
    return res.status(400).json({ error: "Szak id szükséges" });
  }

  try {
    await pool.query(
      `
      INSERT INTO user_saves (user_id, major_id, slot_number, save_name, save_data)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (user_id, major_id, slot_number)
      DO UPDATE SET 
        save_name = EXCLUDED.save_name,
        save_data = EXCLUDED.save_data,
        updated_at = CURRENT_TIMESTAMP
      `,
      [userId, majorId, slotNumber, saveName || `Slot ${slotNumber}`, data]
    );

    res.json({ success: true });
  } catch (err) {
    console.error("SAVE ERROR:", err);
    res.status(500).json({ error: "Mentés sikertelen" });
  }
});
app.get("/api/saves", authMiddleware, verifiedMiddleware, async (req, res) => {
  const userId = req.user.id;
  const { majorId } = req.query;

  if (!majorId) {
    return res.status(400).json({ error: "Szak id szükséges" });
  }

  try {
    const result = await pool.query(
      `
      SELECT id, slot_number, save_name, save_data, updated_at
      FROM user_saves
      WHERE user_id = $1 AND major_id = $2
      ORDER BY slot_number
      `,
      [userId, majorId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("LOAD ERROR:", err);
    res.status(500).json({ error: "Betöltés meghiusúlt!" });
  }
});
app.post("/api/saves/clear", authMiddleware, verifiedMiddleware, async (req, res) => {
  const { slotNumber, majorId } = req.body;
  const userId = req.user.id;

  if (!majorId || !slotNumber) {
    return res.status(400).json({ error: "Szak id és slot szám szükséges" });
  }

  try {
    await pool.query(
      `DELETE FROM user_saves 
       WHERE user_id = $1 AND major_id = $2 AND slot_number = $3`,
      [userId, majorId, slotNumber]
    );

    res.json({ success: true, message: "Slot siekresen tisztítva" });
  } catch (err) {
    console.error("CLEAR ERROR:", err);
    res.status(500).json({ error: "A slot tisztitása nem sikerült" });
  }
});
//------------------------------------------------------------------------------------------------------------------
// Az összes szak lekérdezése
app.get('/api/majors', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM majors ORDER BY major_name ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('Hiba a szakok lekérdezésekor:', err);
    res.status(500).json({ error: 'Nem sikerült lekérdezni a szakok listáját.' });
  }
});

// Egy szak lekérdezése az átadott id paraméterrel
app.get('/api/majors/:id', async (req, res) => {
  const { id } = req.params;

  if (isNaN(parseInt(id))) {
    return res.status(400).json({ error: 'Érvénytelen szak azonosító formátum!' });
  }

  try {
    const result = await pool.query('SELECT * FROM majors WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'A szak nem található!' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Hiba a(z) ${id} ID-jú szaknál:`, err);
    res.status(500).json({ error: 'Szerveroldali hiba történt a szak lekérdezésekor.' });
  }
});

// Egy adott szakhoz tartozó tantrágyak lekérdezése
app.get('/api/majors/:id/subjects', async (req, res) => {
  const { id } = req.params;

  if (isNaN(parseInt(id))) {
    return res.status(400).json({ error: 'Érvénytelen szak azonosító!' });
  }

  try {
    const result = await pool.query(
      `SELECT sm.id, s.name, sm.recommended_semester, sm.subject_code AS code,
              sm.syllabus_year, sm.category, sm.type, s.credit
       FROM subject_major sm
       JOIN subjects s ON sm.subject_code = s.code
       WHERE sm.major_id = $1`,
      [id]
    );
    
    res.json(result.rows);
  } catch (err) {
    console.error('Hiba a tantárgyak betöltésekor:', err);
    res.status(500).json({ error: 'A tantárgy információkat nem sikerült betölteni.' });
  }
});

// A Kredittáblához szükséges adatok lekérdezése
app.get('/api/majors/:id/categories', async (req, res) => {
  const majorId = req.params.id;
  try {
    const result = await pool.query(
      `SELECT type as name, max_credit, accepted_percentage FROM majors WHERE id = $1;`,
      [majorId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Ehhez a szakhoz nem tartoznak kategóriák.' });
    }
    res.json(result.rows);
  } catch (err) {
    console.error('Nem lehet betölteni a kategóriákat:', err);
    res.status(500).json({ error: 'Adatbázis hiba történt' });
  }
});
//------------------------------------------------------------------------------------------------------------------
// Új szak hozzáadása
app.post('/api/majors', authMiddleware, verifiedMiddleware, async (req, res) => {
  const { major_name, syllabus_year, category, type, max_credit, accepted_percentage } = req.body;
  const percentage = accepted_percentage || 70;
  if (!major_name) return res.status(400).json({ error: "Szak név kötelező!" });

  try {
    // Duplikáció ellenőrzése
    const check = await pool.query('SELECT id FROM majors WHERE LOWER(major_name) = LOWER($1)', [major_name.trim()]);
    if (check.rows.length > 0) {
      return res.status(400).json({ error: "Ez a szak már létezik az adatbázisban!" });
    }

    const result = await pool.query(
      `INSERT INTO majors (major_name, syllabus_year, category, type, max_credit, accepted_percentage)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *;`,
      [major_name.trim(), syllabus_year, category, type, max_credit, percentage]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Adatbázis hiba történt.' });
  }
});

// Szerkesztés 
app.put('/api/majors/:id', authMiddleware, verifiedMiddleware, async (req, res) => {
  const { id } = req.params;
  const { major_name, syllabus_year, category, type, max_credit, accepted_percentage } = req.body;
  const percentage = accepted_percentage || 70;

  try {
    const check = await pool.query(
      'SELECT id FROM majors WHERE LOWER(major_name) = LOWER($1) AND id <> $2', 
      [major_name.trim(), id]
    );
    if (check.rows.length > 0) {
      return res.status(400).json({ error: "Ezt a nevet már egy másik szak használja!" });
    }

    const result = await pool.query(
      `UPDATE majors SET major_name=$1, syllabus_year=$2, category=$3, type=$4, max_credit=$5, accepted_percentage=$6 
       WHERE id=$7 RETURNING *`,
      [major_name.trim(), syllabus_year, category, type, max_credit, percentage, id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Szerkesztési hiba történt." });
  }
});
// Szak törlése id alapján
app.delete('/api/majors/:id', authMiddleware, verifiedMiddleware, roleMiddleware('admin'),async (req, res) => {
  
  const majorId = req.params.id;
  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    const codesRes = await client.query(
      'SELECT subject_code FROM subject_major WHERE major_id = $1', 
      [majorId]
    );
    const subjectList = codesRes.rows.map(r => r.subject_code);

    // Kapcsoló tábla és a szak törlése
    await client.query('DELETE FROM subject_major WHERE major_id = $1', [majorId]);
    await client.query('DELETE FROM majors WHERE id = $1', [majorId]);

    // Árva tantárgyak takarítása
    if (subjectList.length > 0) {
      await client.query(`
        DELETE FROM subjects 
        WHERE code = ANY($1) 
        AND code NOT IN (SELECT subject_code FROM subject_major)
      `, [subjectList]);
    }

    await client.query('COMMIT');
    res.json({ message: "Szak és kapcsolódó adatok sikeresen törölve." });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error("Szerver hiba a törlésnél:", err);
    res.status(500).json({ error: "Adatbázis hiba történt a törlés során." });
  } finally {
    client.release();
  }
});
//------------------------------------------------------------------------------------------------------------------
// Színprofilok lekérdezése (Minden szakhoz az adott felhasználóé)
app.get('/api/colors', authMiddleware, verifiedMiddleware, async (req, res) => {
  const { major_id } = req.query;
  const user_id = req.user.id;

  try {
    const result = await pool.query(
      'SELECT * FROM colors WHERE user_id = $1 AND major = $2 ORDER BY is_active DESC, id ASC',
      [user_id, Number(major_id)]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Adatbázis hiba.' });
  }
});

// Profil aktívvá tétele
app.patch('/api/colors/:id/activate', authMiddleware, verifiedMiddleware, async (req, res) => {
  const { id } = req.params;
  const { major_id } = req.body;
  const user_id = req.user.id;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    // Összes többi profil inaktiválása az adott szaknál és usernél
    await client.query(
      'UPDATE colors SET is_active = false WHERE user_id = $1 AND major = $2',
      [user_id, major_id]
    );
    // A konkrét profil aktiválása
    const result = await client.query(
      'UPDATE colors SET is_active = true WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, user_id]
    );

    if (result.rows.length === 0) {
      throw new Error('Profile not found or unauthorized');
    }

    await client.query('COMMIT');
    res.json(result.rows[0]);
  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Szerver hiba az aktiváláskor.' });
  } finally {
    client.release();
  }
});

// Új színprofil létrehozása 
app.post('/api/colors', authMiddleware, verifiedMiddleware, async (req, res) => {
  const { major, color_codes, name } = req.body;
  const user_id = req.user.id;

  if (!name || name.trim().length === 0) return res.status(400).json({ error: 'Név kötelező!' });

  try {
    const checkExisting = await pool.query(
      'SELECT id FROM colors WHERE user_id = $1 AND major = $2',
      [user_id, major]
    );
    const shouldBeActive = checkExisting.rows.length === 0;

    const result = await pool.query(
      `INSERT INTO colors (user_id, major, color_codes, name, is_active)
       VALUES ($1, $2, $3, $4, $5) RETURNING *;`,
      [user_id, major, color_codes, name, shouldBeActive]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Hiba a mentésnél.' });
  }
});

// Színprofil frissítése
app.put('/api/colors/:id', authMiddleware, verifiedMiddleware, async (req, res) => {
  const { id } = req.params;
  const { major, color_codes, name } = req.body;
  const user_id = req.user.id;

  try {
    const result = await pool.query(
      `UPDATE colors
       SET major = $1, color_codes = $2, name = $3
       WHERE id = $4 AND user_id = $5
       RETURNING *;`, 
      [major, color_codes, name, id, user_id]
    );

    if (result.rows.length === 0) {
      return res.status(403).json({ error: 'Nincs jogosultságod vagy nem létezik.' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Frissítés hiba.' });
  }
});

// Színprofil törlése 
app.delete('/api/colors/:id', authMiddleware, verifiedMiddleware, async (req, res) => {
  const { id } = req.params;
  const user_id = req.user.id;
  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    
    const deletedResult = await client.query(
      'DELETE FROM colors WHERE id = $1 AND user_id = $2 RETURNING major, is_active',
      [id, user_id]
    );

    if (deletedResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(403).json({ error: 'Nincs jogosultságod vagy nem létezik.' });
    }

    const { major, is_active } = deletedResult.rows[0];

    if (is_active) {
      await client.query(
        `UPDATE colors SET is_active = true 
         WHERE id = (
           SELECT id FROM colors 
           WHERE user_id = $1 AND major = $2 
           ORDER BY id DESC LIMIT 1
         )`,
        [user_id, major]
      );
    }

    await client.query('COMMIT');
    res.json({ message: 'Profil törölve.' });
  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Törlési hiba.' });
  } finally {
    client.release();
  }
});
//------------------------------------------------------------------------------------------------------------------
const multer = require('multer');
const xlsx = require('xlsx');

const upload = multer({ 
  storage: multer.memoryStorage(),
  fileFilter: (req, file, cb) => {
    if (file.mimetype === "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" || 
        file.mimetype === "application/vnd.ms-excel") {
      cb(null, true);
    } else {
      cb(new Error("Csak .xlsx vagy .xls formátum tölthető fel!"), false);
    }
  }
});

async function upsertSubjectAndMajor(client, {
  code, name, credit, recommended_semester, syllabus_year, category, type, majorId
}) {
  // Karakterhossz validáció
  if (code.length > 20) throw new Error(`A kód túl hosszú (${code}): max 20 karakter!`);
  if (name.length > 100) throw new Error(`A név túl hosszú (${name}): max 100 karakter!`);
  if (type.length > 50) throw new Error(`A csoport neve túl hosszú (${type}): max 50 karakter!`);
  if (credit < 0 || credit > 36) throw new Error(`Érvénytelen kredit: ${credit} (0-36 között kell lennie!)`);


  // Ha a tárgy már létezik, frissítjük a nevét és kreditjét 
  await client.query(
    `INSERT INTO subjects (code, name, credit) 
     VALUES ($1, $2, $3)
     ON CONFLICT (code) DO UPDATE SET name = $2, credit = $3`,
    [code, name, credit]
  );

  // Szak-tárgy kapcsolat
  const resMajor = await client.query(
    'SELECT syllabus_year FROM subject_major WHERE subject_code = $1 AND major_id = $2',
    [code, majorId]
  );

  if (resMajor.rowCount === 0) {
    await client.query(
      `INSERT INTO subject_major 
        (subject_code, major_id, recommended_semester, syllabus_year, category, type) 
        VALUES ($1, $2, $3, $4, $5, $6)`,
      [code, majorId, recommended_semester, syllabus_year, category, type]
    );
  } else {
    const existingYear = resMajor.rows[0].syllabus_year || 0;
    if (syllabus_year >= existingYear) {
      await client.query(
        `UPDATE subject_major SET
          recommended_semester = $1,
          syllabus_year = $2,
          category = $3,
          type = $4
        WHERE subject_code = $5 AND major_id = $6`,
        [recommended_semester, syllabus_year, category, type, code, majorId]
      );
    }
  }
}

app.post(
  '/api/upload-subjects', 
  authMiddleware,
  verifiedMiddleware,
  roleMiddleware(['admin', 'user']),
  upload.single('file'),          
  async (req, res) => {
    const majorId = parseInt(req.body.major_id, 10);
    
    if (!majorId || isNaN(majorId)) {
      return res.status(400).json({ error: 'Szak azonosító megadása kötelező!' });
    }
    if (!req.file) {
      return res.status(400).json({ error: 'Nincs fájl kiválasztva!' });
    }

    const client = await pool.connect();

    try {
      const workbook = xlsx.read(req.file.buffer, { type: 'buffer' });
      const sheetName = workbook.SheetNames[0];
      const sheet = workbook.Sheets[sheetName];
      
      const data = xlsx.utils.sheet_to_json(sheet);

      if (data.length === 0) {
        return res.status(400).json({ error: 'Az Excel fájl üres!' });
      }

      // Struktúra ellenőrzése (kötelező oszlopok megléte)
      const requiredHeaders = ['code', 'name', 'credit', 'recommended_semester', 'syllabus_year', 'category', 'type'];
      const firstRowKeys = Object.keys(data[0]);
      const hasAllHeaders = requiredHeaders.every(h => firstRowKeys.includes(h));

      if (!hasAllHeaders) {
        return res.status(400).json({ 
          error: 'Érvénytelen táblázat szerkezet! Hiányzó oszlopok.',
          details: `Szükséges oszlopok: ${requiredHeaders.join(', ')}`
        });
      }

      await client.query('BEGIN');

      for (const row of data) {
        if (!row.code || row.code.toString().trim() === "") continue;

        await upsertSubjectAndMajor(client, {
          code: row.code.toString().trim(),
          name: row.name ? row.name.toString().trim() : "Névtelen tárgy",
          credit: parseInt(row.credit, 10) || 0,
          recommended_semester: parseInt(row.recommended_semester, 10) || 1,
          syllabus_year: parseInt(row.syllabus_year, 10) || 0,
          category: row.category ? row.category.toString().trim() : "",
          type: row.type ? row.type.toString().trim() : "",
          majorId,
        });
      }

      await client.query('COMMIT');
      res.json({ message: 'A tantárgyak feltöltése és validálása sikeresen megtörtént.' });

    } catch (e) {
      await client.query('ROLLBACK');
      console.error('Feltöltési hiba:', e.message);
      res.status(400).json({ error: e.message || 'Hiba történt a feldolgozás során.' });
    } finally {
      client.release();
    }
  }
);

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
