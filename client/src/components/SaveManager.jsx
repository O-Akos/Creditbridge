import React, { useEffect, useState, useRef, useCallback } from "react";
import { useParams } from "react-router-dom";
import { toast } from 'react-toastify';
import { useAuth } from "./AuthContext";
import "./SaveManager.css";

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

export default function SaveManager({
  authUser,
  userData,
  acceptedSubjects,
  requiredSubjects,
  setUserData,
  setAcceptedSubjects,
  setRequiredSubjects,
}) {
  const API_URL = process.env.REACT_APP_API_URL;

  const [saves, setSaves] = useState([]);
  const [activeWindow, setActiveWindow] = useState(null);
  const [slotNames, setSlotNames] = useState({ 2: "", 3: "", 4: "" });
  
  const dirtyRef = useRef(false);
  const quickSaveLoadedRef = useRef(false);

  const { id: routeMajorId } = useParams();
  const majorId = parseInt(routeMajorId);
  const { authFetch } = useAuth();
  /**
   * Mentés funkció (saveToSlot) 
   */
  const saveToSlot = useCallback(async (slot, name, silent = false) => {
    if (!authUser) return;

    const dataToSave = userData || {};
    // A te egyedi validációd marad
    if (!dataToSave.field1 || !dataToSave.field2 || !dataToSave.field3) {
      if (!silent) toast.error("Hallgatói adatok hiányoznak!");
      return;
    }

    try {
      const saveData = {
        userData: dataToSave,
        acceptedSubjects: acceptedSubjects || {},
        requiredSubjects: requiredSubjects || {},
      };

      const res = await authFetch(`${API_URL}/api/save`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({
          slotNumber: slot,
          saveName: name,
          data: saveData,
          majorId: majorId,
        }),
      });

      if (res.ok) {
        dirtyRef.current = false;
        // Frissítjük a listát a mentés után
        const updatedSaves = await authFetch(`${API_URL}/api/saves?majorId=${majorId}`, {
          credentials: "include",
        }).then((r) => (r.ok ? r.json() : []));
        setSaves(updatedSaves);

        if (!silent) toast.success("Mentés sikeres!");
      }
    } catch (e) {
      console.error(e);
      if (!silent) toast.error("Hiba a mentés során!");
    }
  }, [authUser, userData, acceptedSubjects, requiredSubjects, majorId, API_URL, authFetch]);

  /**
   * Első mentés létrehozása
   */
  useEffect(() => {
    if (userData && !saves.find(s => s.slot_number === 1)) {
      saveToSlot(1, "Quick Save", true);
      quickSaveLoadedRef.current = true;
    }
  }, [userData, saves, saveToSlot]);

  /**
   * Változások követése az autosave-hez
   */
  useEffect(() => {
    if (userData) dirtyRef.current = true;
  }, [userData, acceptedSubjects, requiredSubjects]);

  /**
   * Mentések listájának lekérése (Memóriaszivárgás elleni védelemmel)
   */
  useEffect(() => {
    let isMounted = true;

    if (!userData) {
      setSaves([]);
      setSlotNames({ 2: "", 3: "", 4: "" });
      setActiveWindow(null);
      quickSaveLoadedRef.current = false;
      return;
    }

    authFetch(`${API_URL}/api/saves?majorId=${majorId}`, { credentials: "include" })
      .then((res) => (res.ok ? res.json() : []))
      .then((data) => {
        if (!isMounted) return;
        setSaves(data);
        const newNames = { 2: "", 3: "", 4: "" };
        data.forEach((s) => {
          if ([2, 3, 4].includes(s.slot_number)) newNames[s.slot_number] = s.save_name;
        });
        setSlotNames(newNames);
      })
      .catch(err => isMounted && console.error(err));

    return () => { isMounted = false; };
  }, [userData, majorId, API_URL, authFetch]);

  /**
   * Szakváltás kezelése
   */
  useEffect(() => {
    setSaves([]);
    setSlotNames({ 2: "", 3: "", 4: "" });
    quickSaveLoadedRef.current = false;
  }, [majorId]);

  /**
   * Automatikus betöltés (Quick Save)
   */
  useEffect(() => {
    if (!authUser || quickSaveLoadedRef.current) return;

    const loadQuickSave = async () => {
      try {
        const currentSaves = await authFetch(`${API_URL}/api/saves?majorId=${majorId}`, {
          credentials: "include",
        }).then(r => (r.ok ? r.json() : []));

        setSaves(currentSaves);
        let quickSave = currentSaves.find(s => s.slot_number === 1);

        if (!quickSave) {
          await saveToSlot(1, "Quick Save", true);
          return;
        }

        if (quickSave?.save_data) {
          const parsed = quickSave.save_data;
          if (parsed.userData) setUserData(parsed.userData);
          if (parsed.acceptedSubjects) setAcceptedSubjects(parsed.acceptedSubjects);
          if (parsed.requiredSubjects) setRequiredSubjects(parsed.requiredSubjects);
        }

        quickSaveLoadedRef.current = true;
      } catch (err) {
        console.error("Hiba a Quick Save betöltésekor:", err);
      }
    };

    loadQuickSave();
  }, [authUser, majorId, API_URL, setAcceptedSubjects, setRequiredSubjects, setUserData, saveToSlot, authFetch]);

  /**
   * Autosave funkció
   */
  useEffect(() => {
    const interval = setInterval(() => {
      if (
        userData &&
        dirtyRef.current &&
        ((acceptedSubjects && Object.keys(acceptedSubjects).length > 0) ||
          (requiredSubjects && Object.keys(requiredSubjects).length > 0))
      ) {
        saveToSlot(1, "Autosave", true);
      }
    }, 60000);

    return () => clearInterval(interval);
  }, [userData, acceptedSubjects, requiredSubjects, saveToSlot]);

  const quickSave = () => saveToSlot(1, "Quick Save");

  const handleLoad = (save) => {
    if (!authUser) return toast.error("Be kell jelentkezni a betöltéshez!");
    if (!save?.save_data) return;
    const parsed = save.save_data;
    setAcceptedSubjects(parsed.acceptedSubjects);
    setRequiredSubjects(parsed.requiredSubjects);
    toast.success("Adatok betöltve!");
  };
