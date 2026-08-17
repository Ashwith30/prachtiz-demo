require('dotenv').config();
const { Pool } = require('pg');

// Build connection URL with uselibpqcompat for Neon SSL compatibility
const connectionString = (process.env.DATABASE_URL || '').replace(
  'channel_binding=require',
  'channel_binding=require&uselibpqcompat=true'
);

const pool = new Pool({
  connectionString,
  ssl: { rejectUnauthorized: false },
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

pool.on('connect', () => {
  if (process.env.NODE_ENV !== 'production') {
    console.log('✅ PostgreSQL connected to Neon DB');
  }
});

pool.on('error', (err) => {
  console.error('❌ Unexpected DB pool error:', err.message);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};
