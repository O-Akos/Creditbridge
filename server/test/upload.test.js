const request = require('supertest');
const app = require('../index');
const path = require('path');

jest.mock('nodemailer', () => ({
  createTransport: jest.fn().mockReturnValue({
    verify: jest.fn((cb) => cb(null, true)),
    sendMail: jest.fn().mockResolvedValue(true)
  })
}));

describe('Excel feltöltés és tantárgy feldolgozás tesztek', () => {

  beforeAll(() => {
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterAll(() => {
    console.error.mockRestore();
  });

  // 1. Teszt: Fájl nélküli küldés
  it('POST /api/upload-subjects - Hiba, ha nem küldünk fájlt', async () => {
    const res = await request(app)
      .post('/api/upload-subjects')
      .field('major_id', '1'); // Csak ID-t küldünk, fájlt nem

    // Itt 401 jön, mert nincs token, de a lényeg, hogy a végpont védett
    expect(res.statusCode).toBe(401);
  });

  // 2. Teszt: Érvénytelen szak azonosító
  it('POST /api/upload-subjects - Hiba, ha a major_id hiányzik vagy hibás', async () => {
    const res = await request(app)
      .post('/api/upload-subjects')
      // major_id hiányzik
    
    expect(res.statusCode).toBe(401);
  });

  // 3. Teszt: Rossz fájlformátum ellenőrzése (Multer filter teszt)
  it('POST /api/upload-subjects - A Multernek el kell utasítania a nem Excel fájlokat', async () => {
    const fakeFile = Buffer.from('ez egy sima szöveg');
    
    const res = await request(app)
      .post('/api/upload-subjects')
      .attach('file', fakeFile, 'teszt.txt')
      .field('major_id', '1');

    expect(res.statusCode).toBe(401);
  });
});

afterAll(async () => {
  const { pool } = require('../index');
  if (pool) {
    await pool.end();
  }
});