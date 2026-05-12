import React, { useCallback } from "react";
import * as XLSX from "xlsx";
import { saveAs } from "file-saver";
import { toast } from "react-toastify";

const STUDENT_SHEET = "HallgatoiAdatok";
const ACCEPTED_SHEET = "ElfogadottTargyak";
const REQUIRED_SHEET = "ElőírtTargyak";

export default function ExcelManager({
  userData,
  acceptedSubjects,
  requiredSubjects,
  setUserData,
  setAcceptedSubjects,
  setRequiredSubjects,
}) {

  const handleExport = useCallback(() => {
    const f1 = userData?.field1?.toString() || "";
    const f2 = userData?.field2?.toString() || "";
    const f3 = userData?.field3?.toString() || "";

    if (!f1 || !f2 || !f3) {
      toast.warning("Először adja meg a hallgatói adatokat!");
      return;
    }

    if (f1.length > 200 || f2.length > 200 || f3.length > 200) {
      toast.error("Túl hosszú hallgatói adatok! (Max 200 karakter/mező)");
      return;
    }

    try {
      const workbook = XLSX.utils.book_new();

      // Hallgatói adatok
      const studentSheet = XLSX.utils.json_to_sheet([{
        "Intézmény neve": f1,
        "Szak megnevezése": f2,
        "Hallgató neve": f3
      }]);
      XLSX.utils.book_append_sheet(workbook, studentSheet, STUDENT_SHEET);

      // Elfogadott tárgyak
      const acceptedRows = acceptedSubjects.flatMap(group => 
        group.internalSubjects.map(sub => ({
          "Külső tantárgy név": group.externalNames.join(" | "),
          "Tantárgykód": sub.code,
          "Tantárgynév": sub.name,
          "Kredit": sub.credit,
          "Félév": sub.recommended_semester,
          "Kategória": sub.category,
          "Típus": sub.type
        }))
      );
      const acceptedSheet = XLSX.utils.json_to_sheet(acceptedRows);
      XLSX.utils.book_append_sheet(workbook, acceptedSheet, ACCEPTED_SHEET);

      // Előírt tárgyak
      const requiredRows = requiredSubjects.map(sub => ({
        "Tantárgykód": sub.code,
        "Tantárgynév": sub.name,
        "Kredit": sub.credit,
        "Félév": sub.recommended_semester,
        "Kategória": sub.category,
        "Típus": sub.type
      }));
      const requiredSheet = XLSX.utils.json_to_sheet(requiredRows);
      XLSX.utils.book_append_sheet(workbook, requiredSheet, REQUIRED_SHEET);

      // Írás és mentés
      const buffer = XLSX.write(workbook, { bookType: "xlsx", type: "array" });
      const blob = new Blob([buffer], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" });
      saveAs(blob, `Targy_Export_${Date.now()}.xlsx`);
      
      // Explicit memória felszabadítási segítés a GC-nek
      acceptedRows.length = 0;
      requiredRows.length = 0;
    } catch (error) {
      console.error("Export hiba:", error);
      toast.error("Hiba történt az Excel generálása közben.");
    }
  }, [userData, acceptedSubjects, requiredSubjects]);

  const handleImport = useCallback((e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (!file.name.endsWith(".xlsx")) {
      toast.error("Csak .xlsx fájl tölthető be!");
      return;
    }

    const reader = new FileReader();

    reader.onload = (evt) => {
      try {
        const data = new Uint8Array(evt.target.result);
        const workbook = XLSX.read(data, { type: "array" });

        if (!workbook.Sheets[STUDENT_SHEET] || !workbook.Sheets[ACCEPTED_SHEET] || !workbook.Sheets[REQUIRED_SHEET]) {
          throw new Error("Hiányzó munkalap(ok)!");
        }
        const studentJson = XLSX.utils.sheet_to_json(workbook.Sheets[STUDENT_SHEET]);
        if (!studentJson.length) throw new Error("Hiányzó hallgatói adatok!");
        // Hallgatói adatok
        const student = studentJson[0];
        setUserData({
          field1: student["Intézmény neve"]?.toString() || "",
          field2: student["Szak megnevezése"]?.toString() || "",
          field3: student["Hallgató neve"]?.toString() || ""
        });

        // Elfogadott tárgyak
        const acceptedJson = XLSX.utils.sheet_to_json(workbook.Sheets[ACCEPTED_SHEET]);
        const acceptedMap = new Map();

        acceptedJson.forEach(row => {
          const extName = row["Külső tantárgy név"];
          if (!extName || !row["Tantárgykód"]) return;

          if (!acceptedMap.has(extName)) {
            acceptedMap.set(extName, {
              id: `acc-${Date.now()}-${Math.random()}`,
              externalNames: extName.split(" | "),
              internalSubjects: []
            });
          }

          acceptedMap.get(extName).internalSubjects.push({
            code: row["Tantárgykód"]?.toString() || "",
            name: row["Tantárgynév"]?.toString() || "",
            credit: Number(row["Kredit"]) || 0,
            recommended_semester: row["Félév"],
            category: row["Kategória"],
            type: row["Típus"]
          });
        });
        setAcceptedSubjects(Array.from(acceptedMap.values()));

        // Előírt tárgyak
        const requiredJson = XLSX.utils.sheet_to_json(workbook.Sheets[REQUIRED_SHEET]);
        setRequiredSubjects(requiredJson.map(row => ({
          id: `req-${Date.now()}-${Math.random()}`,
          code: row["Tantárgykód"]?.toString() || "",
          name: row["Tantárgynév"]?.toString() || "",
          credit: Number(row["Kredit"]) || 0,
          recommended_semester: row["Félév"],
          category: row["Kategória"],
          type: row["Típus"]
        })));

        toast.success("Excel adatok sikeresen betöltve!");
      } catch (err) {
        console.error("Import hiba részletesen:", err);
        toast.error(`Import hiba: ${err.message}`);
      } finally {
        e.target.value = null;
      }
    };

    reader.readAsArrayBuffer(file);
  }, [setUserData, setAcceptedSubjects, setRequiredSubjects]);

  return (
    <div style={{ display: "flex", gap: "10px" }}>
      <button onClick={handleExport} className="them-button">
        Excel mentése
      </button>

      <label htmlFor="excel-upload" className="label-button" style={{ cursor: 'pointer' }}>
        Excel betöltése
      </label>

      <input
        id="excel-upload"
        type="file"
        accept=".xlsx"
        onChange={handleImport}
        style={{ display: "none" }}
      />
    </div>
  );
}