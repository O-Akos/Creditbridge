
/**
 * Segédfüggvény a jelszó erősségének ellenőrzésére.
 */
export const getPasswordError = (pwd) => {
  if (pwd.length < 8) return "A jelszónak legalább 8 karakter hosszúnak kell lennie.";
  if (!/[A-Z]/.test(pwd)) return "A jelszónak tartalmaznia kell legalább egy nagybetűt.";
  if (!/[a-z]/.test(pwd)) return "A jelszónak tartalmaznia kell legalább egy kisbetűt.";
  if (!/\d/.test(pwd)) return "A jelszónak tartalmaznia kell legalább egy számot.";
  if (!/[!@#$%^&*(),.?":{}|<>/]/.test(pwd)) return "A jelszónak tartalmaznia kell egy speciális karaktert.";
  if (pwd.length > 20) return "A jelszó nem lehet hosszabb 20 karakternél.";
  return null;
};

export const isEmailInvalid = (email) => !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);