-- ============================================================
-- Prachtiz Database Schema — PostgreSQL / Neon
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Doctors ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS doctors (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name    TEXT NOT NULL,
  last_name     TEXT NOT NULL,
  email         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  phone         TEXT,
  specialty     TEXT,         -- e.g. "General Physician", "Cardiologist"
  license       TEXT,         -- Medical council license number
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── Receptionists ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS receptionists (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name    TEXT NOT NULL,
  last_name     TEXT NOT NULL,
  email         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  phone         TEXT,
  employee_id   TEXT,
  shift         TEXT,         -- "Morning" / "Afternoon" / "Evening"
  department    TEXT,
  doctor_id     UUID REFERENCES doctors(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── Patients ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS patients (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name        TEXT NOT NULL,
  last_name         TEXT NOT NULL,
  email             TEXT UNIQUE NOT NULL,
  password_hash     TEXT NOT NULL,
  phone             TEXT,
  dob               DATE,
  gender            TEXT,     -- "Male" / "Female" / "Other"
  blood_group       TEXT,     -- "A+", "B-", etc.
  allergies         JSONB DEFAULT '[]',
  condition         TEXT,
  insurance_partner TEXT,     -- "CH", "HDFC", "SBI", "CircleBlue" or NULL (self-pay)
  doctor_id         UUID REFERENCES doctors(id) ON DELETE SET NULL,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ── Appointments ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS appointments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id      UUID REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id       UUID REFERENCES doctors(id) ON DELETE CASCADE,
  date            DATE NOT NULL,
  time            TEXT NOT NULL,        -- "10:30"
  end_time        TEXT,                 -- "11:00"
  type            TEXT,                 -- Telehealth / In-Person / Consultation / Follow-up / Emergency / Check-up
  status          TEXT DEFAULT 'pending', -- pending / confirmed / inProgress / completed / cancelled
  symptoms        TEXT,
  consult_type    TEXT,                 -- General / Follow-up / Video-MER / Telehealth
  price           NUMERIC(10,2),
  payment_status  TEXT DEFAULT 'due',   -- paid / due
  partner_logo    TEXT,                 -- "CH", "HDFC", "SBI", "CircleBlue"
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ── Prescriptions ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS prescriptions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id   UUID REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id    UUID REFERENCES doctors(id),
  date         DATE NOT NULL DEFAULT CURRENT_DATE,
  medications  JSONB DEFAULT '[]',     -- [{name, dose, frequency, duration}]
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── Vitals ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vitals (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id     UUID REFERENCES patients(id) ON DELETE CASCADE,
  heart_rate     INTEGER,
  blood_pressure TEXT,                  -- "122/80"
  temperature    NUMERIC(4,1),          -- 36.8
  spo2           INTEGER,               -- 98
  recorded_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── Lab Results ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lab_results (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id  UUID REFERENCES doctors(id),
  test_name  TEXT NOT NULL,
  result     TEXT,
  date       DATE DEFAULT CURRENT_DATE,
  status     TEXT DEFAULT 'pending',   -- pending / ready / reviewed
  file_url   TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Vaccinations ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vaccinations (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id   UUID REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id    UUID REFERENCES doctors(id),
  vaccine_name TEXT NOT NULL,
  dose         TEXT,                   -- "Dose 1 of 2", "Booster"
  date_given   DATE,
  next_due     DATE,
  batch_number TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── Invoices ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS invoices (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id     UUID REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id      UUID REFERENCES doctors(id),
  date           DATE NOT NULL DEFAULT CURRENT_DATE,
  due_date       DATE,
  items          JSONB DEFAULT '[]',   -- [{code, description, unitPrice, quantity}]
  discount       NUMERIC(5,2) DEFAULT 0,
  tax_rate       NUMERIC(4,3) DEFAULT 0.05,
  status         TEXT DEFAULT 'unpaid', -- paid / unpaid / pending / overdue / partial
  payment_method TEXT DEFAULT 'Cash',
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ── Tasks ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tasks (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id    UUID REFERENCES doctors(id) ON DELETE CASCADE,
  title        TEXT NOT NULL,
  description  TEXT,
  assigned_to  TEXT,                   -- name of staff member
  priority     TEXT DEFAULT 'medium',  -- low / medium / high / urgent
  status       TEXT DEFAULT 'todo',    -- todo / inProgress / done
  due_date     DATE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── Indexes for performance ───────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_appointments_doctor_id  ON appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date       ON appointments(date);
CREATE INDEX IF NOT EXISTS idx_patients_doctor_id      ON patients(doctor_id);
CREATE INDEX IF NOT EXISTS idx_receptionists_doctor_id ON receptionists(doctor_id);
CREATE INDEX IF NOT EXISTS idx_vitals_patient_id       ON vitals(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient   ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_lab_results_patient     ON lab_results(patient_id);
CREATE INDEX IF NOT EXISTS idx_invoices_patient        ON invoices(patient_id);
CREATE INDEX IF NOT EXISTS idx_doctors_specialty       ON doctors(specialty);
