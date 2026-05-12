import React, { useState, useEffect, useCallback } from "react";
import "./DataPopup.css"; 

/**
 * DataPopup komponens
 */
const DataPopup = ({ onSubmit, onClose, initialData }) => {
  const [formData, setFormData] = useState({
    field1: initialData?.field1 || "",
    field2: initialData?.field2 || "",
    field3: initialData?.field3 || "",
  });

  useEffect(() => {
    if (initialData) {
      setFormData(initialData);
    }
  }, [initialData]);

  const handleChange = useCallback((e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  }, []);

  const handleSubmit = useCallback((e) => {
    e.preventDefault();
    onSubmit(formData);
  }, [onSubmit, formData]);

  return (
    <div className="popup">
      <div className="popup-content">
        <button type="button" className="close-x" onClick={onClose} aria-label="Bezárás">
          &times;
        </button>

        <h2>Adatok megadása</h2>
        
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            name="field1"
            placeholder="Intézmény neve"
            value={formData.field1}
            onChange={handleChange}
            required
            maxLength={200}
          />
          
          <input
            type="text"
            name="field2"
            placeholder="Szak megnevezése"
            value={formData.field2}
            onChange={handleChange}
            required
            maxLength={200}
          />
          
          <input
            type="text"
            name="field3"
            placeholder="Hallgató neve"
            value={formData.field3}
            onChange={handleChange}
            required
            maxLength={200}
          />
          
          <button type="submit" className="save-btn">Mentés</button>
        </form>
      </div>
    </div>
  );
};

export default DataPopup;