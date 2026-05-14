import React, { useState, useEffect, useCallback } from 'react';
import { useParams } from 'react-router-dom';

/**
 * Segédfüggvény: Speciális PostgreSQL tömb formátum feldolgozása.
 * Kívül definiáljuk, hogy ne jöjjön létre minden renderelésnél újra.
 */
function parseCustomArrayString(str) {
  if (!str) return [];
  let clean = str.trim();
  if (clean.startsWith('{') && clean.endsWith('}')) {
    clean = clean.slice(1, -1);
  }
  const items = clean.split('","').map(s => s.replace(/^"+|"+$/g, '').trim());
  return items.filter(Boolean);
}

export default function FilterPanel({ filters, setFilters }) {
  const { id } = useParams();
  const [filterData, setFilterData] = useState(null);
  const [collapsed, setCollapsed] = useState({});
   const API_URL = process.env.REACT_APP_API_URL;

  
  useEffect(() => {
    if (!id) return;
    const controller = new AbortController();

    fetch(`${API_URL}/api/majors/${id}`, { signal: controller.signal })
      .then(res => {
        if (!res.ok) throw new Error('Failed to fetch');
        return res.json();
      })
      .then(data => {
        const parsed = {};
        parsed["Év"] = Array.isArray(data.syllabus_year) ? data.syllabus_year : [];
        parsed["Tantárgy csoport"] = Array.isArray(data.category) ? data.category : [];
        parsed["5 fő csoport"] = Array.isArray(data.type) ? data.type : parseCustomArrayString(data.type);
        
        setFilterData(parsed);
      })
      .catch(err => {
        if (err.name !== 'AbortError') {
          console.error("Hiba a szűrő adatok betöltésekor:", err);
          setFilterData({});
        }
      });

    return () => controller.abort();
  }, [id, API_URL]);

 
  const toggletype = useCallback((type) => {
    setCollapsed(prev => ({
      ...prev,
      [type]: !prev[type]
    }));
  }, []);

  const handleCheckbox = useCallback((type, option) => {
    const key = `${type}:${option}`;
    setFilters(prevFilters => {
      const newFilters = { ...prevFilters };
      if (newFilters[key]) {
        delete newFilters[key];
      } else {
        newFilters[key] = true;
      }
      return newFilters;
    });
  }, [setFilters]);

  if (!filterData) {
    return <p>Loading filters...</p>;
  }

  return (
    <div className="filter-panel">
      <h2>Szűrők</h2>
      {Object.entries(filterData).map(([type, options]) => (
        <div key={type} className="filter-type">
          <div
            onClick={() => toggletype(type)}
            className="filter-group-title"
            style={{ cursor: 'pointer' }}
          >
            {type} {collapsed[type] ? '▶' : '▼'}
          </div>
          
          {!collapsed[type] && (
            <div className="filter-options">
              {options.map(option => {
                const filterKey = `${type}:${option}`;
                return (
                  <label key={option}>
                    <input
                      type="checkbox"
                      checked={!filters[filterKey]}
                      onChange={() => handleCheckbox(type, option)}
                    />
                    {option}
                  </label>
                );
              })}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}