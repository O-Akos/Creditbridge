import React, { createContext, useState, useContext, useEffect, useCallback } from 'react';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {

  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const API_URL = process.env.REACT_APP_API_URL;

  const logout = async () => {
    try {
      await authFetch(`${API_URL}/api/logout`, { 
        method: 'POST', 
        credentials: 'include' 
      });
    } catch (err) {
      console.error("Logout hálózati hiba:", err);
    } finally {
      setUser(null);
      window.location.href = "/"; 
    }
  };
const fetchUser = useCallback(async () => {
  try {
    const res = await fetch(`${API_URL}/api/me`, { credentials: 'include' });

    if (res.status === 401) {
      setUser(null);
      return;
    }

    if (res.ok) {
      const data = await res.json();
      setUser(data);
    } else {
      setUser(null);
    }
  } catch (err) {
    console.error("Szerver kapcsolati hiba:", err);
    setUser(null);
  } finally {
    setLoading(false);
  }
}, [API_URL]);
const authFetch = async (url, options = {}) => {
    const res = await fetch(url, { ...options, credentials: 'include' });
    if (res.status === 401) {
      await logout(); 
      return null;
    }
    return res;
  };

  useEffect(() => {
    fetchUser();
  }, [fetchUser]);

  return (
    <AuthContext.Provider value={{ user, setUser, fetchUser, loading, logout, authFetch }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);