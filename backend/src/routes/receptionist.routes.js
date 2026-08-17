const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { authenticate, requireRole } = require('../middleware/auth');

const router = express.Router();
router.use(authenticate, requireRole('receptionist'));

// Helper: get the doctor_id assigned to this receptionist
async function getReceptionistDoctorId(receptionistId) {
  const { rows } = await db.query(`SELECT doctor_id FROM receptionists WHERE id=$1`, [receptionistId]);
  return rows[0]?.doctor_id;
}

// ─── GET /api/receptionist/profile ───────────────────────────────────────────
router.get('/profile', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT id, first_name, last_name, email, phone, employee_id, shift, department, doctor_id, created_at
       FROM receptionists WHERE id=$1`,
      [req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/receptionist/profile ─────────────────────────────────────────
router.patch('/profile', async (req, res) => {
  const { first_name, last_name, phone, department, employee_id } = req.body;
  try {
    const { rows } = await db.query(
      `UPDATE receptionists SET
        first_name=COALESCE($1,first_name),
        last_name=COALESCE($2,last_name),
        phone=COALESCE($3,phone),
        department=COALESCE($4,department),
        employee_id=COALESCE($5,employee_id)
       WHERE id=$6
       RETURNING id, first_name, last_name, email, phone, employee_id, shift, department, doctor_id, created_at`,
      [first_name, last_name, phone, department, employee_id, req.user.id]
    );
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/receptionist/patients ──────────────────────────────────────────
router.get('/patients', async (req, res) => {
  const { search, status } = req.query;
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    let query = `SELECT id, first_name, last_name, email, phone, dob, gender, condition, insurance_partner, created_at
                 FROM patients WHERE doctor_id=$1`;
    const params = [doctorId];
    if (search) {
      query += ` AND (first_name ILIKE $${params.length+1} OR last_name ILIKE $${params.length+1} OR email ILIKE $${params.length+1})`;
      params.push(`%${search}%`);
    }
    query += ` ORDER BY first_name ASC`;
    const { rows } = await db.query(query, params);
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/receptionist/patients ─────────────────────────────────────────
// Receptionist registers a walk-in patient (no password — admin-created)
router.post('/patients', async (req, res) => {
  const { first_name, last_name, email, phone, dob, gender, blood_group, allergies, insurance_partner, condition } = req.body;
  if (!first_name || !last_name) return res.status(400).json({ error: 'first_name, last_name required' });
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const bcrypt = require('bcryptjs');
    const tempPassword = await bcrypt.hash(uuidv4(), 10); // Temp hash, patient must reset
    const id = uuidv4();
    const { rows } = await db.query(
      `INSERT INTO patients (id, first_name, last_name, email, password_hash, phone, dob, gender, blood_group, allergies, condition, insurance_partner, doctor_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
       RETURNING id, first_name, last_name, email, phone, dob, gender, condition, insurance_partner`,
      [id, first_name, last_name, email || null, tempPassword, phone, dob, gender, blood_group, JSON.stringify(allergies || []), condition, insurance_partner, doctorId]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

router.get('/appointments', async (req, res) => {
  const { date } = req.query;
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    let query = `SELECT a.*, p.first_name || ' ' || p.last_name AS patient_name,
                        p.phone AS patient_phone, p.insurance_partner
                 FROM appointments a
                 JOIN patients p ON a.patient_id = p.id
                 WHERE a.doctor_id=$1`;
    const params = [doctorId];
    if (date && date !== 'all') {
      query += ` AND a.date=$2`;
      params.push(date);
    }
    query += ` ORDER BY a.time ASC`;
    const { rows } = await db.query(query, params);
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/receptionist/appointments ─────────────────────────────────────
router.post('/appointments', async (req, res) => {
  const { patient_id, date, time, end_time, type, symptoms, consult_type, price, partner_logo } = req.body;
  if (!patient_id || !date || !time) return res.status(400).json({ error: 'patient_id, date, time required' });
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);

    // Check if slot is already booked for this doctor (and not cancelled)
    const conflictCheck = await db.query(
      `SELECT id FROM appointments 
       WHERE doctor_id = $1 AND date = $2 AND time = $3 AND status != 'cancelled'`,
      [doctorId, date, time]
    );
    if (conflictCheck.rows.length > 0) {
      return res.status(409).json({ error: 'This appointment slot is already booked. Please choose another time.' });
    }

    const { rows } = await db.query(
      `INSERT INTO appointments (patient_id, doctor_id, date, time, end_time, type, symptoms, consult_type, price, partner_logo)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
      [patient_id, doctorId, date, time, end_time, type, symptoms, consult_type, price, partner_logo]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/receptionist/appointments/:id/checkin ────────────────────────
router.patch('/appointments/:id/checkin', async (req, res) => {
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const { rows } = await db.query(
      `UPDATE appointments SET status='inProgress' WHERE id=$1 AND doctor_id=$2 RETURNING *`,
      [req.params.id, doctorId]
    );
    if (!rows.length) return res.status(404).json({ error: 'Appointment not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/receptionist/appointments/:id/cancel ─────────────────────────
router.patch('/appointments/:id/cancel', async (req, res) => {
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const { rows } = await db.query(
      `UPDATE appointments SET status='cancelled' WHERE id=$1 AND doctor_id=$2 RETURNING *`,
      [req.params.id, doctorId]
    );
    if (!rows.length) return res.status(404).json({ error: 'Appointment not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/receptionist/billing ───────────────────────────────────────────
router.get('/billing', async (req, res) => {
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const { rows } = await db.query(
      `SELECT inv.*, p.first_name || ' ' || p.last_name AS patient_name
       FROM invoices inv JOIN patients p ON inv.patient_id = p.id
       WHERE inv.doctor_id=$1 ORDER BY inv.created_at DESC LIMIT 50`,
      [doctorId]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/receptionist/billing ──────────────────────────────────────────
router.post('/billing', async (req, res) => {
  const { patient_id, items, discount, tax_rate, payment_method, due_date } = req.body;
  if (!patient_id) return res.status(400).json({ error: 'patient_id required' });
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const { rows } = await db.query(
      `INSERT INTO invoices (patient_id, doctor_id, items, discount, tax_rate, payment_method, due_date)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [patient_id, doctorId, JSON.stringify(items || []), discount || 0, tax_rate || 0.05, payment_method || 'Cash', due_date]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/receptionist/billing/:id/payment ─────────────────────────────
router.patch('/billing/:id/payment', async (req, res) => {
  const { status, payment_method } = req.body;
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const { rows } = await db.query(
      `UPDATE invoices SET status=COALESCE($1,status), payment_method=COALESCE($2,payment_method)
       WHERE id=$3 AND doctor_id=$4 RETURNING *`,
      [status, payment_method, req.params.id, doctorId]
    );
    if (!rows.length) return res.status(404).json({ error: 'Invoice not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/receptionist/tasks ─────────────────────────────────────────────
router.get('/tasks', async (req, res) => {
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const { rows } = await db.query(`SELECT * FROM tasks WHERE doctor_id=$1 ORDER BY created_at DESC`, [doctorId]);
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/receptionist/tasks/:id/status ────────────────────────────────
router.patch('/tasks/:id/status', async (req, res) => {
  const { status } = req.body;
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const { rows } = await db.query(
      `UPDATE tasks SET status=$1 WHERE id=$2 AND doctor_id=$3 RETURNING *`,
      [status, req.params.id, doctorId]
    );
    if (!rows.length) return res.status(404).json({ error: 'Task not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/receptionist/doctor-schedule ───────────────────────────────────
router.get('/doctor-schedule', async (req, res) => {
  const { date } = req.query;
  try {
    const doctorId = await getReceptionistDoctorId(req.user.id);
    const { rows } = await db.query(
      `SELECT a.id, a.date, a.time, a.end_time, a.type, a.status,
              p.first_name || ' ' || p.last_name AS patient_name
       FROM appointments a JOIN patients p ON a.patient_id = p.id
       WHERE a.doctor_id=$1 ${date ? 'AND a.date=$2' : ''}
       ORDER BY a.date ASC, a.time ASC`,
      date ? [doctorId, date] : [doctorId]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
