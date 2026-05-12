import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from './components/AuthContext';
import "./components/ResetPassword.css";
import { getPasswordError } from './components/authUtils';
import PasswordInput from './components/PasswordInput';

export default function ResetPasswordPage() {
  const { token } = useParams();
  const navigate = useNavigate();
  const { fetchUser } = useAuth();
  const [form, setForm] = useState({ password: "", confirm: "" });
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let timeoutId;

    if (success) {
      timeoutId = setTimeout(() => {
        navigate("/");
      }, 3000);
    }

    return () => {
      if (timeoutId) clearTimeout(timeoutId);
    };
  }, [success, navigate]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleReset = async () => {
    const { password, confirm } = form;

    if (!password || !confirm) return setError("Töltsön ki minden mezőt!");
    if (password !== confirm) return setError("A jelszavak nem egyeznek!");
    
    const pwdError = getPasswordError(password);
    if (pwdError) return setError(pwdError);

    try {
      setLoading(true);
      setError(null);
      
      const res = await fetch(`${process.env.REACT_APP_API_URL}/api/reset/${token}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ newPassword: password }),
        credentials: 'include'
      });

      const data = await res.json();

      if (res.ok) {
        await fetchUser();
        setSuccess(true);
      } else {
        setError(data.error || "Hiba történt");
        setLoading(false);
      }
    } catch (err) {
      setError("Hálózati hiba");
      setLoading(false);
    }
  };

  if (success) return (
    <div className="reset-container">
      <div className="reset-form-wrapper">
        <div className="status-icon">✅</div>
        <h2>Siker!</h2>
        <p className="success-message">Jelszó módosítva és bejelentkezve!</p>
        <p className="success-message" style={{fontSize: '14px', marginTop: '10px'}}>
          Átirányítás a főoldalra...
        </p>
        <button className="verify-button" onClick={() => navigate("/")}>
          Ugrás most
        </button>
      </div>
    </div>
  );

  return (
    <div className="reset-container">
      <div className="reset-form-wrapper">
        <h2>Új jelszó megadása</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          <PasswordInput
            name="password"
            placeholder="Új jelszó"
            value={form.password}
            onChange={handleChange}
          />
          <PasswordInput
            name="confirm"
            placeholder="Új jelszó megerősítése"
            value={form.confirm}
            onChange={handleChange}
          />
          
          {error && <div className="error-text">{error}</div>}
          
          <button 
            className="verify-button" 
            onClick={handleReset}
            disabled={loading}
          >
            {loading ? "Folyamatban..." : "Visszaállítás"}
          </button>
        </div>
      </div>
    </div>
  );
}