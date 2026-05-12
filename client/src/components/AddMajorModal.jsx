import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import "./AddMajorModal.css";
import { useAuth } from "./AuthContext";
import * as XLSX from "xlsx"; 

const AddMajorModal = ({ show, onClose, refreshMajors, majorToEdit: initialMajorToEdit, authUser }) => {
  const [currentMajor, setCurrentMajor] = useState(null);
  const [majorName, setMajorName] = useState("");
  const [syllabus_year, setsyllabus_year] = useState([""]);
  const [type, settype] = useState([""]);
  const [maxCredit, setMaxCredit] = useState([""]);
  const [category, setCategory] = useState([""]);
  const [excelFile, setExcelFile] = useState(null);
  const [uploading, setUploading] = useState(false);
  const [acceptedPercentage, setAcceptedPercentage] = useState(70);
  const { authFetch } = useAuth();
  const API_URL = process.env.REACT_APP_API_URL

  const MAX_MAJOR_NAME = 100;
  const MAX_CREDIT_VALUE = 200;

 useEffect(() => {
    if (show) {
      setCurrentMajor(initialMajorToEdit);
      if (initialMajorToEdit) {
        setMajorName(initialMajorToEdit.major_name || "");
        setsyllabus_year((initialMajorToEdit.syllabus_year?.length > 0) ? initialMajorToEdit.syllabus_year.map(String) : [""]);
        settype((initialMajorToEdit.type?.length > 0) ? initialMajorToEdit.type : [""]);
        setMaxCredit((initialMajorToEdit.max_credit?.length > 0) ? initialMajorToEdit.max_credit.map(String) : [""]);
        setCategory((initialMajorToEdit.category?.length > 0) ? initialMajorToEdit.category : [""]);
        setAcceptedPercentage(initialMajorToEdit.accepted_percentage ?? 100);
      } else {
        setMajorName("");
        setsyllabus_year([""]);
        settype([""]);
        setMaxCredit([""]);
        setCategory([""]);
        setExcelFile(null);
        setAcceptedPercentage(75);
      }
      return () => {
    if (!show) {
      setExcelFile(null);
    }
  };
    }
  }, [show, initialMajorToEdit]);

  const handleFileChange = (e) => {
    if (!authUser) {
      toast.error("Bejelentkezés szükséges a fájlkezeléshez!");
      return;
    }

    const file = e.target.files[0];
    
    if (file) {
      const fileExtension = file.name.split('.').pop().toLowerCase();
      if (fileExtension !== 'xlsx' && fileExtension !== 'xls') {
        toast.error("Hiba: Csak .xlsx vagy .xls formátumú Excel fájlt tölthetsz fel!");
        e.target.value = ""; 
        setExcelFile(null);
        return;
      }
    }

    setExcelFile(file);

    if (file) {
      const reader = new FileReader();
      reader.onload = (evt) => {
        try {
          const bstr = evt.target.result;
          const wb = XLSX.read(bstr, { type: "binary" });
          const ws = wb.Sheets[wb.SheetNames[0]];
          const data = XLSX.utils.sheet_to_json(ws);

          if (data.length === 0) {
            toast.warning("A fájl üres!");
            return;
          }

          const requiredHeaders = ['code', 'name', 'credit', 'recommended_semester', 'syllabus_year', 'category', 'type'];
          const firstRow = data[0];
          const fileHeaders = Object.keys(firstRow);
          const isValidHeader = requiredHeaders.every(header => fileHeaders.includes(header));

          if (!isValidHeader) {
            toast.error("Hiba: Érvénytelen táblázat szerkezet! Várt oszlopok: " + requiredHeaders.join(", "));
            setExcelFile(null);
            e.target.value = ""; 
            return;
          }

          for (let i = 0; i < data.length; i++) {
            const row = data[i];
            const rowNum = i + 2;

            if (String(row.code || "").length > 20) throw new Error(`${rowNum}. sor: A kód túl hosszú (max 20)!`);
            if (String(row.name || "").length > 100) throw new Error(`${rowNum}. sor: A név túl hosszú (max 100)!`);
            
            const cred = Number(row.credit);
            if (isNaN(cred) || cred < 0 || cred > 36) throw new Error(`${rowNum}. sor: Érvénytelen kredit (0-36)!`);
            
            if (String(row.type || "").length > 50) throw new Error(`${rowNum}. sor: A csoport neve túl hosszú (max 50)!`);
          }

          const excelYears = data.map(item => String(item.syllabus_year)).filter(Boolean);
          const currentYears = syllabus_year.filter(y => y !== "");
          const combinedYears = [...new Set([...currentYears, ...excelYears])]
            .sort((a, b) => Number(a) - Number(b));
          
          setsyllabus_year(combinedYears.length > 0 ? combinedYears : [""]);

          const excelCategories = data.map(item => String(item.category || "").trim()).filter(Boolean);
          const currentCategories = category.filter(c => c !== "");
          const combinedCategories = [...new Set([...currentCategories, ...excelCategories])];

          setCategory(combinedCategories.length > 0 ? combinedCategories : [""]);

          const excelTypes = [...new Set(data.map(item => String(item.type || "").trim()))].filter(Boolean);
          const currentTypes = type.filter(t => t && t.trim() !== "");
          const combinedTypes = [...new Set([...currentTypes, ...excelTypes])];

          const updatedCredits = combinedTypes.map((tName) => {
            const idx = type.indexOf(tName);
            // Ha már létezett a csoport, megtartjuk a kreditet, különben 0
            return (idx !== -1 && maxCredit[idx]) ? maxCredit[idx] : "0";
          });

          settype(combinedTypes);
          setMaxCredit(updatedCredits);
          toast.info("Excel fájl sikeresen beolvasva és validálva.");
        } catch (err) {
          toast.error("Validációs hiba: " + err.message);
          setExcelFile(null);
          e.target.value = ""; 
        }
      };
      reader.readAsBinaryString(file);
    }
  };

  const handleUpload = async () => {
    if (!authUser) return toast.error("Bejelentkezés szükséges!");
    if (!excelFile || !currentMajor) return toast.warning("Mentsd el a szakot feltöltés előtt!");
    
    setUploading(true);
    const formData = new FormData();
    formData.append("file", excelFile);
    formData.append("major_id", currentMajor.id);

    try {
      // JAVÍTVA: API_URL használata
      const res = await authFetch(`${API_URL}/api/upload-subjects`, { 
        method: "POST", 
        body: formData,
        credentials: "include" 
      });
      
      const data = await res.json();
      if (res.ok) {
        toast.success(data.message || "Tantárgyak sikeresen feltöltve!");
        setExcelFile(null);
        // Frissítjük a főoldalt is, ha kell
        refreshMajors();
      } else {
        toast.error(data.error || "Hiba a feltöltés során.");
      }
    } catch (err) {
      toast.error("Hálózati hiba!");
    } finally { setUploading(false); }
  };

  const handleSave = async () => {
    if (!authUser) return toast.error("Bejelentkezés szükséges a mentéshez!");
    if (!majorName.trim()) return toast.warning("Szak név kötelező!")
    if (majorName.length > MAX_MAJOR_NAME) return toast.warning(`A szak neve max ${MAX_MAJOR_NAME} karakter lehet!`);

    const perc = Number(acceptedPercentage);
    if (isNaN(perc) || perc < 0 || perc > 100) {
      return toast.error("Az elfogadási küszöbnek 0 és 100 között kell lennie!");
    }

    const validYears = syllabus_year.filter(y => y !== "");
    for (let year of validYears) {
      if (!/^\d{4}$/.test(year)) {
        return toast.error(`Érvénytelen év: ${year}. Az évnek 4 számjegyből kell állnia!`);
      }
    }

    const validCredits = maxCredit.filter(c => c !== "");
    for (let credit of validCredits) {
      const num = Number(credit);
      if (isNaN(num) || num < 0 || num > MAX_CREDIT_VALUE) {
        return toast.error(`Kredit hiba: ${credit}. Számnak kell lennie 0 és ${MAX_CREDIT_VALUE} között!`);
      }
    }

    const majorData = {
      major_name: majorName.trim(),
      syllabus_year: syllabus_year.filter(y => y !== "").map(Number),
      category: category.filter(c => c !== ""),
      type: type.filter(t => t !== ""),
      max_credit: maxCredit.filter(c => c !== "").map(Number),
      accepted_percentage: perc
    };

    try {
      const url = currentMajor ? `${API_URL}/api/majors/${currentMajor.id}` : `${API_URL}/api/majors`;
      const res = await authFetch(url, {
        method: currentMajor ? "PUT" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(majorData),
        credentials: "include"
      });

      const data = await res.json();

      if (res.ok) {
        toast.success(currentMajor ? "Szak sikeresen frissítve!" : "Új szak sikeresen hozzáadva!");
        if (!currentMajor) {
            setCurrentMajor(data);
        }
        refreshMajors();
      } else {
        toast.error(data.error || data.message || "Hiba történt a mentés során.");
      }
    } catch (err) {
      toast.error("Hálózati hiba! Nem sikerült elérni a szervert.");
    }
  };

const handleDelete = async () => {
  if (!authUser || authUser.role !== 'admin') {
    toast.error("Nincs jogosultságod a törléshez!");
    return;
  }
  const confirmName = prompt(
    `FIGYELEM: A törlés végleges! \n\nA szak törléséhez írd be a nevét pontosan: \n"${currentMajor.major_name}"`
  );

  if (confirmName === null) return;

  if (confirmName.length > 100) {
    toast.error("Hiba: A beírt név túl hosszú (max 100 karakter)!");
    return;
  }

  if (confirmName !== currentMajor.major_name) {
    toast.error("A beírt név nem egyezik. Törlés megszakítva.");
    return;
  }

  const loadingToast = toast.loading("Szak törlése folyamatban...");

  try {
    const res = await authFetch(`${process.env.REACT_APP_API_URL}/api/majors/${currentMajor.id}`, {
      method: "DELETE",
      headers: { 
        "Content-Type": "application/json" 
      },
      credentials: "include"
    });

    toast.dismiss(loadingToast);

    if (res.ok) {
      toast.success("Szak sikeresen törölve!");
      refreshMajors(); 
      onClose();       
    } else {
      const errorData = await res.json();
      toast.error(errorData.message || "Nem sikerült a törlés.");
    }
  } catch (err) {
    toast.dismiss(loadingToast);
    console.error("Hiba a törlésnél:", err);
    toast.error("Hálózati hiba történt a törlés során.");
  }
};
  const downloadTemplate = () => {
    const headers = [
      ['code', 'name', 'credit', 'recommended_semester', 'syllabus_year', 'category', 'type']
    ];

    const exampleData = [
      ['GKNB_INTM114', 'Programozás', '5', '2', '2024', 'Számítástechnikai és programozási ismeretek', 'Kötelező']
    ];

    const worksheet = XLSX.utils.aoa_to_sheet([...headers, ...exampleData]);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "Template");
    XLSX.writeFile(workbook, "tantargy_feltolto_sablon.xlsx");
  };

  if (!show) return null;

  return (
    <div className="modal-backdrop">
      <div className="modal-container">
        <h2>{currentMajor ? "Szak szerkesztése" : "Új szak hozzáadása"}</h2>

        <div className="modal-section">
          <label>Szak neve ({majorName.length}/{MAX_MAJOR_NAME}):</label>
          <input 
            type="text" 
            value={majorName} 
            maxLength={MAX_MAJOR_NAME}
            onChange={(e) => setMajorName(e.target.value)} 
            disabled={!authUser} 
          />
        </div>

        <div className="modal-section excel-box">
          <label><strong>Excel importálás:</strong></label>
          <button 
            type="button" 
            className="template-btn" 
            onClick={downloadTemplate}
            style={{ marginBottom: "10px", display: "block", fontSize: "12px" }}
          >
            Sablon letöltése (.xlsx)
          </button>
          <input 
            type="file" 
            accept=".xlsx,.xls" 
            onChange={handleFileChange} 
            disabled={!authUser} 
          />
          
          <button 
            className="upload-btn" 
            onClick={handleUpload} 
            disabled={uploading || !excelFile || !currentMajor || !authUser}
            title={!authUser ? "Bejelentkezés szükséges!" : (!currentMajor ? "Mentsd el a szakot a névvel!" : "")}
          >
            {uploading ? "Feltöltés..." : "Tantárgyak frissítése"}
          </button>

          {!currentMajor && excelFile && (
            <p style={{ color: "orange", fontSize: "12px", marginTop: "5px" }}>
              Előbb mentsd el az új szakot a Mentés gombbal!
            </p>
          )}
          {!authUser && (
             <p style={{ color: "red", fontSize: "12px", marginTop: "5px" }}>
              A módosításhoz be kell jelentkezned!
           </p>
          )}
        </div>

        <div className="modal-section">
          <label>Évek (pl. 2024):</label>
          {syllabus_year.map((y, i) => (
            <div key={i} className="inline-row">
              <input 
                type="text" 
                placeholder="ÉÉÉÉ" 
                value={y} 
                onChange={(e) => {
                  const u = [...syllabus_year]; u[i] = e.target.value; setsyllabus_year(u);
                }} 
                disabled={!authUser}
              />
              <button 
                className="remove-btn" 
                onClick={() => setsyllabus_year(syllabus_year.filter((_, idx) => idx !== i))}
                disabled={!authUser}
                
              > -
              </button>
            </div>
          ))}
          <button 
            className="add-btn" 
            onClick={() => setsyllabus_year([...syllabus_year, ""])}
            disabled={!authUser}
          >
            + Év
          </button>
        </div>
        <label>Alapértelmezett elfogadási küszöb (%):</label>
  <div className="inline-row" style={{ width: '150px' }}>
    <input 
      type="number" 
      min="0" 
      max="100"
      value={acceptedPercentage} 
      onChange={(e) => setAcceptedPercentage(e.target.value)} 
      disabled={!authUser} 
    />
    <span style={{ marginLeft: "5px" }}>%</span>
  </div>

          <div className="modal-section">
  <label>Tantárgy kategóriák (pl. Számítástechnika):</label>
  {category.map((cat, i) => (
    <div key={i} className="inline-row">
      <input 
        type="text" 
        placeholder="Kategória neve" 
        value={cat} 
        onChange={(e) => {
          const u = [...category]; u[i] = e.target.value; setCategory(u);
        }} 
        disabled={!authUser} 
      />
      <button 
        className="remove-btn" 
        onClick={() => setCategory(category.filter((_, idx) => idx !== i))}
        disabled={!authUser}
      > - </button>
    </div>
  ))}
  <button 
    className="add-btn" 
    onClick={() => setCategory([...category, ""])}
    disabled={!authUser}
  >
    + Kategória
  </button>
</div>
        <div className="modal-section">
          <label>Tantárgy csoportok és kreditek (max {MAX_CREDIT_VALUE}):</label>
          {type.map((t, i) => (
            <div key={i} className="inline-row">
              <input 
                type="text" 
                placeholder="Név" 
                value={t} 
                onChange={(e) => {
                  const u = [...type]; u[i] = e.target.value; settype(u);
                }} 
                disabled={!authUser}
              />
              <input 
                type="number" 
                placeholder="Kredit" 
                value={maxCredit[i]} 
                onChange={(e) => {
                  const u = [...maxCredit]; u[i] = e.target.value; setMaxCredit(u);
                }} 
                disabled={!authUser}
              />
              <button 
                className="remove-btn" 
                onClick={() => {
                  settype(type.filter((_, idx) => idx !== i));
                  setMaxCredit(maxCredit.filter((_, idx) => idx !== i));
                }}
                disabled={!authUser}
              >
                -
              </button>
            </div>
          ))}
          <button 
            className="add-btn" 
            onClick={() => { settype([...type, ""]); setMaxCredit([...maxCredit, ""]); }}
            disabled={!authUser}
          >
            + Csoport
          </button>
        </div>

        <div className="button-row">
          <button 
            className="save-btn" 
            onClick={handleSave} 
            disabled={!authUser}
          >
            Mentés
          </button>
          {currentMajor && (
  <button 
    className="delete-btn" 
    onClick={handleDelete} 
    disabled={!authUser || authUser.role !== 'admin'} 
    title={(!authUser || authUser.role !== 'admin') ? "Csak adminisztrátor törölhet szakot!" : ""}
  >
    Törlés
  </button>
)}
          <button className="close-btn" onClick={onClose}>Bezárás</button>
        </div>
      </div>
    </div>
  );
};

export default AddMajorModal;