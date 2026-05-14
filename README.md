# MSc-felvételi kreditátvitel adminisztratív támogatása

Ez a webalkalmazás a BSc diplomával rendelkező hallgatók mesterképzésre (MSc) történő jelentkezésének adminisztrációját, valamint az ezzel járó kreditátviteli eljárást támogatja.

## Projekt célkitűzése
A rendszer célja, hogy vizuálisan és interaktív módon segítse a kreditátviteli folyamatot a hallgatók és az adminisztrátorok számára. Az alkalmazás modern technológiákra épül, biztosítva a gyors és pontos döntéstámogatást.

## Főbb funkciók
*   **Dinamikus szűrés:** Adatbázis-alapú, valós idejű keresési mechanizmus a tantárgyakhoz.
*   **Interaktív kredittábla:** Vizuális felület a tantárgyak összevetéséhez és elfogadásához.
*   **Döntéstámogató rendszer:** Tantárgy-elfogadó és előíró modul az adminisztratív bírálathoz.
*   **Összesítő kimutatások:** Automatikusan generált listák az elfogadott és előírt tárgyakról.
*   **Szakspecifikus navigáció:** Intuitív választási lehetőség a különböző szakok között.
*   **Excel Import és Export:** Munka állapot mentése `.xlsx` fájlba és annak későbbi visszatöltése.
*   **Fiókezelés:** A felhasználó regisztrálhat majd bejelentkezhet ezzel új funciókat elérve.
*   **Munka mentése adatbázisba:** A regisztrált és e-mail címét megerősített felhasználó munkaállapot mentése.
*   **Egyesített lista színezése:** A regisztrált és e-mail címét megerősített felhasználó preferált listaszíneinek beállítása.
*   **Szak létrehozás/Szerkesztés:** A regisztrált és e-mail címét megerősített felhasználó szakokat hozhat létre és azokat szerkesztheti is, a létrehozott szakok minden felhasználónak látható.


## Technológiai stekk (Tech Stack)
- **Frontend:** React.js
- **Backend:** Node.js (Express)
- **Adatbázis:** PostgreSQL
- **Infrastruktúra:** Docker & Docker Compose
- **Hitelesítés:** JWT (JSON Web Token) & biztonságos cookie-kezelés

## Telepítés és futtatás (Docker)

A projekt futtatásához Docker és Docker Compose szükséges.

1. **Repozitórium klónozása:**
   ```bash
<<<<<<< HEAD
   git clone [https://github.com/O-Akos/Creditbridge](https://github.com/O-Akos/Creditbridge)
=======
   git clone https://github.com/O-Akos/Creditbridge
>>>>>>> develop
   cd Creditbridge

2. **Környezeti változók:**
    Másolja le a mintafájlt .env néven, és szükség esetén módosítsa az értékeket:
    ```bash
    cp .env.example .env

3. **Indítás:**
    ```bash
    docker compose up --build

Az alkalmazás az alábbi portokon érhető el:
- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:5000
- **MailHog (Email teszt):** http://localhost:8025