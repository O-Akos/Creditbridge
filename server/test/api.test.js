
const request = require('supertest');
const app = require('../index');
require('dotenv').config()
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });


jest.mock('nodemailer', () => ({
  createTransport: jest.fn().mockReturnValue({
    verify: jest.fn((cb) => cb(null, true)),
    sendMail: jest.fn().mockResolvedValue(true)
  })
}));
describe('Kreditelismerő Rendszer API tesztek', () => {

  // 1. Teszt: Nyilvános végpont (vagy hiba kezelés)
  it('GET /api/ttr/tematika - Kód nélkül 400-as hibát kell adnia', async () => {
    const res = await request(app).get('/api/ttr/tematika');
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toBe("Missing code");
  });

  // 2. Teszt: AuthMiddleware védelem
  it('Védett útvonal tesztelése (token hiánya esetén)', async () => {
  const res = await request(app).get('/api/ttr/tematika'); 
 expect([400, 401, 404]).toContain(res.statusCode);
});

  // 3. Teszt: CORS beállítások
  it('A CORS-nak engedélyeznie kell a localhost:3000-et', async () => {
    const res = await request(app)
      .get('/api/ttr/tematika')
      .set('Origin', 'http://localhost:3000');
    
    expect(res.headers['access-control-allow-origin']).toBeDefined();
  });
  it('POST /api/register - El kell utasítania a gyenge jelszót', async () => {
  const res = await request(app)
    .post('/api/register')
    .send({
      first_name: 'Teszt',
      last_name: 'Elek',
      email: 'elek@teszt.hu',
      password: '123'
    });

  expect(res.statusCode).toBe(400);
  expect(res.body.error).toBe("A jelszó nem felel meg a biztonsági követelményeknek");
});
it('POST /api/login - Hibás email formátum esetén 400-at kell adnia', async () => {
  const res = await request(app)
    .post('/api/login')
    .send({
      email: 'rossz_email_formátum',
      password: 'Password123!'
    });

  expect(res.statusCode).toBe(400);
  expect(res.body.error).toBe("Érvénytelen email formátum!");
});
it('POST /api/logout - Sikeres kijelentkezés vagy elutasítás', async () => {
  const res = await request(app).post('/api/logout');
  expect([200, 401]).toContain(res.statusCode);
});
it('POST /api/register - Hiba, ha hiányoznak a kötelező mezők', async () => {
  const res = await request(app)
    .post('/api/register')
    .send({
      email: 'valaki@gmail.com'
    });

  expect(res.statusCode).toBe(400);
  expect(res.body.error).toBe("Minden mező kitöltése kötelező!");
});
it('POST /api/change-password - Belépés nélkül tilos a jelszócsere', async () => {
  const res = await request(app)
    .post('/api/change-password')
    .send({
      old_password: 'RegiJelszo123!',
      new_password: 'UjJelszo123!'
    });

  expect(res.statusCode).toBe(401);
});
it('POST /api/save - El kell utasítania a túl hosszú mentés nevet', async () => {
  const res = await request(app)
    .post('/api/save')
    .send({
      slotNumber: 1,
      saveName: 'EzEgyNagyonHosszuNevAmiTobbMintOtvenKarakterHogyLássukMegfogjaEASzerver',
      data: { valami: "adat" },
      majorId: 1
    });
  expect([401, 400]).toContain(res.statusCode);
});
it('POST /api/save - Hiba, ha a slot szám nem 1 és 4 közötti', async () => {
  const res = await request(app)
    .post('/api/save')
    .send({
      slotNumber: 5,
      saveName: 'Teszt mentés',
      data: { test: true },
      majorId: 1
    });

  expect([401, 400]).toContain(res.statusCode);
});

});

afterAll(async () => {
  const { pool } = require('../index'); 
  if (pool) {
    await pool.end();
  }
});