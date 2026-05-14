import React, { useEffect, useState, useMemo } from 'react';
import { useParams } from 'react-router-dom';

export default function CreditTable({ acceptedSubjects = [], requiredSubjects = [] }) {
  const { id: majorId } = useParams();
  const API_URL = process.env.REACT_APP_API_URL;
  const [categories, setCategories] = useState([]);
  const [thresholdPercent, setThresholdPercent] = useState(70);

  useEffect(() => {
    if (!majorId) return;
    const controller = new AbortController();

    async function fetchCategories() {
      try {
        const res = await fetch(`${API_URL}/api/majors/${majorId}/categories`, {
          signal: controller.signal 
        });
        if (res.ok) {
          const data = await res.json();
          const raw = data[0];
          
          if (raw.accepted_percentage) setThresholdPercent(raw.accepted_percentage);

          const parsed = raw.name.map((n, i) => ({
            name: n.trim(),
            max_credit: Number(raw.max_credit[i]) || 0,
          }));
          setCategories(parsed);
        }
      } catch (err) {
        if (err.name !== 'AbortError') console.error('Error:', err);
      }
    }

    fetchCategories();
    return () => controller.abort();
  }, [majorId, API_URL]);

  const stats = useMemo(() => {
    const flattenedAccepted = acceptedSubjects.flatMap(entry => entry.internalSubjects || []);
    
    const accTotals = {};
    const reqTotals = {};

    flattenedAccepted.forEach(subj => {
      const credits = Number(subj.credits || subj.credit || 0);
      accTotals[subj.type] = (accTotals[subj.type] || 0) + credits;
    });

    requiredSubjects.forEach(subj => {
      const credits = Number(subj.credits || subj.credit || 0);
      reqTotals[subj.type] = (reqTotals[subj.type] || 0) + credits;
    });

    let totalAccCapped = 0;
    let totalFinalSum = 0;

    categories.forEach(cat => {
      const acc = accTotals[cat.name] || 0;
      const req = reqTotals[cat.name] || 0;
      totalAccCapped += Math.min(acc, cat.max_credit);
      totalFinalSum += Math.min(acc + req, cat.max_credit);
    });

    const maxLimit = categories.reduce((sum, c) => sum + c.max_credit, 0);
    const thresholdValue = (maxLimit * thresholdPercent) / 100;

    return {
      categoryAccepted: accTotals,
      categoryRequired: reqTotals,
      totalAccOnly: totalAccCapped,
      totalFinal: totalFinalSum,
      maxCredit: maxLimit,
      thresholdValue
    };
  }, [acceptedSubjects, requiredSubjects, categories, thresholdPercent]);
  const isYellow = stats.totalAccOnly >= stats.thresholdValue && stats.maxCredit > 0;
  const isGreen = isYellow && stats.totalFinal >= stats.maxCredit && stats.maxCredit > 0;
  const totalColorClass = isGreen ? "green-row" : (isYellow ? "yellow-row" : "");

  return (
    <div className="credit-table">
      <h2>Kredit tábla</h2>
      <table>
        <thead>
          <tr>
            <th>Kategória</th>
            <th>Elfogadott</th>
            <th>Előírt</th>
            <th>Max</th>
          </tr>
        </thead>
        <tbody>
          {categories.map((category) => {
            const acc = stats.categoryAccepted[category.name] || 0;
            const req = stats.categoryRequired[category.name] || 0;
            const total = acc + req;
            const overMax = total >= category.max_credit;

            return (
              <tr key={category.name} className={overMax ? "green-row" : ""}>
                <td>{category.name}</td>
                <td>{acc}</td>
                <td>{req}</td>
                <td>
                  {Math.min(total, category.max_credit)}/{category.max_credit}
                </td>
              </tr>
            );
          })}
          <tr className={`total-row ${totalColorClass}`}>
            <td colSpan="3">Összes kredit</td>
            <td>
              {stats.totalFinal}/{stats.maxCredit}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}