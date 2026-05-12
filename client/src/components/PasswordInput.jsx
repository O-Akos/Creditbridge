import React, { useState } from 'react';

/**
 * Jelszó input mező
 */
export default function PasswordInput({ name, value, onChange, placeholder }) {
  const [show, setShow] = useState(false);
  return (
    <div className="password-input-wrapper">
      <input
        type={show ? 'text' : 'password'}
        name={name}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        maxLength={20}
      />
      <span className="password-toggle" style={{cursor: 'pointer'}} onClick={() => setShow(!show)}>
        {show ? '👁️' : '🔒'}
      </span>
    </div>
  );
}