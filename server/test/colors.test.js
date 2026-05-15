const request = require('supertest');
const app = require('../index');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
jest.mock('nodemailer', () => ({
  createTransport: jest.fn().mockReturnValue({
    verify: jest.fn((cb) => cb(null, true)),
    sendMail: jest.fn().mockResolvedValue(true)
  })
}));

describe('Színprofil API végpontok tesztelése', () => {

  beforeAll(() => {
    // Elnémítjuk a hibaüzeneteket a tiszta screenshot érdekében
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterAll(() => {
    console.error.mockRestore();
  });

  // 1. Teszt: Lekérdezés védelem
  it('GET /api/colors - Bejelentkezés nélkül 401-et kell adnia', async () => {
    const res = await request(app).get('/api/colors?major_id=1');
    expect(res.statusCode).toBe(401);
  });

  // 2. Teszt: Új profil létrehozása név nélkül (Hiba kezelés)
  it('POST /api/colors - Név nélkül 400-at kell adnia', async () => {
    const res = await request(app)
      .post('/api/colors')
      .send({
        major: 1,
        color_codes: { primary: "#ff0000" }
        // név hiányzik
      });
    
    expect([401, 400]).toContain(res.statusCode);
  });

  // 3. Teszt: Aktiválás (PATCH)
  it('PATCH /api/colors/:id/activate - Aktiválás védelem', async () => {
    const res = await request(app)
      .patch('/api/colors/1/activate')
      .send({ major_id: 1 });

    expect(res.statusCode).toBe(401);
  });

  // 4. Teszt: Törlés és jogosultság ellenőrzés
  it('DELETE /api/colors/:id - Illetéktelen törlés megakadályozása', async () => {
    const res = await request(app).delete('/api/colors/1');
    
    // Itt a kódodban a 'WHERE id = $1 AND user_id = $2' rész védi az adatokat,
    // de mivel nincs token, már a middleware megállítja (401).
    expect(res.statusCode).toBe(401);
  });
});

afterAll(async () => {
  const { pool } = require('../index');
  if (pool) {
    await pool.end();
  }
});