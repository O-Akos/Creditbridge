import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';

import 'react-toastify/dist/ReactToastify.css';
import { toast } from 'react-toastify';
// Alkomponensek importálása - minden funkció külön modulban van
import FilterPanel from './components/FilterPanel';
import SubjectList from './components/SubjectList';
import AcceptPairing from './components/AcceptPairing';
import CreditTable from './components/CreditTable';
import RequiredSubject from './components/RequiredSubject';
import DataPopup from './components/DataPopup';
import ThemeSwitcher from './components/themeswicher';
import UnifiedList from './components/UnifiedList';
import ChangeColor from './components/ChangeColor';
import ExcelManager from './components/Excelsave';
import AccountPanel from './components/AccountPanel';
import SaveManager from './components/SaveManager';
import { useAuth } from './components/AuthContext';
import './components/variables.css';
import './Application.css';

function Application() {
  // Állapotkezelés
  const [filters, setFilters] = useState({}); // Szűrési feltételek a tárgylistához
  const [acceptedSubjects, setAcceptedSubjects] = useState([]); // Elfogadott (párosított) tárgyak listája
  const [requiredSubjects, setRequiredSubjects] = useState([]); // Előírt (még teljesítendő) tárgyak listája
  const [showPopup, setShowPopup] = useState(false); // Hallgatói adatokat kérő ablak láthatósága
  const [studentData, setStudentData] = useState(null); // Hallgató adatai (név, szak, intézmény)
  //const [authUser, setAuthUser] = useState(null); // Bejelentkezett felhasználó adatai
  const { user: authUser, fetchUser } = useAuth();
  const [showColorChange, setShowColorChange] = useState(false); // Színmódosító ablak állapota
  const [classColors, setClassColors] = useState([]); // Egyedi színek a tárgycsoportokhoz
  const { id: majorId } = useParams();
  const navigate = useNavigate();
  const [isValidMajor, setIsValidMajor] = useState(null); 
  const [isInitialLoading, setIsInitialLoading] = useState(true);
  const API_URL = process.env.REACT_APP_API_URL;

 /* // Felhasználó hitelesítése
  const fetchAuthUser = async () => {
    try {
      const res = await fetch(`${API_URL}/api/me`, { credentials: 'include' });
      if (res.ok) {
        const data = await res.json();
        setAuthUser(data);
        console.log("Auth user loaded:", data);
      } else {
        setAuthUser(null);
      }
    } catch (err) {
      console.error("Fetch auth user failed:", err);
      setAuthUser(null);
    }
  };

  useEffect(() => {
    fetchAuthUser();
  }, []);*/
  /*useEffect(() => {
    const controller = new AbortController();
    
    const fetchActiveColors = async () => {
      if (authUser?.id && majorId) {
        try {
          const res = await fetch(`${API_URL}/api/colors?user_id=${authUser.id}&major_id=${majorId}`, { 
            credentials: 'include',
            signal: controller.signal
          });
          
          if (res.ok) {
            const allPresets = await res.json();
            const activePreset = allPresets.find(p => p.is_active === true);
            if (activePreset?.color_codes) {
              setClassColors(activePreset.color_codes);
            }
          }
        } catch (err) {
          if (err.name !== 'AbortError') {
            console.error("Hiba a színek betöltésekor:", err);
          }
        }
      }
    };

    fetchActiveColors();
    return () => controller.abort();
  }, [authUser?.id, majorId, API_URL]);*/
  const refreshColors = useCallback(async (signal) => {
    if (authUser?.id && majorId) {
      try {
        const res = await fetch(`${API_URL}/api/colors?user_id=${authUser.id}&major_id=${majorId}`, { 
          credentials: 'include',
          signal: signal
        });
        
        if (res.ok) {
          const allPresets = await res.json();
          const activePreset = allPresets.find(p => p.is_active === true);
          
          if (activePreset?.color_codes) {
            setClassColors(activePreset.color_codes);
          } else {
            setClassColors([]);
          }
        }
      } catch (err) {
        if (err.name !== 'AbortError') console.error("Hiba:", err);
      }
    }
  }, [authUser?.id, majorId, API_URL]);

  useEffect(() => {
    const controller = new AbortController();
    refreshColors(controller.signal);
    return () => controller.abort();
  }, [refreshColors]);

  // Kezelőfüggvények

  // Amikor a felhasználó menti a személyes adatait a popupban
  const handlePopupSubmit = (data) => {
    setStudentData(data);
    setShowPopup(false);
  };

  // Tárgyak eltávolítása a listákból ID alapján
  const handleRemoveAccepted = useCallback((id) => {
    setAcceptedSubjects((prev) => prev.filter((s) => s.id !== id));
  }, []);

  const handleRemoveRequired = useCallback((id) => {
    setRequiredSubjects((prev) => prev.filter((s) => s.id !== id));
  }, []);

  const unifiedItems = useMemo(() => [
    ...acceptedSubjects.map((item) => ({ ...item, type_a: 'accepted' })),
    ...requiredSubjects.map((item) => ({ ...item, type_a: 'required' })),
  ], [acceptedSubjects, requiredSubjects]);

  // Színválasztó ablak nyitás/zárás
  const handleOpenColorChange = () => setShowColorChange(true);
  const handleCloseColorChange = () => setShowColorChange(false);

  // Új előírt tárgy hozzáadása (ellenőrzéssel, hogy ne szerepeljen duplán)
  const handleAddRequired = (subject) => {
    const existsRequired = requiredSubjects.some(s => s.id === subject.id);
    const existsAccepted = acceptedSubjects.some(acc =>
      acc.internalSubjects.some(sub => sub.id === subject.id)
    );

    if (existsRequired || existsAccepted) {
      toast.warning("Ez a tárgy már elő van írva vagy el van fogadva!");
      return;
    }
    setRequiredSubjects(prev => [...prev, subject]);
  };

  const handleAddAccepted = (newSubject) => {
    const internalIds = newSubject.internalSubjects.map(s => s.id);
    const alreadyAccepted = acceptedSubjects.some(acc =>
      acc.internalSubjects.some(sub => internalIds.includes(sub.id))
    );

    if (alreadyAccepted) {
      toast.warning("Ez a belső tárgy már hozzá lett adva!");
      return;
    }

    setAcceptedSubjects(prev => {
      const existingIndex = prev.findIndex(acc =>
        JSON.stringify(acc.externalNames.sort()) === JSON.stringify(newSubject.externalNames.sort())
      );

      if (existingIndex !== -1) {
        const existing = prev[existingIndex];
        const mergedInternalSubjects = [
          ...existing.internalSubjects,
          ...newSubject.internalSubjects.filter(
            s => !existing.internalSubjects.some(existingSub => existingSub.id === s.id)
          )
        ];
        const updated = [...prev];
        updated[existingIndex] = { ...existing, internalSubjects: mergedInternalSubjects };
        return updated;
      }
      return [...prev, newSubject];
    });
  };
  
  // Szak érvényességének ellenőrzése
  useEffect(() => {
    const checkMajor = async () => {
      setIsInitialLoading(true);
      try {
        const res = await fetch(`${API_URL}/api/majors/${majorId}`);
        if (res.ok) {
          setIsValidMajor(true);
        } else {
          toast.error("A választott szak nem található!");
          setIsValidMajor(false);
          navigate("/");
        }
      } catch (err) {
        console.error("Hiba az ellenőrzéskor:", err);
        setIsValidMajor(false); 
        navigate("/")
        toast.error("Nem sikerült ellenőrizni a szakot.");
      } finally {
        setIsInitialLoading(false);
      }
    };

    if (majorId) checkMajor();
  }, [majorId, API_URL, navigate]);

  if (isInitialLoading) {
    return <div className="loading-screen">Szakadatok ellenőrzése...</div>;
  }

  if (isValidMajor === false) {
    return null; 
  }
  return (
    <>
    
    
      {/* Felső információs sáv és vezérlőgombok */}
      <div className="rows">
        <div className="top_row">
          {studentData ? (
            <strong>
              Intézmény: {studentData.field1} | Szak: {studentData.field2} | Hallgató: {studentData.field3}
            </strong>
          ) : (
            <strong>Hallgatói adatok nincsenek megadva.</strong>
          )}
          <button className="them-button" style={{ marginLeft: '15px' }} onClick={() => setShowPopup(true)}>
            {studentData ? "Adatok módosítása" : "Adatok megadása"}
          </button>
        </div>

        <div className="under_row">
          <ThemeSwitcher />
          
          {/* Színmódosítás csak bejelentkezve érhető el */}
          <button 
            className="them-button" 
            onClick={handleOpenColorChange}
            disabled={!authUser}
            
            title={!authUser ? "Be kell jelentkezni a színek módosításához!" : ""}
          >
            Csoport színek
          </button>

          {/* Excel mentésért és betöltésért felelős komponens */}
          <ExcelManager
            userData={studentData}
            acceptedSubjects={acceptedSubjects}
            requiredSubjects={requiredSubjects}
            setUserData={setStudentData}
            setAcceptedSubjects={setAcceptedSubjects}
            setRequiredSubjects={setRequiredSubjects}
            openUserPopup={() => setShowPopup(true)}
          />

          {/* Adatbázisba mentésért felelős komponens csak bejelentkezett fiókoknak.*/}
          <SaveManager
            authUser={authUser}
            userData={studentData}
            acceptedSubjects={acceptedSubjects}
            requiredSubjects={requiredSubjects}
            setUserData={setStudentData}
            setAcceptedSubjects={setAcceptedSubjects}
            setRequiredSubjects={setRequiredSubjects}
          />

          <AccountPanel
            userData={authUser}
            //onLogin={fetchAuthUser}
            //onLogout={() => setAuthUser(null)}

            onLogin={fetchUser}
            onLogout={() => {}}
          />
        </div>
      </div>

      {/* Felugró ablakok (Popups) */}
      {showPopup && <DataPopup onSubmit={handlePopupSubmit} onClose={() => setShowPopup(false)} initialData={studentData} />}
      {showColorChange && <ChangeColor userData={authUser} setClassColors={setClassColors} onClose={handleCloseColorChange} />}

      {/* Fő tartalom: 4 oszlopos elrendezés */}
      <div className="four_columns">
        <div className="column column_1">
          <FilterPanel filters={filters} setFilters={setFilters} />
        </div>
        <div className="column column_2">
          <SubjectList filters={filters} />
        </div>
        <div className="column column_3">
          <CreditTable acceptedSubjects={acceptedSubjects} requiredSubjects={requiredSubjects} />
          <AcceptPairing onAccept={handleAddAccepted} />
        </div>
        <div className="column column_4">
          <RequiredSubject onAdd={handleAddRequired} />
          <UnifiedList
            items={unifiedItems}
            onRemove={(id, type_a) => {
              if (type_a === 'accepted') handleRemoveAccepted(id);
              else if (type_a === 'required') handleRemoveRequired(id);
            }}
            classColors={classColors}
          />
        </div>
      </div>
    </>
  );
}

export default Application;