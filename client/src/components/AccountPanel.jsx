import React, { useState, useEffect, useRef } from 'react';
import { toast } from 'react-toastify';
import './AccountPanel.css';
import { useAuth } from './AuthContext';
import { getPasswordError, isEmailInvalid } from './authUtils';
import PasswordInput from './PasswordInput';
/**
 * Segédfüggvény a jelszó erősségének ellenőrzésére.
 * Sorrendben ellenőriz, és az első hiányosságot adja vissza szövegként.
 */
/*const getPasswordError = (pwd) => {
  if (pwd.length < 8) return "A jelszónak legalább 8 karakter hosszúnak kell lennie.";
  if (!/[A-Z]/.test(pwd)) return "A jelszónak tartalmaznia kell legalább egy nagybetűt.";
  if (!/[a-z]/.test(pwd)) return "A jelszónak tartalmaznia kell legalább egy kisbetűt.";
  if (!/\d/.test(pwd)) return "A jelszónak tartalmaznia kell legalább egy számot.";
  if (!/[!@#$%^&*(),.?":{}|<>/]/.test(pwd)) return "A jelszónak tartalmaznia kell egy speciális karaktert.";
  if (pwd.length > 20) return "A jelszó nem lehet hosszabb 20 karakternél.";
  return null;
};

/**
 * Egyedi jelszó beviteli mező komponens láthatósági kapcsolóval (lakat / szem ikon).
 */
/*function PasswordInput({ name, value, onChange, placeholder }) {
  const [show, setShow] = useState(false);
  return (
    <div className="password-input-wrapper">
      <input
        type={show ? 'text' : 'password'}
        name={name}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        maxLength={20}
      />
      <span className="password-toggle" onClick={() => setShow(!show)}>
        {show ? '👁️' : '🔒'}
      </span>
    </div>
  );
}

/**
 * Kisméretű felugró ablak keretrendszere fejléccel és bezáró gombbal.
 */
function MiniWindow({ title, children, onClose }) {
  return (
    <div className="mini-window">
      <div className="mini-window-header">
        <h3>{title}</h3>
        <button onClick={onClose}>✖</button>
      </div>
      {children}
    </div>
  );
}

