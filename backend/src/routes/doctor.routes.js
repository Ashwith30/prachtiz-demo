const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../db');
const { authenticate, requireRole } = require('../middleware/auth');

const router = express.Router();
router.use(authenticate, requireRole('doctor'));

// ─── GET /api/doctor/profile ──────────────────────────────────────────────────
router.get('/profile', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT id, first_name, last_name, email, phone, specialty, license, created_at FROM doctors WHERE id = $1`,
      [req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Doctor not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/doctor/profile ────────────────────────────────────────────────
router.patch('/profile', async (req, res) => {
  const { first_name, last_name, phone, specialty, license } = req.body;
  try {
    const { rows } = await db.query(
      `UPDATE doctors SET first_name=COALESCE($1,first_name), last_name=COALESCE($2,last_name),
       phone=COALESCE($3,phone), specialty=COALESCE($4,specialty), license=COALESCE($5,license)
       WHERE id=$6
       RETURNING id, first_name, last_name, email, phone, specialty, license`,
      [first_name, last_name, phone, specialty, license, req.user.id]
    );
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/doctor/patients ─────────────────────────────────────────────────
router.get('/patients', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT id, first_name, last_name, email, phone, dob, gender, blood_group,
              allergies, condition, insurance_partner, created_at
       FROM patients WHERE doctor_id = $1 ORDER BY first_name ASC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/doctor/appointments ────────────────────────────────────────────
router.get('/appointments', async (req, res) => {
  const { date, status } = req.query;
  try {
    let query = `
      SELECT a.*, p.first_name || ' ' || p.last_name AS patient_name,
             p.phone AS patient_phone, p.insurance_partner
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      WHERE a.doctor_id = $1
    `;
    const params = [req.user.id];
    if (date) { query += ` AND a.date = $${params.length + 1}`; params.push(date); }
    if (status) { query += ` AND a.status = $${params.length + 1}`; params.push(status); }
    query += ` ORDER BY a.date ASC, a.time ASC`;
    const { rows } = await db.query(query, params);
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── PATCH /api/doctor/appointments/:id/status ────────────────────────────────
router.patch('/appointments/:id/status', async (req, res) => {
  const { status } = req.body;
  const validStatuses = ['pending', 'confirmed', 'inProgress', 'completed', 'cancelled'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: 'Invalid status' });
  }
  try {
    const { rows } = await db.query(
      `UPDATE appointments SET status=$1 WHERE id=$2 AND doctor_id=$3 RETURNING *`,
      [status, req.params.id, req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Appointment not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/doctor/staff ────────────────────────────────────────────────────
router.get('/staff', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT id, first_name, last_name, email, phone, employee_id, shift, department, created_at
       FROM receptionists WHERE doctor_id = $1 ORDER BY first_name ASC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/doctor/analytics/summary ───────────────────────────────────────
router.get('/analytics/summary', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const [
      apptToday,
      apptWeek,
      totalPatients,
      pendingLabs,
      videoToday,
      walkinToday,
      cancelledToday,
      patStats
    ] = await Promise.all([
      db.query(`SELECT COUNT(*) FROM appointments WHERE doctor_id=$1 AND date=$2`, [req.user.id, today]),
      db.query(`SELECT COUNT(*) FROM appointments WHERE doctor_id=$1 AND date BETWEEN $2 AND $2::date + 7`, [req.user.id, today]),
      db.query(`SELECT COUNT(*) FROM patients WHERE doctor_id=$1`, [req.user.id]),
      db.query(`SELECT COUNT(*) FROM lab_results WHERE doctor_id=$1 AND status='pending'`, [req.user.id]),
      db.query(`SELECT COUNT(*) FROM appointments WHERE doctor_id=$1 AND date=$2 AND (type ILIKE '%tele%' OR type ILIKE '%video%')`, [req.user.id, today]),
      db.query(`SELECT COUNT(*) FROM appointments WHERE doctor_id=$1 AND date=$2 AND (type NOT ILIKE '%tele%' AND type NOT ILIKE '%video%')`, [req.user.id, today]),
      db.query(`SELECT COUNT(*) FROM appointments WHERE doctor_id=$1 AND date=$2 AND status='cancelled'`, [req.user.id, today]),
      db.query(`
        WITH pat_counts AS (
          SELECT patient_id, COUNT(*) as cnt
          FROM appointments
          WHERE doctor_id=$1
          GROUP BY patient_id
        )
        SELECT 
          COALESCE(COUNT(CASE WHEN cnt = 1 THEN 1 END), 0) as first_time,
          COALESCE(COUNT(CASE WHEN cnt > 1 THEN 1 END), 0) as repeat
        FROM pat_counts
      `, [req.user.id]),
    ]);

    const firstTime = parseInt(patStats.rows[0].first_time || 0);
    const repeat = parseInt(patStats.rows[0].repeat || 0);

    return res.json({
      appointmentsToday: parseInt(apptToday.rows[0].count),
      appointmentsThisWeek: parseInt(apptWeek.rows[0].count),
      totalPatients: parseInt(totalPatients.rows[0].count),
      pendingLabReports: parseInt(pendingLabs.rows[0].count),
      videoConsultations: parseInt(videoToday.rows[0].count),
      walkInAppointments: parseInt(walkinToday.rows[0].count),
      firstTimePatients: firstTime,
      repeatPatients: repeat,
      rescheduled: 0,
      cancelled: parseInt(cancelledToday.rows[0].count),
    });
  } catch (err) {
    console.error('Analytics error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/doctor/prescriptions ───────────────────────────────────────────
router.get('/prescriptions', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT pr.*, p.first_name || ' ' || p.last_name AS patient_name
       FROM prescriptions pr
       JOIN patients p ON pr.patient_id = p.id
       WHERE pr.doctor_id = $1
       ORDER BY pr.created_at DESC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/doctor/prescriptions ──────────────────────────────────────────
router.post('/prescriptions', async (req, res) => {
  const { patient_id, medications, notes } = req.body;
  if (!patient_id) return res.status(400).json({ error: 'patient_id required' });
  try {
    const { rows } = await db.query(
      `INSERT INTO prescriptions (patient_id, doctor_id, medications, notes)
       VALUES ($1,$2,$3,$4) RETURNING *`,
      [patient_id, req.user.id, JSON.stringify(medications || []), notes]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/doctor/vitals/:patientId ───────────────────────────────────────
router.get('/vitals/:patientId', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM vitals WHERE patient_id=$1 ORDER BY recorded_at DESC LIMIT 50`,
      [req.params.patientId]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/doctor/vitals ──────────────────────────────────────────────────
router.post('/vitals', async (req, res) => {
  const { patient_id, heart_rate, blood_pressure, temperature, spo2 } = req.body;
  if (!patient_id) return res.status(400).json({ error: 'patient_id required' });
  try {
    const { rows } = await db.query(
      `INSERT INTO vitals (patient_id, heart_rate, blood_pressure, temperature, spo2)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [patient_id, heart_rate, blood_pressure, temperature, spo2]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/doctor/invoices ─────────────────────────────────────────────────
router.get('/invoices', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT inv.*, p.first_name || ' ' || p.last_name AS patient_name
       FROM invoices inv
       JOIN patients p ON inv.patient_id = p.id
       WHERE inv.doctor_id = $1
       ORDER BY inv.created_at DESC`,
      [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/doctor/invoices ────────────────────────────────────────────────
router.post('/invoices', async (req, res) => {
  const { patient_id, items, discount, tax_rate, payment_method, due_date } = req.body;
  if (!patient_id) return res.status(400).json({ error: 'patient_id required' });
  try {
    const { rows } = await db.query(
      `INSERT INTO invoices (patient_id, doctor_id, items, discount, tax_rate, payment_method, due_date)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [patient_id, req.user.id, JSON.stringify(items || []), discount || 0, tax_rate || 0.05, payment_method || 'Cash', due_date]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ── PATCH /api/doctor/invoices/:id/status ─────────────────────────────────────
router.patch('/invoices/:id/status', async (req, res) => {
  const { status } = req.body;
  const validStatuses = ['paid', 'unpaid', 'pending', 'overdue', 'partial'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: 'Invalid status' });
  }
  try {
    const { rows } = await db.query(
      `UPDATE invoices SET status=$1 WHERE id=$2 AND doctor_id=$3 RETURNING *`,
      [status, req.params.id, req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Invoice not found' });
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/doctor/tasks ────────────────────────────────────────────────────
router.get('/tasks', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM tasks WHERE doctor_id=$1 ORDER BY created_at DESC`, [req.user.id]
    );
    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── POST /api/doctor/tasks ───────────────────────────────────────────────────
router.post('/tasks', async (req, res) => {
  const { title, description, assigned_to, priority, due_date } = req.body;
  if (!title) return res.status(400).json({ error: 'title required' });
  try {
    const { rows } = await db.query(
      `INSERT INTO tasks (doctor_id, title, description, assigned_to, priority, due_date)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [req.user.id, title, description, assigned_to, priority || 'medium', due_date]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    return res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
