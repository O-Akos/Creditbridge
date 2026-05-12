import React, { useEffect, useState, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from './components/AuthContext';
import "./components/ResetPassword.css";

function VerifyPage() {
  const { token } = useParams();
  const navigate = useNavigate();
  const { fetchUser, user: authUser } = useAuth();
  const [status, setStatus] = useState("loading");
  const [errorMessage, setErrorMessage] = useState("");
  
  // Ez a ref megakadályozza a végtelen ciklust és a dupla hívást
  const hasCalledVerify = useRef(false);

 useEffect(() => {
  if (hasCalledVerify.current) return;
  hasCalledVerify.current = true;

  let timeoutId;

  const verify = async () => {
    try {
      const res = await fetch(
        `${process.env.REACT_APP_API_URL}/api/verify/${token}`,
        { credentials: 'include' }
      );

      if (!res.ok) {
        const errorData = await res.json();
        await fetchUser();
        
        if (authUser || errorData.message === "Email verified and logged in") {
          setStatus("success");
          timeoutId = setTimeout(() => navigate("/"), 2500);
        } else {
          setErrorMessage(errorData.message || "A megerősítő link érvénytelen vagy már lejárt.");
          setStatus("error");
        }
        return;
      }
      const data = await res.json();
      await fetchUser();
      setStatus("success");
      timeoutId = setTimeout(() => navigate("/"), 2500);

    } catch (err) {
      // IDE FUT BE, HA NINCS ADATBÁZIS KAPCSOLAT / SZERVERHIBA
      console.error("Hálózati hiba:", err);
      setErrorMessage("Hálózati hiba: Nem sikerült elérni a szervert. Kérjük, próbáld meg később!");
      setStatus("error");
    }
  };

  verify();

  return () => {
    if (timeoutId) clearTimeout(timeoutId);
  };
}, [token, navigate, fetchUser, authUser]);
  return (
    <div className="reset-container">
      <div className="reset-form-wrapper">
        {status === "loading" && (
          <>
            <h2>Ellenőrzés</h2>
            <div className="loading-spinner"></div> 
            <p className="success-message">Verifikálás folyamatban...</p>
          </>
        )}
        {status === "success" && (
          <>
            <div className="status-icon">✅</div>
            <h2>Siker!</h2>
            <p className="success-message">Email sikeresen megerősítve!</p>
            <p className="success-message" style={{fontSize: '14px', marginTop: '10px'}}>
              Átirányítás a főoldalra...
            </p>
            {/* Manuális gomb, ha a felhasználó nem akarja megvárni a 3 másodperces időzítőt */}
            <button className="verify-button" onClick={() => navigate("/")}>
              Ugrás most
            </button>
          </>
        )}
        {status === "error" && (
  <>
    <div className="status-icon">❌</div>
    <h2>Hiba történt</h2>
    <div className="error-text" style={{ textAlign: 'center', marginBottom: '20px' }}>
      {errorMessage} {/* Itt jelenik meg a hálózati hiba vagy a lejárt token üzenet */}
    </div>
    <button className="verify-button" onClick={() => navigate("/")}>
      Vissza a főoldalra
    </button>
  </>
)}

      </div>
    </div>
  );
}

export default VerifyPage;