export default function AccountPanel() {
  const { user: authUser, setUser, fetchUser, logout, authFetch } = useAuth();
  // API elérési útja a környezeti változókból
  const API_URL = process.env.REACT_APP_API_URL;

  // Állapotkezelés (States)
  const [isVerified, setIsVerified] = useState(true); // Email megerősítettség állapota
  const [loading, setLoading] = useState(false);     // Betöltési állapot (hálózati kérések alatt)
  const [error, setError] = useState(null);           // Hibaüzenetek tárolása
  const [form, setForm] = useState({                  // Az összes űrlap közös állapota
    first_name: '', last_name: '', email: '', password: '',
    old_password: '', new_password1: '', new_password2: ''
  });
  const [activeWindow, setActiveWindow] = useState(null); // Aktuálisan látható ablak
  const [resendCooldown, setResendCooldown] = useState(0); // Újraküldési időzítő (másodperc)
  const didMount = useRef(false);                     // Segédlet az egyszeri betöltéshez

  // Űrlap mezőinek alaphelyzetbe állítása
  const resetForm = () => setForm({
    first_name: '', last_name: '', email: '', password: '',
    old_password: '', new_password1: '', new_password2: ''
  });

  // Ablak megnyitása: hiba törlése és mezők ürítése
 const openWindow = (name) => {
    setError(null);
    if (name !== "verify") {
      resetForm();
    }
    setActiveWindow(name);
  };

  /**
   * Cooldown időzítő kezelése
   */
  useEffect(() => {
    let timer;
    if (resendCooldown > 0) {
      timer = setInterval(() => {
        setResendCooldown((prev) => prev - 1);
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [resendCooldown]);

  // Általános beviteli mező kezelő
  const handleInput = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  /**
   * Bejelentkezési folyamat kezelése.
   */
  const handleLogin = async () => {
  if (!form.email || !form.password) return setError("Adj meg minden mezőt!");
  if (isEmailInvalid(form.email)) {
    return setError("Érvénytelen e-mail cím formátum!");
  }
  setLoading(true);
  setError(null);

  try {
    const res = await fetch(`${API_URL}/api/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify({ email: form.email, password: form.password })
    });

    const data = await res.json();

    if (!res.ok) {
      setError(data.error || "Hiba történt");

      if(data.error ){}
      
      if (data.error?.toLowerCase().includes("hitelesítse")) {
        setIsVerified(false);
        openWindow("verify");
      }
    } else {
      await fetchUser();
      setActiveWindow(null);
      setError(null);
      //onLogin?.(data);
    }
  } catch {
    setError('Hálózati hiba');
  } finally { 
    setLoading(false); 
  }
  
};

  /**
   * Regisztrációs folyamat kezelése.
   */
  const handleRegister = async () => {
  if (!form.first_name || !form.last_name || !form.email || !form.password)
    return setError("Töltsön ki minden mezőt!");

  if (form.first_name.length > 100 || form.last_name.length > 100)
    return setError("A név nem lehet hosszabb 100 karakternél.");
  if (isEmailInvalid(form.email)) {
    return setError("Érvénytelen e-mail cím formátum!");
  }

  const pwdError = getPasswordError(form.password);
  if (pwdError) return setError(pwdError);

  setLoading(true); 
  setError(null);

  try {
    const res = await fetch(`${API_URL}/api/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form)
    });
    
    const data = await res.json();

    if (!res.ok) {
        // Most már csak a valódi hibákat jelezzük (pl. hálózati hiba, szerver hiba)
        setError(data.error || "Hiba történt a regisztráció során.");
      } else {
        // Bármi történik (új regisztráció vagy már létező email), ugyanazt látja a júzer
        setIsVerified(false);
        openWindow("verify");
        setError(null);
        toast.info("A regisztrációs folyamat elindult. Kérjük, ellenőrizze az e-mail fiókját!");
      }
  } catch {
    setError('Hálózati hiba.');
  } finally { 
    setLoading(false); 
  }
};

  /**
   * Megerősítő email újraküldése.
   */
  const handleResend = async () => {
    if (resendCooldown > 0) return;
    setLoading(true); setError(null);
    try {
      const res = await fetch(`${API_URL}/api/resend-verification`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: form.email })
      });
      const data = await res.json();
      if (!res.ok) setError(data.error);
      else setResendCooldown(60); 
    } catch {
      setError('Hálózati hiba');
    } finally { setLoading(false); }
  };

  /**
   * Elfelejtett jelszó visszaállításának kezdeményezése.
   */
  const handleResetPassword = async () => {
    if (!form.email) return setError("Adj meg egy emailt!");
    if (resendCooldown > 0) return;
    if (isEmailInvalid(form.email)) {
    return setError("Érvénytelen e-mail cím formátum!");
  }

    setLoading(true); 
    setError(null);
    try {
      const res = await fetch(`${API_URL}/api/request-reset`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: form.email })
      });
      
      if (res.ok) {
        toast.success("Ha a fiók létezik, az e-mailt elküldtük.");
        setResendCooldown(60); 
      }
    } catch {
      setError('Hálózati hiba');
    } finally { 
      setLoading(false); 
    }
  };

  /**
   * Bejelentkezett felhasználó jelszavának módosítása.
   */
  const handleChangePassword = async () => {
  if (!form.old_password || !form.new_password1 || !form.new_password2)
    return setError("Töltsön ki minden mezőt!");
  
  if (form.new_password1 !== form.new_password2)
    return setError("Az új jelszavak nem egyeznek!");

  const pwdError = getPasswordError(form.new_password1);
  if (pwdError) return setError(pwdError);

    setLoading(true); setError(null);
    try {
      const res = await authFetch(`${API_URL}/api/change-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ old_password: form.old_password, new_password: form.new_password1 })
      });
      const data = await res.json();
      if (!res.ok) {
      if (data.error === "Incorrect old password") {
        setError("Hibás régi jelszó!");
      } else {
        setError(data.error || "Hiba történt.");
      }
    }
      else { toast.success("Jelszó sikeresen megváltoztatva."); 
      setActiveWindow("account"); }
    } catch { setError('Hálózati hiba'); }
    finally { setLoading(false); }
  };

  /**
   * Kijelentkezés és session törlése.
   */
 const handleLogout = async () => {
    await logout();
  };

  /**
   * Felhasználói fiók végleges törlése megerősítéssel.
   */
  const handleDelete = async () => {
    const confirmed = window.confirm(
      'Biztosan törölni szeretnéd a fiókodat? Minden mentett adatod véglegesen elvész!'
    );
    
    if (!confirmed) return;

    try {
      const res = await authFetch(`${API_URL}/api/delete-account`, { 
        method: 'DELETE', 
        credentials: 'include' 
      });

      if (res.ok) {
        toast.success("A fiókod törlésre került.");
        setActiveWindow(null);
        //onLogout?.(); 
        
        window.location.href = "/";
      } else {
        const data = await res.json();
        toast.error(data.error || "Hiba történt a törlés során.");
      }
    } catch (err) {
      toast.error("Hálózati hiba a törlés során.");
    }
  };

  return (
    <div className="account-panel">
      {/* Fő gomb a panel megnyitásához */}
      <button onClick={() => openWindow(authUser ? "account" : "login")}>
        {authUser ? "Fiókom" : "Fiók"}
      </button>

      {/* ADATLAP ABLAK (Ha be van jelentkezve) */}
      {activeWindow === "account" && authUser && (
        <MiniWindow title="Fiók" onClose={() => setActiveWindow(null)}>
          <div className="account-info">
            <div><strong>Név:</strong> {authUser.first_name} {authUser.last_name}</div>
            <div><strong>E-mail:</strong> {authUser.email}</div>
            {!isVerified && (
              <div className="account-warning">
                E-mail nincs megerősítve!<br/>
                <button onClick={() => openWindow("verify")}>Megerősítés</button>
              </div>
            )}
            <button onClick={handleLogout}>Kijelentkezés</button>
            <button onClick={handleDelete} className="delete-button">Fiók törlése</button>
            <button onClick={() => openWindow("changePassword")}>Jelszó módosítása</button>
          </div>
        </MiniWindow>
      )}

      {/* BEJELENTKEZÉS ABLAK */}
      {activeWindow === "login" && (
        <MiniWindow title="Bejelentkezés" onClose={() => setActiveWindow(null)}>
          <form onSubmit={(e) => { e.preventDefault(); handleLogin(); }}>
            <input name="email" placeholder="E-mail" onChange={handleInput} maxLength={100}/>
            <PasswordInput name="password" placeholder="Jelszó" value={form.password} onChange={handleInput}/>
            {error && <div className="error-message">{error}</div>}
            <button type="submit">Bejelentkezés</button>
          </form>
          <p className="clickable-link" onClick={() => openWindow("register")}>
            Még nincs fiókod? Regisztrálj
          </p>
          <p className="clickable-link" onClick={() => openWindow("resetPassword")}>
            Elfelejtett jelszó?
          </p>
        </MiniWindow>
      )}

      {/* REGISZTRÁCIÓ ABLAK */}
      {activeWindow === "register" && (
        <MiniWindow title="Regisztráció" onClose={() => setActiveWindow(null)}>
          <form onSubmit={(e) => { e.preventDefault(); handleRegister(); }}>
            <input name="first_name" placeholder="Keresztnév" onChange={handleInput} maxLength={100} />
            <input name="last_name" placeholder="Vezetéknév" onChange={handleInput} maxLength={100} />
            <input name="email" placeholder="E-mail" onChange={handleInput}maxLength={100}/>
            <PasswordInput name="password" placeholder="Jelszó" value={form.password} onChange={handleInput}/>
            {error && <div className="error-message">{error}</div>}
            <button type="submit">Regisztráció</button>
          </form>
          <p className="clickable-link" onClick={() => openWindow("login")}>
            Már van fiókja? Jelentkezzen be.
          </p>
        </MiniWindow>
      )}

      {/* EMAIL MEGERŐSÍTÉS ABLAK */}
      {activeWindow === "verify" && (
        <MiniWindow title="E-mail megerősítés" onClose={() => setActiveWindow(null)}>
          <div style={{ display:'flex', flexDirection:'column', gap:'10px' }}>
            <p>Ellenőrizd az e-mailed.</p>
            <p style={{fontSize:'12px', color:'gray'}}>Bezárhatod, de nem lesz teljes a hozzáférés.</p>
            <button onClick={handleResend} disabled={resendCooldown>0}>
              {resendCooldown > 0 ? `${resendCooldown}s` : 'Újra küldés'}
            </button>
          </div>
        </MiniWindow>
      )}

      {/* JELSZÓ VISSZAÁLLÍTÁS ABLAK */}
      {activeWindow === "resetPassword" && (
        <MiniWindow title="Jelszó visszaállítása" onClose={() => setActiveWindow(null)}>
          <form onSubmit={(e) => { e.preventDefault(); handleResetPassword(); }}>
            <input name="email" placeholder="E-mail" onChange={handleInput} maxLength={100} />
            {error && <div className="error-message">{error}</div>}
            <button type="submit" disabled={resendCooldown>0}>
              {resendCooldown > 0 ? `${resendCooldown}s` : 'Visszaállítás'}
            </button>
          </form>
        </MiniWindow>
      )}

      {/* JELSZÓ MÓDOSÍTÁS ABLAK */}
      {activeWindow === "changePassword" && (
        <MiniWindow title="Jelszó módosítása" onClose={() => setActiveWindow(null)}>
          <form onSubmit={(e) => { e.preventDefault(); handleChangePassword(); }}>
            <PasswordInput name="old_password" placeholder="Régi jelszó" value={form.old_password} onChange={handleInput} />
            <PasswordInput name="new_password1" placeholder="Új jelszó" value={form.new_password1} onChange={handleInput} />
            <PasswordInput name="new_password2" placeholder="Új jelszó újra" value={form.new_password2} onChange={handleInput} />
            {error && <div className="error-message">{error}</div>}
            <button type="submit">Módosítás</button>
          </form>
        </MiniWindow>
      )}
    </div>
  );
}