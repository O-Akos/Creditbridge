import React, { useState} from 'react';
import { toast } from 'react-toastify';
import './AcceptPairing.css'; 

/* Itt végezzük a tárgyak párosítását, mind a szöveges hozzá adást illetve a drag and drop mechanikát is.
Beíert tárgyhoz tetszőleges rublika hozzá adható míg a drag and dropos felület kettő darabot engedélyez.*/

export default function AcceptPairing({ onAccept }) {
  const [writtenSubjects, setWrittenSubjects] = useState(['']);
  const [droppedSubjects, setDroppedSubjects] = useState([]);


function handleDrop(e) {
    e.preventDefault();
    try {
      const data = e.dataTransfer.getData('subject');
      if (!data) return;
      const subjectData = JSON.parse(data);

      // JAVÍTÁS: sub.name helyett sub.code vizsgálata
      if (droppedSubjects.some(sub => sub.code === subjectData.code)) {
        toast.warning(`"${subjectData.name}" (${subjectData.code}) már hozzá lett adva.`);
        return;
      }
      
      setDroppedSubjects(prev => [...prev, subjectData]);
    } catch (err) {
      console.error("Hiba a behúzott adat feldolgozásakor", err);
    }
  }

  function handleDragOver(e) {
    e.preventDefault();
  }

  function updateWritten(index, value) {
    const copy = [...writtenSubjects];
    copy[index] = value;
    setWrittenSubjects(copy);
  }

  function removeWritten(index) {
    const copy = [...writtenSubjects];
    copy.splice(index, 1);
    setWrittenSubjects(copy);
  }

  function addWrittenField() {
    setWrittenSubjects([...writtenSubjects, '']);
  }

  function removeDropped(index) {
    setDroppedSubjects(droppedSubjects.filter((_, i) => i !== index));
  }

  function canAccept() {
    const hasWritten = writtenSubjects.some((name) => name.trim());
    const hasDropped = droppedSubjects.length > 0;
    return hasWritten && hasDropped;
  }

  function handleAccept() {
    const validWrittenSubjects = writtenSubjects.filter((name) => name.trim() !== '');
    const hasDropped = droppedSubjects.length > 0;

    if (validWrittenSubjects.length > 0 && hasDropped) {
      onAccept({
        id: Date.now(),
        externalNames: validWrittenSubjects,
        internalSubjects: droppedSubjects,
      });

      setWrittenSubjects(['']);
      setDroppedSubjects([]);
    }
  }

  return (
    <div className="accept-pairing">
      <h2>Elfogadás</h2>

      {writtenSubjects.map((value, index) => (
        <div key={index} className="written-subject">
          <input
            type="text"
            placeholder={`Külső tárgy neve ${index + 1}...`}
            value={value}
            onChange={(e) => updateWritten(index, e.target.value)}
          />
          {writtenSubjects.length > 1 && (
            <button onClick={() => removeWritten(index)} className="remove-written-btn">
              ×
            </button>
          )}
        </div>
      ))}

      <button onClick={addWrittenField} className="add-written-btn">
        ➕ További tárgy hozzáadása
      </button>

      <div
  onDrop={handleDrop}
  onDragOver={handleDragOver}
  className={`drop-zone ${droppedSubjects.length > 0 ? 'has-items' : ''}`}
>
  {droppedSubjects.length === 0 && <p style={{ margin: 0 }}>Húzza ide a tárgyat a tárgylistából!</p>}

  {droppedSubjects.map((dropped, i) => (
    <div key={i} className="dropped-item">
      <span>{dropped.name} (kredit: {dropped.credit})</span>
      <button
        onClick={() => removeDropped(i)}
        className="remove-dropped-btn"
        aria-label="Törlés"
      >
        ×
      </button>
    </div>
  ))}
</div>
      <button
        onClick={handleAccept}
        disabled={!canAccept()}
        className={`accept-btn ${canAccept() ? 'enabled' : 'disabled'}`}
      >
        ✅ Elfogad
      </button>
    </div>
  );
}
