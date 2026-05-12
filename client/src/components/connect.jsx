import React, { useState } from 'react';
import FilterPanel from './FilterPanel';
import SubjectList from './SubjectList';

/**
 * MajorPage komponens: 
 * Ez a komponens szolgál "hídként" a szűrőpanel és a tárgylista között.
 * Itt tároljuk a szűrési feltételeket, amiket mindkét alkomponens elér.
 */
export default function MajorPage() {
  // Állapot (state) a kiválasztott szűrők tárolására.
  // Az objektum kulcsai a szűrő típusát és értékét tárolják (pl. "Év:2024").
  const [filters, setFilters] = useState({});

  return (
    <div>
      {/* A szűrőpanel megkapja a jelenlegi szűrőket és a funkciót, 
           amivel módosítani tudja azokat a checkboxok alapján. 
      */}
      <FilterPanel filters={filters} setFilters={setFilters} />

      {/* A tárgylista megkapja a szűrőket, hogy a szerver felé 
          már csak a kért feltételeknek megfelelő tárgyakat jelenítse meg. 
      */}
      <SubjectList filters={filters} />
    </div>
  );
}