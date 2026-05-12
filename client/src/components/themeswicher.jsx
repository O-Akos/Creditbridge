import React, { useState, useEffect, useCallback, useMemo } from 'react';

/**
 * ThemeSwitcher: Optimalizált témaváltó komponens.
 */
export default function ThemeSwitcher() {
  const prefersDark = useMemo(() => 
    window.matchMedia("(prefers-color-scheme: dark)").matches, 
  []);

  const [theme, setTheme] = useState(() => {
    try {
      return localStorage.getItem('theme') || (prefersDark ? 'dark' : 'light');
    } catch (e) {
      // Biztonsági mentés, ha a localStorage le van tiltva/megtelt
      return prefersDark ? 'dark' : 'light';
    }
  });

  const toggleTheme = useCallback(() => {
    setTheme(prevTheme => (prevTheme === 'light' ? 'dark' : 'light'));
  }, []);

  useEffect(() => {
    const root = document.documentElement;
    root.setAttribute('data-theme', theme);
    
    try {
      localStorage.setItem('theme', theme);
    } catch (e) {
      console.warn("LocalStorage mentési hiba:", e);
    }
  }, [theme]);

  return (
    <button 
      className="them-button"
      onClick={toggleTheme}
      aria-pressed={theme === 'dark'}
    >
      {/* Felirat váltása a jelenlegi állapot alapján */}
      {theme === 'light' ? 'Sötét' : 'Világos'} téma
    </button>
  );
}