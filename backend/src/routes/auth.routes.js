const express = require('express');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { generateToken } = require('../middleware/auth');

const router = express.Router();

// ─── POST /api/auth/login ─────────────────────────────────────────────────────
// Body: { email, password, role: "doctor"|"receptionist"|"patient" }
router.post('/login', async (req, res) => {
  const { email, password, role } = req.body;
  if (!email || !password || !role) {
    return res.status(400).json({ error: 'email, password and role are required' });
  }

  const tableMap = { doctor: 'doctors', receptionist: 'receptionists', patient: 'patients' };
  const table = tableMap[role];
  if (!table) return res.status(400).json({ error: 'Invalid role' });

  try {
    const { rows } = await db.query(`SELECT * FROM ${table} WHERE email = $1`, [email]);
    if (!rows.length) return res.status(401).json({ error: 'Invalid credentials' });

    const user = rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Invalid credentials' });

    const token = generateToken({ id: user.id, role, email: user.email });

    // Build clean profile (exclude password_hash)
    const { password_hash, ...profile } = user;
    return res.json({ token, role, user: profile });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/auth/signup/doctor ─────────────────────────────────────────────
router.post('/signup/doctor', async (req, res) => {
  const { first_name, last_name, email, password, phone, specialty, license } = req.body;
  if (!first_name || !last_name || !email || !password) {
    return res.status(400).json({ error: 'first_name, last_name, email, password are required' });
  }

  try {
    const exists = await db.query('SELECT id FROM doctors WHERE email = $1', [email]);
    if (exists.rows.length) return res.status(409).json({ error: 'Email already registered' });

    const password_hash = await bcrypt.hash(password, 10);
    const id = uuidv4();
    const { rows } = await db.query(
      `INSERT INTO doctors (id, first_name, last_name, email, password_hash, phone, specialty, license)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
       RETURNING id, first_name, last_name, email, phone, specialty, license, created_at`,
      [id, first_name, last_name, email, password_hash, phone, specialty, license]
    );

    const token = generateToken({ id, role: 'doctor', email });
    return res.status(201).json({ token, role: 'doctor', user: rows[0] });
  } catch (err) {
    console.error('Doctor signup error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/auth/signup/receptionist ──────────────────────────────────────
router.post('/signup/receptionist', async (req, res) => {
  const { first_name, last_name, email, password, phone, employee_id, shift, department, doctor_id } = req.body;
  if (!first_name || !last_name || !email || !password || !doctor_id) {
    return res.status(400).json({ error: 'first_name, last_name, email, password, doctor_id are required' });
  }

  try {
    const exists = await db.query('SELECT id FROM receptionists WHERE email = $1', [email]);
    if (exists.rows.length) return res.status(409).json({ error: 'Email already registered' });

    // Verify doctor exists
    const docCheck = await db.query('SELECT id FROM doctors WHERE id = $1', [doctor_id]);
    if (!docCheck.rows.length) return res.status(404).json({ error: 'Doctor not found' });

    const password_hash = await bcrypt.hash(password, 10);
    const id = uuidv4();
    const { rows } = await db.query(
      `INSERT INTO receptionists (id, first_name, last_name, email, password_hash, phone, employee_id, shift, department, doctor_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
       RETURNING id, first_name, last_name, email, phone, employee_id, shift, department, doctor_id, created_at`,
      [id, first_name, last_name, email, password_hash, phone, employee_id, shift, department, doctor_id]
    );

    const token = generateToken({ id, role: 'receptionist', email });
    return res.status(201).json({ token, role: 'receptionist', user: rows[0] });
  } catch (err) {
    console.error('Receptionist signup error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/auth/signup/patient ────────────────────────────────────────────
router.post('/signup/patient', async (req, res) => {
  const {
    first_name, last_name, email, password, phone,
    dob, gender, blood_group, allergies,
    insurance_partner, doctor_id
  } = req.body;
  if (!first_name || !last_name || !email || !password) {
    return res.status(400).json({ error: 'first_name, last_name, email, password are required' });
  }

  try {
    const exists = await db.query('SELECT id FROM patients WHERE email = $1', [email]);
    if (exists.rows.length) return res.status(409).json({ error: 'Email already registered' });

    const password_hash = await bcrypt.hash(password, 10);
    const id = uuidv4();
    const allergiesJson = JSON.stringify(allergies || []);
    const { rows } = await db.query(
      `INSERT INTO patients (id, first_name, last_name, email, password_hash, phone, dob, gender, blood_group, allergies, insurance_partner, doctor_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
       RETURNING id, first_name, last_name, email, phone, dob, gender, blood_group, allergies, insurance_partner, doctor_id, created_at`,
      [id, first_name, last_name, email, password_hash, phone, dob, gender, blood_group, allergiesJson, insurance_partner, doctor_id]
    );

    const token = generateToken({ id, role: 'patient', email });
    return res.status(201).json({ token, role: 'patient', user: rows[0] });
  } catch (err) {
    console.error('Patient signup error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
