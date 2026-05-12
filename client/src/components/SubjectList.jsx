import React, { useState, useEffect, useMemo } from 'react';
import { useParams } from 'react-router-dom';
import { toast } from 'react-toastify';

export default function SubjectList({ filters }) {
  const [searchTerm, setSearchTerm] = useState('');
  const [subjects, setSubjects] = useState([]);
  const { id } = useParams();


useEffect(() => {
  const controller = new AbortController();
  
  const fetchSubjects = async () => {
    try {
      const response = await fetch(`/api/majors/${id}/subjects`, {
        signal: controller.signal 
      });

      if (response.status === 404) {
        toast.error(`A kért szak (ID: ${id}) nem található a rendszerben.`);
        window.location.href = "/";
        return;
      }

      if (!response.ok) throw new Error("Szerver hiba történt.");

      const data = await response.json();
      setSubjects(data);
    } catch (error) {
      if (error.name !== 'AbortError') {
        if (!navigator.onLine) {
          toast.error("Nincs internetkapcsolat! Kérjük, ellenőrizze a hálózatot.");
        } else {
          console.error('Failed to fetch subjects:', error);
          toast.error("Nem sikerült kapcsolódni a szerverhez.");
        }
      }
    }
  };

  fetchSubjects();
  return () => controller.abort(); 
}, [id]);


  const filteredSubjects = useMemo(() => {
    let result = [...subjects];

    if (Object.keys(filters).length > 0) {
      result = result.filter(subject => {
        for (const filterKey of Object.keys(filters)) {
          const [type, option] = filterKey.split(':');

          if (type === 'Év' && String(subject.syllabus_year) === option) return false;
          if (type === 'Tantárgy csoport' && String(subject.category).trim() === option) return false;
          if (type === '5 fő csoport' && String(subject.type).trim() === option) return false;
          if (type === 'Előírható tárgyak' && String(subject.prescribable) === option) return false;
        }
        return true;
      });
    }

    if (searchTerm.trim() !== '') {
      const lowerSearch = searchTerm.toLowerCase();
      result = result.filter(subject =>
        subject.name.toLowerCase().includes(lowerSearch) || 
        subject.code.toLowerCase().includes(lowerSearch)
      );
    }

    return result;
  }, [filters, searchTerm, subjects]);

  // Tematika megnyitása
  const openSyllabus = async (code) => {
    toast.info("Tematika generálása...", { autoClose: 2000 });

    try {
      const res = await fetch(`/api/ttr/tematika?code=${code}`);
      const data = await res.json();
      
      if (data.notFound) {
        toast.warning("Ehhez a tárgyhoz nem létezik tematika.");
        return;
      }
      
      if (data.isFallback) {
        toast.warning("Kérlek várj pár másodpercet!");
      } else {
        window.open(`${data.file}?t=${Date.now()}`, "_blank");
        toast.success("Tematika sikeresen generálva!");
      }
    } catch {
      toast.error("Hiba történt a generálás során.");
    }
  };

  return (
    <div className="subject-list">
      <h2>Tárgylista</h2>
      
      <input
        type="text"
        placeholder="Keresés..."
        value={searchTerm}
        onChange={e => setSearchTerm(e.target.value)}
        className="search-input"
      />

      {filteredSubjects.length === 0 ? (
        <p>Nincs találat</p>
      ) : (
        <ul>
          {filteredSubjects.map(subject => (
            <li
              key={subject.id}
              className="subject-card"
              draggable
              onDragStart={e => {
                e.dataTransfer.setData("subject", JSON.stringify(subject));
              }}
              style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}
            >
              <span>
                <strong>{subject.name}</strong> ({subject.code}) – {subject.credit} credit – {subject.recommended_semester}.félév
              </span>

              <button
                onClick={() => openSyllabus(subject.code)}
                aria-label={`Syllabus megnyitása: ${subject.name}`}
                title="Kattints a tematika megnyitásához"
                className="info-button"
                style={{
                  marginLeft: '10px', 
                  border: 'none', 
                  backgroundColor: '#007bff', 
                  color: 'white',
                  borderRadius: '50%', 
                  width: '20px', 
                  height: '20px', 
                  cursor: 'pointer',
                  display: 'flex', 
                  alignItems: 'center', 
                  justifyContent: 'center'
                }}
              >
                i
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}