import React, { useState, useEffect, useCallback } from "react";
import { useParams } from "react-router-dom";
import { toast } from 'react-toastify';
import { useAuth } from './AuthContext';
import './ChangeColor.css'

/**
 * ChangeColor komponens: Lehetővé teszi a felhasználó számára a tantárgytípusok színeinek testreszabását.
 * Támogatja a mentett szín-presetek (beállítások) betöltését, mentését és törlését.
 */
const ChangeColor = ({ userData, setClassColors, refreshColors, onClose }) => {
  const { id: routeMajorId } = useParams();
  const [majorId] = useState(routeMajorId);
  const { authFetch } = useAuth();
  // --- Állapotok (State) ---
  const [majorData, setMajorData] = useState(null);
  const [colorsOptions, setColorsOptions] = useState([]);
  const [colors, setColors] = useState([]);
  const [name, setName] = useState("");
  const [selectedColors, setSelectedColors] = useState(null);
  const [loading, setLoading] = useState(false);

  const isLoggedIn = !!userData?.id;

  /**
   * Alapértelmezett háttérszín lekérése a CSS változókból.
   */
  const getDefaultColor = useCallback(() => {
    const rootStyles = getComputedStyle(document.documentElement);
    return rootStyles.getPropertyValue('--bg-color-main').trim() || "#ffffff";
  }, []);

  /**
   * Színbeállítások érvényesítése a globális állapoton.
   */
  const applyPresetColors = (colors) => {
    if (typeof setClassColors === "function") {
      setClassColors(colors);
    }
  };

  /**
   * Presetlista frissítése a szerverről.
   */
  const fetchPresets = useCallback(async () => {
    try {
      const res = await authFetch(`/api/colors?major_id=${majorId}`, {
        credentials: "include"
      });
      if (res.ok) {
        const data = await res.json();
        setColorsOptions(Array.isArray(data) ? data : []);
        return data;
      }
    } catch (err) {
      console.error("Hiba a színprofilok frissítésekor:", err);
    }
  }, [majorId]);

  /**
   * Adatok betöltése.
   */
  useEffect(() => {
    if (!majorId) return;

    const fetchData = async () => {
      setLoading(true);
      try {
        const majorRes = await fetch(`/api/majors/${majorId}`);
        let currentMajor = null;
        if (majorRes.ok) {
          currentMajor = await majorRes.json();
          setMajorData(currentMajor);
        }
        
        const allPresets = await fetchPresets();
        
        if (allPresets) {
          const activePreset = allPresets.find(p => p.is_active === true);
          if (activePreset) {
            setSelectedColors(activePreset.id);
            setName(activePreset.name);
            setColors(activePreset.color_codes);
            setClassColors?.(activePreset.color_codes);
          } else if (currentMajor) { 
            setColors(Array(currentMajor.type.length).fill(getDefaultColor()));
          }
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [majorId, fetchPresets, setClassColors, getDefaultColor]);

  const setActivePresetOnServer = async (presetId) => {
    if (!majorId || !presetId) return;
    try {
      await authFetch(`/api/colors/${presetId}/activate`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ major_id: majorId }),
      });
    } catch (err) {
      console.error("Hiba az aktiváláskor:", err);
    }
  };

  const handleSelectPreset = (colorsId) => {
    if (!colorsId) {
      resetForm();
      return;
    }

    const selected = colorsOptions.find(f => f.id === parseInt(colorsId));
    if (!selected) return;

    setSelectedColors(selected.id);
    setColors(selected.color_codes || Array(majorData?.type?.length || 0).fill(getDefaultColor()));
    setName(selected.name || "");
    applyPresetColors(selected.color_codes || []);
  };

  const resetForm = () => {
    setSelectedColors(null);
    setName("");
    if (majorData) {
      const defaultColors = Array(majorData.type.length).fill(getDefaultColor());
      setColors(defaultColors);
      setClassColors?.(defaultColors);
    }
  };

  const handleSave = async () => {
    if (!isLoggedIn) {
      toast.error("Be kell jelentkezni a mentéshez!");
      return;
    }
    if (!name.trim()) return toast.error("Adj nevet a szín profilnak!");

    const payload = {
      major: parseInt(majorId),
      name: name.trim(),
      color_codes: colors,
    };

    try {
      const method = selectedColors ? "PUT" : "POST";
      const url = selectedColors ? `/api/colors/${selectedColors}` : "/api/colors";

      const res = await authFetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify(payload),
      });
      
      if (!res.ok) throw new Error();
      const data = await res.json();
      
      toast.success(`Színprofil ${selectedColors ? "frissítve" : "elmentve"}!`);
      setSelectedColors(data.id);
      await fetchPresets();
      if (refreshColors) refreshColors();
    } catch (err) {
      toast.error("Hiba történt a mentés során");
    }
  };

  const handleDelete = async () => {
  if (!isLoggedIn) return;
  if (!selectedColors || !window.confirm("Biztosan törlöd?")) return;

  try {
    const res = await authFetch(`/api/colors/${selectedColors}`, { 
      method: "DELETE", 
      credentials: "include" 
    });
    
    if (res.ok) {
      toast.success("Színprofil törölve!");
      const updatedPresets = await fetchPresets(); 
      if (updatedPresets && updatedPresets.length > 0) {
        const nextPreset = updatedPresets.find(p => p.is_active) || updatedPresets[0];
        handleSelectPreset(nextPreset.id);
      } else {
        resetForm();
      }
      if (refreshColors) refreshColors();
    }
  } catch (err) {
    toast.error("Hiba a törlés során");
  }
};
  if (loading || !majorData) {
    return (
      <div className="modal-overlay">
        <div className="color-change-popup">
          <button className="close-button" onClick={onClose}>❌</button>
          <p>Betöltés...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="modal-overlay">
      <div className="color-change-popup">
        <button className="close-button" onClick={onClose}>❌</button>
        <h3>Színek módosítása – {majorData.major_name}</h3>

        <select value={selectedColors || ""} onChange={e => handleSelectPreset(e.target.value)}>
          <option value="">-- Színek --</option>
          {colorsOptions
            .filter(f => f.major === parseInt(majorId))
            .map(f => (
              <option key={f.id} value={f.id}>{f.name}</option>
            ))}
        </select>

        <input
          type="text"
          placeholder="Szín csoport név"
          value={name}
          onChange={e => setName(e.target.value)}
          style={{ marginLeft: 10 }}
          maxLength={50}
        />

        {majorData.type.map((cls, index) => (
          <div key={index} className="class-color-input">
            <label style={{ marginRight: 10 }}>{cls}</label>
            <input
              type="color"
              value={colors[index] || getDefaultColor()}
              onChange={e => {
                const newColors = [...colors];
                newColors[index] = e.target.value;
                setColors(newColors);
                setClassColors?.(newColors);
              }}
            />
          </div>
        ))}

        <div style={{ marginTop: "15px"}}>
          <button 
            onClick={async () => {
              applyPresetColors(colors); 
              if (selectedColors && isLoggedIn) {
                await setActivePresetOnServer(selectedColors);
                if (refreshColors) refreshColors();
              }
              onClose();
            }} 
            style={{marginRight: "10px"}}
          >
            Alkalmaz és Bezár
          </button>

          <button 
            onClick={handleSave} 
            style={{ marginRight: "10px" }}
            disabled={!isLoggedIn}
            title={!isLoggedIn ? "Be kell jelentkezni!" : ""}
          >
            {selectedColors ? "Színek frissítése" : "Színek mentése"}
          </button>

          {selectedColors && (
            <button 
              onClick={handleDelete} 
              style={{ color: "red", marginRight: "10px" }}
              disabled={!isLoggedIn}
            >
              Színek törlése
            </button>
          )}

          <button onClick={resetForm}>Reset</button>
        </div>

        {!isLoggedIn && (
          <p style={{ fontSize: "12px", color: "#666", marginTop: "10px" }}>
            💾 Mentés/törlés: Bejelentkezés szükséges
          </p>
        )}
      </div>
    </div>
  );
};

export default ChangeColor;