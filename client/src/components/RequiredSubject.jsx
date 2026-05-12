import React, { useState } from 'react';
import { toast } from 'react-toastify';
import './RequiredSubject.css';

function RequiredSubject({ onAdd }) {
  const [isVisible, setIsVisible] = useState(true);

  /**
   * Kezeli a tárgyak behúzását (drop esemény).
   */
  const handleDrop = (e) => {
  e.preventDefault();
  const subjectData = e.dataTransfer.getData('subject');
  if (!subjectData) return;

  try {
    const subject = JSON.parse(subjectData);
    onAdd(subject);
  } catch (err) {
    toast.error('Hiba a tárgy hozzáadásakor!');
  }
};

  /**
   * Megfordítja a panel láthatóságát.
   */
  const toggleVisibility = () => {
    setIsVisible(!isVisible);
  };

  return (
    <div>
      {/* Kapcsológomb a panel elrejtéséhez vagy megjelenítéséhez */}
      <button className="toggle-button" onClick={toggleVisibility}>
        {isVisible ? 'Előírás elrejtése' : 'Előírás'}
      </button>

      {/* A tartalom csak akkor jelenik meg, ha az isVisible értéke igaz */}
      {isVisible && (
        <div
          className="required-drop-area"
          onDrop={handleDrop}
          onDragOver={(e) => e.preventDefault()}
        >
          <h3>Előírt tárgyak</h3>
          <p>Húzzon ide egy tárgyat a tárgylistából, és az automatikusan hozzáadódik.</p>
        </div>
      )}
    </div>
  );
}

export default RequiredSubject;