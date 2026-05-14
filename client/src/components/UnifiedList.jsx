import React, { useState, useMemo, useEffect, useCallback } from 'react';
import { useParams } from 'react-router-dom';
import './UnifiedList.css';

function UnifiedList({ items, onRemove, classColors = [] }) {
  // Állapotok
  const [searchTerm, setSearchTerm] = useState(''); // A keresőmező szövege
  const [filterType, setFilterType] = useState('all'); // Szűrés típus szerint: Összes / Elfogadott / Előírt
  const { id } = useParams(); // Az aktuális szak ID-ja az URL-ből
  const [majorClasses, setMajorClasses] = useState([]); // A szakhoz tartozó tantárgycsoportok (pl. "A csoport", "Szabadon választható")

  // Adatok betöltése
  useEffect(() => {
    const controller = new AbortController();
    async function loadMajorClasses() {
      try {
        const response = await fetch(`/api/majors/${id}`, { signal: controller.signal });
        const data = await response.json();
        setMajorClasses(data.type || []);
      } catch (err) {
        if (err.name !== 'AbortError') console.error(err);
      }
    }
    if (id) loadMajorClasses();
    return () => controller.abort();
  }, [id]);

  // Színkezelés
  const colorMap = useMemo(() => {
    const map = {};
    majorClasses.forEach((cls, i) => {
      map[cls] = classColors[i] || "var(--bg-color-main)";
    });
    return map;
  }, [classColors, majorClasses]);

  // Szűrési logika
  const filteredItems = useMemo(() => {
    return items.filter(item => {
      const matchesType = filterType === 'all' ? true : item.type_a === filterType;

      const searchText = searchTerm.toLowerCase().trim();
      let matchesSearch = false;

      if (item.type_a === 'accepted') {

        const external = item.externalNames.join(' + ').toLowerCase();
        const internal = item.internalSubjects.map(s => s.name.toLowerCase()).join(' + ');
        matchesSearch = external.includes(searchText) || internal.includes(searchText);
      } else if (item.type_a === 'required') {

        matchesSearch = item.name.toLowerCase().includes(searchText);
      }

      return matchesType && matchesSearch;
    });
  }, [items, filterType, searchTerm]);

  // Segédfüggvény: megkeresi, hogy az adott tárgy melyik szakcsoportba tartozik
  const getMajorClass = useCallback((item) => {
    if (item.type_a === 'accepted') {
      const firstSub = item.internalSubjects[0] || {};
      return Object.values(firstSub).find(val => majorClasses.includes(val)) || null;
    } 
    return Object.values(item).find(val => majorClasses.includes(val)) || null;
  }, [majorClasses]);

  return (
    <div className="unified-list">
      <div className="unified-list-header">
        <h2>Összes Tárgy</h2>
        
        <select
          value={filterType}
          onChange={(e) => setFilterType(e.target.value)}
          className="filter-select"
        >
          <option value="all">Összes</option>
          <option value="accepted">Elfogadott</option>
          <option value="required">Előírt</option>
        </select>

        <div className="unified-controls">
          <input
            type="text"
            placeholder="Keresés..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
      </div>

      {filteredItems.length === 0 ? (
        <p>Nincs találat.</p>
      ) : (
        <ul>
          {filteredItems.map(item => {
            const majorClass = getMajorClass(item);
            const bgColor = colorMap[majorClass] || "var(--bg-color-main)";

            if (item.type_a === 'accepted') {
              const externalLabel = item.externalNames.join(' + ');
              const internalWithCredits = item.internalSubjects
                .map(sub => `${sub.name} (${sub.credit})`)
                .join(' + ');

              return (
                <li
      key={`accepted-${item.id}`}
      className="unified-item accepted-item"
      style={{ backgroundColor: bgColor }}
    >
      <div className="vertical-label accepted-label">Elfogadott</div>
      <div className="item-content">
        <strong>{externalLabel}</strong> ➡️ <em>{internalWithCredits}</em>
      </div>
      <button onClick={() => onRemove(item.id, 'accepted')}>❌</button>
    </li>
              );
            }

            if (item.type_a === 'required') {
              return (
                <li
                  key={`required-${item.id}`}
                  className="unified-item required-item"
                  style={{ backgroundColor: bgColor }}
                >
                  <div className="vertical-label required-label">Előírt</div>
                  <div className="item-content">
                    {item.name} ({item.credit} kredit)
                  </div>
                  {/* Törlés gomb: meghívja a szülő Application.jsx-ben lévő handleRemoveRequired-et */}
                  <button onClick={() => onRemove(item.id, 'required')}>❌</button>
                </li>
              );
            }

            return null;
          })}
        </ul>
      )}
    </div>
  );
}

export default UnifiedList;