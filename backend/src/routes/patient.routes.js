const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { authenticate, requireRole } = require('../middleware/auth');

const router = express.Router();
router.use(authenticate, requireRole('patient'));

// ─── GET /api/patient/profile ─────────────────────────────────────────────────
router.get('/profile', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT id, first_name, last_name, email, phone, dob, gender, blood_group,
              allergies, condition, insurance_partner, doctor_id, created_at
       FROM patients WHERE id=$1`,
      [req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Patient not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/patient/profile ───────────────────────────────────────────────
router.patch('/profile', async (req, res) => {
  const { first_name, last_name, phone, blood_group, allergies, insurance_partner } = req.body;
  try {
    const { rows } = await db.query(
      `UPDATE patients SET
        first_name=COALESCE($1,first_name),
        last_name=COALESCE($2,last_name),
        phone=COALESCE($3,phone),
        blood_group=COALESCE($4,blood_group),
        allergies=COALESCE($5,allergies),
        insurance_partner=COALESCE($6,insurance_partner)
       WHERE id=$7
       RETURNING id, first_name, last_name, email, phone, dob, gender, blood_group,
                 allergies, condition, insurance_partner, doctor_id`,
      [first_name, last_name, phone, blood_group, allergies ? JSON.stringify(allergies) : null, insurance_partner, req.user.id]
    );
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/patient/appointments ───────────────────────────────────────────
router.get('/appointments', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT a.*, d.first_name || ' ' || d.last_name AS doctor_name, d.specialty
       FROM appointments a
       JOIN doctors d ON a.doctor_id = d.id
       WHERE a.patient_id=$1
       ORDER BY a.date DESC, a.time DESC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/patient/appointments ──────────────────────────────────────────
// Patient books a new appointment
router.post('/appointments', async (req, res) => {
  const { doctor_id, date, time, type, symptoms, consult_type } = req.body;
  if (!doctor_id || !date || !time) {
    return res.status(400).json({ error: 'doctor_id, date, time required' });
  }
  try {
    // Verify doctor exists
    const docCheck = await db.query(`SELECT id FROM doctors WHERE id=$1`, [doctor_id]);
    if (!docCheck.rows.length) return res.status(404).json({ error: 'Doctor not found' });

    // Check if slot is already booked for this doctor (and not cancelled)
    const conflictCheck = await db.query(
      `SELECT id FROM appointments 
       WHERE doctor_id = $1 AND date = $2 AND time = $3 AND status != 'cancelled'`,
      [doctor_id, date, time]
    );
    if (conflictCheck.rows.length > 0) {
      return res.status(409).json({ error: 'This appointment slot is already booked. Please choose another time.' });
    }

    // Get patient's insurance partner for partner_logo
    const { rows: patRows } = await db.query(`SELECT insurance_partner FROM patients WHERE id=$1`, [req.user.id]);
    const partner_logo = patRows[0]?.insurance_partner || null;

    const { rows } = await db.query(
      `INSERT INTO appointments (patient_id, doctor_id, date, time, type, symptoms, consult_type, partner_logo, status)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'pending') RETURNING *`,
      [req.user.id, doctor_id, date, time, type || 'Consultation', symptoms, consult_type, partner_logo]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/patient/appointments/:id/cancel ──────────────────────────────
router.patch('/appointments/:id/cancel', async (req, res) => {
  try {
    const { rows } = await db.query(
      `UPDATE appointments SET status='cancelled' WHERE id=$1 AND patient_id=$2 AND status='pending' RETURNING *`,
      [req.params.id, req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Appointment not found or cannot be cancelled' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/patient/prescriptions ──────────────────────────────────────────
router.get('/prescriptions', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT pr.*, d.first_name || ' ' || d.last_name AS doctor_name, d.specialty
       FROM prescriptions pr
       JOIN doctors d ON pr.doctor_id = d.id
       WHERE pr.patient_id=$1
       ORDER BY pr.created_at DESC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/patient/lab-results ────────────────────────────────────────────
router.get('/lab-results', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT lr.*, d.first_name || ' ' || d.last_name AS doctor_name
       FROM lab_results lr
       JOIN doctors d ON lr.doctor_id = d.id
       WHERE lr.patient_id=$1
       ORDER BY lr.created_at DESC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/patient/vitals ──────────────────────────────────────────────────
router.get('/vitals', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM vitals WHERE patient_id=$1 ORDER BY recorded_at DESC LIMIT 30`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/patient/vaccinations ────────────────────────────────────────────
router.get('/vaccinations', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM vaccinations WHERE patient_id=$1 ORDER BY date_given DESC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/patient/invoices ────────────────────────────────────────────────
router.get('/invoices', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT inv.*, d.first_name || ' ' || d.last_name AS doctor_name
       FROM invoices inv
       JOIN doctors d ON inv.doctor_id = d.id
       WHERE inv.patient_id=$1
       ORDER BY inv.created_at DESC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/patient/doctors ─────────────────────────────────────────────────
// For patient appointment booking — list doctors by specialty
router.get('/doctors', async (req, res) => {
  const { specialty } = req.query;
  try {
    let query = `SELECT id, first_name, last_name, specialty, license FROM doctors`;
    const params = [];
    if (specialty && specialty !== 'All') {
      query += ` WHERE specialty ILIKE $1`;
      params.push(`%${specialty}%`);
    }
    query += ` ORDER BY first_name ASC`;
    const { rows } = await db.query(query, params);
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
