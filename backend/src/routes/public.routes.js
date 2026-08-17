const express = require('express');
const db = require('../db');

const router = express.Router();

// ─── GET /api/public/doctors ──────────────────────────────────────────────────
// Public endpoint — lists doctors for signup search (no auth required)
// Query params: ?specialty=Cardiologist
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
    console.error('List doctors error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// ─── GET /api/public/specialties ─────────────────────────────────────────────
// Public endpoint — distinct list of specialties for the filter dropdown
router.get('/specialties', async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT DISTINCT specialty FROM doctors WHERE specialty IS NOT NULL ORDER BY specialty ASC`
    );
    return res.json(rows.map((r) => r.specialty));
  } catch (err) {
    console.error('List specialties error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
