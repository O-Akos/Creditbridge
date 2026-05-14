import React, { useEffect, Navigate } from 'react';
import { Routes, Route } from 'react-router-dom';
import MainMenu from './Mainmenu';
import Application from './Application';
import VerifyPage from './VerifyPage';
import ResetPasswordPage from './ResetPasswordPage';
import { AuthProvider } from './components/AuthContext';
import { ToastContainer, toast} from 'react-toastify';

/**
 * Az App komponens az alkalmazás útvonalválasztója (Router).
 * Itt definiáljuk, hogy melyik URL címhez melyik komponens tartozzon.
 */
function App() {


  useEffect(() => {
    const handleOnline = () => {

      toast.success("Internetkapcsolat helyreállt!");
    };
    const handleOffline = () => {
      toast.error("Nincs internetkapcsolat!", { autoClose: false, toastId: 'offline' });
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Takarítás az unmount fázisban
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);
  return (
    <AuthProvider>
      <ToastContainer 
        position="top-center" 
        autoClose={3000} 
        limit={3}
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
        theme="colored"
      />
    <Routes>
      {/* Főoldal: Itt listázzuk ki a szakokat */}
      <Route path="/" element={<MainMenu />} />

      {/* Egy konkrét szak részletei az egyedi azonosítója alapján */}
      <Route path="/app/:id" element={<Application />} />

      {/* E-mail megerősítő oldal - a token azonosítja a felhasználót */}
      <Route path="/verify/:token" element={<VerifyPage />} />

      {/* Jelszó visszaállító oldal - a token biztosítja a jogosultságot a módosításhoz */}
      <Route path="/reset/:token" element={<ResetPasswordPage />} />

      <Route path="*" element={<Navigate to="/" replace />} />

    </Routes>
    </AuthProvider>
  );
}

export default App;