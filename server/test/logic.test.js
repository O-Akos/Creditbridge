const app = require('../index'); 

jest.mock('nodemailer', () => ({
  createTransport: jest.fn().mockReturnValue({
    verify: jest.fn((cb) => cb(null, true)),
    sendMail: jest.fn().mockResolvedValue(true)
  })
}));
describe('Regisztrációs logika tesztelése', () => {
  
  it('Jelszó validátornak el kell fogadnia az erős jelszót', () => {
    const strongPwd = "Password123!";
    const hasUpper = /[A-Z]/.test(strongPwd);
    const hasNumber = /\d/.test(strongPwd);
    expect(hasUpper && hasNumber).toBe(true);
  });

  it('Email validátornak el kell utasítania a rossz formátumot', () => {
    const badEmail = "rosszemail.hu";   
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    expect(emailRegex.test(badEmail)).toBe(false);
  });
});


describe('Unit Tesztek - Üzleti logika validálása', () => {
  
  // 1. Jelszó teszt (Regisztrációhoz)
  it('Jelszó validátornak el kell fogadnia az erős jelszót', () => {
    const strongPwd = "Password123!";
    const hasUpper = /[A-Z]/.test(strongPwd);
    const hasLower = /[a-z]/.test(strongPwd);
    const hasNumber = /\d/.test(strongPwd);
    const isLongEnough = strongPwd.length >= 8;
    
    expect(hasUpper && hasLower && hasNumber && isLongEnough).toBe(true);
  });

  // 2. Email teszt (Input validációhoz)
  it('Email validátornak el kell utasítania a rossz formátumot', () => {
    const badEmail = "rosszemail.hu";
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    expect(emailRegex.test(badEmail)).toBe(false);
  });

  // 3. Kredit korlát teszt (Tantárgy feltöltéshez)
  it('Kreditértéknek 0 és 30 között kell lennie', () => {
    const validateCredit = (c) => c >= 0 && c <= 30;
    
    expect(validateCredit(5)).toBe(true);
    expect(validateCredit(0)).toBe(true);
    expect(validateCredit(35)).toBe(false);
    expect(validateCredit(-2)).toBe(false);
  });

  // 4. Szemeszter határérték teszt
  it('Szemeszter számának reális tartományban kell lennie (1-14)', () => {
    const validateSemester = (s) => s >= 1 && s <= 14;
    
    expect(validateSemester(1)).toBe(true);
    expect(validateSemester(7)).toBe(true);
    expect(validateSemester(0)).toBe(false);
    expect(validateSemester(15)).toBe(false);
  });
});

afterAll(async () => {
  const { pool } = require('../index');
  if (pool) {
    await pool.end();
  }
});

afterAll(async () => {
  const { pool } = require('../index');
  if (pool) {
    await pool.end();
  }
});