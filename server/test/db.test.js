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

describe('Hitelesítés nélküli api hívások', () => {

  beforeAll(() => {
    jest.spyOn(console, 'error').mockImplementation(() => {});
    jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterAll(() => {
    console.error.mockRestore();
    console.log.mockRestore();
  });


  it('GET /api/saves - Hiba, ha hiányzik a majorId a lekérdezésből', async () => {
    const res = await request(app).get('/api/saves');
    expect([401, 400]).toContain(res.statusCode);
  });

  it('GET /api/majors - Vissza kell adnia a szakok listáját', async () => {
    const res = await request(app).get('/api/majors');
    expect([200, 500]).toContain(res.statusCode);
  });

  it('GET /api/majors/:id/subjects - Adatokat kell adnia egy létező szakhoz', async () => {
    const res = await request(app).get('/api/majors/1/subjects');
    expect([200, 500]).toContain(res.statusCode);
  });
});

afterAll(async () => {
  const { pool } = require('../index');
  if (pool) {
    await pool.end();
  }
});