/** 
 * Új hallgató kezdése
*/
  const handleNewStudent = async () => {
  if (!window.confirm("Biztosan új hallgatót szeretnél kezdeni?")) return;

  try {
    setUserData(null);
    setAcceptedSubjects([]);
    setRequiredSubjects([]);
    
    dirtyRef.current = false;
    quickSaveLoadedRef.current = true;

    setSaves([]);

    if (authUser) {
      await authFetch(`${API_URL}/api/saves/clear`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ slotNumber: 1, majorId: majorId }),
      });
      
      const updatedSaves = await authFetch(`${API_URL}/api/saves?majorId=${majorId}`, {
        credentials: "include",
      }).then(r => (r.ok ? r.json() : []));
      setSaves(updatedSaves);
    }

    toast.success("Új munkamenet sikeresen megkezdve!");
  } catch (e) {
    console.error(e);
    toast.error("Hiba történt!");
  }
};
  return (
    
    <div className="save-panel">
      <button onClick={handleNewStudent} className="btn-new-student">👤 Új hallgató</button>
      
      <button
        onClick={quickSave}
        disabled={!authUser}
        title={!authUser ? "Be kell jelentkezni a mentéshez!" : ""}
      >
        💾 Gyors mentés
      </button>

      <button
        onClick={() => setActiveWindow("slots")}
        disabled={!authUser}
        title={!authUser ? "Be kell jelentkezni a mentések kezeléséhez!" : ""}
      >
        🗂 Mentések kezelése
      </button>

      {activeWindow === "slots" && (
        <MiniWindow title="Mentési helyek" onClose={() => setActiveWindow(null)}>
          {!authUser ? (
            <p>Be kell jelentkezni a mentéshez!</p>
          ) : (
            [2, 3, 4].map((slot) => (
              <button key={slot} onClick={() => setActiveWindow(slot)}>
                {slotNames[slot] || `Hely ${slot-1}`}
              </button>
            ))
          )}
        </MiniWindow>
      )}

      {[2, 3, 4].map((slot) => {
        if (activeWindow !== slot) return null;
        const save = saves.find((s) => s.slot_number === slot);

        return (
          <MiniWindow key={slot} title={`Hely ${slot-1}`} onClose={() => setActiveWindow("slots")}>
            {!authUser ? (
              <p>Be kell jelentkezni a mentéshez!</p>
            ) : (
              <>
                <p><strong>Mentés neve:</strong></p>
                <input
                  type="text"
                  value={slotNames[slot]}
                  onChange={(e) => setSlotNames({ ...slotNames, [slot]: e.target.value })}
                  placeholder={`Hely ${slot-1}`}
                  maxLength={50}
                />

                {save?.updated_at && (
                  <p>
                    <strong>Utolsó mentés:</strong>
                    <br />
                    {new Date(save.updated_at).toLocaleString()}
                  </p>
                )}

                <div style={{ display: "flex", gap: "10px" }}>
                  <button onClick={() => saveToSlot(slot, slotNames[slot])}>💾 Mentés</button>
                  {save && <button onClick={() => handleLoad(save)}>📥 Betöltés</button>}
                  <button onClick={() => setActiveWindow("slots")}>🔙 Vissza</button>
                </div>
              </>
            )}
          </MiniWindow>
        );
      })}
    </div>
  );
}