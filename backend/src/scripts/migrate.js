require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { pool } = require('../db');

async function migrate() {
  console.log('🚀 Running Prachtiz DB migration against Neon...');
  const sql = fs.readFileSync(path.join(__dirname, '../schema.sql'), 'utf8');
  try {
    await pool.query(sql);
    console.log('✅ Migration complete! All tables created.');
  } catch (err) {
    console.error('❌ Migration failed:', err.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

migrate();
