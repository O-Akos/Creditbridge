import React, { useState, useEffect, useCallback } from "react";
import { Link } from "react-router-dom";
import AddMajorModal from "./components/AddMajorModal";
import ThemeSwitcher from './components/themeswicher';
import AccountPanel from "./components/AccountPanel";
import "./components/MajorsPage.css";
import { useAuth } from './components/AuthContext';

const MainMenu = () => {
  const { user: authUser, fetchUser } = useAuth();
  const API_URL = process.env.REACT_APP_API_URL;

  const [majors, setMajors] = useState([]);          
  const [modalOpen, setModalOpen] = useState(false);  
  const [majorToEdit, setMajorToEdit] = useState(null); 
  const [editMode, setEditMode] = useState(false);    
  const [searchQuery, setSearchQuery] = useState(""); 
  const isLoggedIn = !!(authUser && authUser.id);

const refreshMajors = useCallback(() => {
  let isMounted = true;

  fetch(`${API_URL}/api/majors`)
    .then((res) => res.json())
    .then((data) => {
      if (isMounted) {
        setMajors(data);
        if (Array.isArray(data)) {
          setMajors(data);
        } else {
          console.error("Nincs létrehozott szak.", data);
          setMajors([]);
        }
      }
    })
    .catch((err) => { 
      if (isMounted) {
        console.error(err); 
        setMajors([]); 
      }
    });

  return () => { isMounted = false; };
}, [API_URL]);

  useEffect(() => {
    refreshMajors();
  }, [refreshMajors]);

  useEffect(() => {
    if (!isLoggedIn) {
      setEditMode(false);
    }
  }, [isLoggedIn]);

  const filteredMajors = (majors || []).filter((major) =>
    major.major_name?.toLowerCase().includes(searchQuery.toLowerCase())
);

  return (
    <div className="majors-container">
      <header className="majors-header">
        <h1>Szakválasztás</h1>
        <div className="header-controls">
          <input
            type="text"
            placeholder="Keresés..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="search-input"
          />
          
          {/* A gomb mindig ott van, de ha nincs bejelentkezve, inaktív és kiírja az üzenetet */}
          <button
            className={`edit-mode-button ${editMode ? "active" : ""}`}
            onClick={() => setEditMode(!editMode)}
            disabled={!isLoggedIn}
            title={!isLoggedIn ? "Be kell jelentkezni a használathoz" : ""}
          >
            {editMode ? "Szerkesztés kikapcsolása" : "Szerkesztés bekapcsolása"}
          </button>

          <ThemeSwitcher />

          <AccountPanel
            userData={authUser}
            onLogin={fetchUser}
            onLogout={() => {}}
          />
        </div>
      </header>

      {editMode && (
        <button
          className="add-button"
          onClick={() => { 
            setMajorToEdit(null);
            setModalOpen(true); 
          }}
          disabled={!isLoggedIn}
          title={!isLoggedIn ? "Be kell jelentkezni a használathoz" : ""}
        >
          Új szak hozzáadása
        </button>
      )}

      <nav>
        <ul className="majors-list">
          {filteredMajors.length === 0 && <li className="loading">Nincs találat, várakozás a szerverre...</li>}
          
          {filteredMajors.map((major) => (
            <li key={major.id} className="major-item">
              <Link to={`/app/${major.id}`} className="major-link">{major.major_name}</Link>
              
              {editMode && (
                <button
                  className="edit-button"
                  onClick={() => { 
                    setMajorToEdit(major);
                    setModalOpen(true);
                  }}
                  disabled={!isLoggedIn}
                  title={!isLoggedIn ? "Be kell jelentkezni a használathoz" : ""}
                >
                  Szerkesztés
                </button>
              )}
            </li>
          ))}
        </ul>
      </nav>

      <AddMajorModal
        show={modalOpen}
        onClose={() => setModalOpen(false)}
        refreshMajors={refreshMajors}
        majorToEdit={majorToEdit}
        authUser={authUser}
      />
    </div>
  );
};

export default MainMenu;