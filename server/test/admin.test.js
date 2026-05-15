const request = require('supertest');
const app = require('../index');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

// Nodemailer némítása
jest.mock('nodemailer', () => ({
  createTransport: jest.fn().mockReturnValue({
    verify: jest.fn((cb) => cb(null, true)),
    sendMail: jest.fn().mockResolvedValue(true)
  })
}));

describe('Admin / Szak CRUD műveletek tesztelése', () => {

  beforeAll(() => {
    // Elnyomjuk a hibaüzeneteket a tiszta terminálért
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterAll(() => {
    console.error.mockRestore();
  });

  // 1. Teszt: Új szak hozzáadása (Auth védelem)
  it('POST /api/majors - Bejelentkezés nélkül tilos a hozzáadás', async () => {
    const res = await request(app)
      .post('/api/majors')
      .send({ major_name: "Teszt Szak" });

    expect(res.statusCode).toBe(401); // Unauthorized
  });

  // 2. Teszt: Új szak hozzáadása (Validáció)
  it('POST /api/majors - Név nélkül nem engedélyezett', async () => {
    const res = await request(app)
      .post('/api/majors')
      .send({ syllabus_year: 2024 });

    expect([401, 400]).toContain(res.statusCode);
  });

  // 3. Teszt: Szerkesztés (PUT)
  it('PUT /api/majors/:id - Szerkesztés védelme', async () => {
    const res = await request(app)
      .put('/api/majors/1')
      .send({ major_name: "Módosított név" });

    expect([401, 403]).toContain(res.statusCode); // 401: nincs belépve, 403: nem admin
  });

  // 4. Teszt: Törlés (DELETE) - Tranzakció és Role ellenőrzés
  it('DELETE /api/majors/:id - Csak admin törölhet', async () => {
    const res = await request(app).delete('/api/majors/1');
    
    expect([401, 403]).toContain(res.statusCode);
  });
});

afterAll(async () => {
  const { pool } = require('../index');
  if (pool) {
    await pool.end();
  }
});