const express = require("express");
const cors = require("cors");
const multer = require("multer");
const path = require("path");
const { Pool } = require("pg");
const fs = require("fs");

const app = express();
const PORT = 3000;

const pool = new Pool({
  host: process.env.DB_HOST || "db",
  port: Number(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME || "employeehub",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "postgres",
});

pool.query("SELECT NOW()")
  .then(() => console.log("✅ Connected to PostgreSQL"))
  .catch((err) => console.error("❌ DB Connection failed:", err.message));

pool.query(`
  CREATE TABLE IF NOT EXISTS r7_forms (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL UNIQUE,
    data JSONB NOT NULL DEFAULT '{}',
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT r7_forms_employee_fkey
      FOREIGN KEY (employee_id)
      REFERENCES employees(id)
      ON DELETE CASCADE
  )
`).then(() => console.log("✅ r7_forms table ready"))
  .catch((err) => console.error("❌ r7_forms error:", err.message));

pool.query(`
  CREATE TABLE IF NOT EXISTS r7_annual (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL UNIQUE,
    data JSONB NOT NULL DEFAULT '{}',
    employee_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
  )
`).then(() => console.log("✅ r7_annual table ready"))
  .catch((err) => console.error("❌ r7_annual error:", err.message));

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, "uploads", req.params.employeeId.toString());
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}_${file.originalname.replace(/[^a-zA-Z0-9._-]/g, "_")}`);
  },
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

const companyStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, "uploads", "company");
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}_${file.originalname.replace(/[^a-zA-Z0-9._-]/g, "_")}`);
  },
});
const uploadCompany = multer({
  storage: companyStorage,
  limits: { fileSize: 50 * 1024 * 1024 },
});

// ═══════════════════════════════════════════════════════════
// EMPLOYEES — specific routes MUST come before /:id
// ═══════════════════════════════════════════════════════════

app.get("/api/employees", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM employees ORDER BY full_name ASC");
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ⚠️ BEFORE /:id
app.get("/api/employees/departed", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        id, full_name, first_name, father_name, last_name,
        start_date, end_date, left_date, left_work_since,
        personal_financial_number, social_security_number
      FROM employees
      WHERE 
        end_date IS NOT NULL 
        OR left_date IS NOT NULL 
        OR (left_work_since IS NOT NULL AND left_work_since != '')
      ORDER BY COALESCE(end_date, left_date, left_work_since::date) DESC
    `);
    res.json(result.rows);
  } catch (err) {
    console.error("DEPARTED EMPLOYEES ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

// ⚠️ BEFORE /:id
app.post("/api/employees/:id/auto-e3lam", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM employees WHERE id = $1",
      [req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Employee not found" });
    }

    const e = result.rows[0];
    const endDate = e.end_date || e.left_date;

    const autoData = {
      institution_responsible:      e.institution_responsible ?? null,
      institution_nssf_number:      e.institution_nssf_number ?? null,
      institution_place:            e.institution_place ?? null,
      institution_number:           e.institution_number ?? null,
      institution_phone:            e.institution_phone ?? e.phone ?? null,
      institution_full_address:     e.institution_full_address ?? null,
      employee_fund_number:         e.employee_fund_number ?? null,
      employee_name:                e.employee_name ?? e.first_name ?? null,
      employee_surname:             e.employee_surname ?? e.last_name ?? null,
      father_name:                  e.father_name ?? null,
      mother_name:                  e.mother_name ?? null,
      birth_date_place:             e.birth_date_place ??
                                    [e.date_of_birth, e.place_of_birth]
                                      .filter(Boolean).join(' - ') ?? null,
      register_number:              e.register_number ?? null,
      nationality:                  e.nationality ?? null,
      gender:                       e.gender ?? 'ذكر',
      marital_status:               e.marital_status ?? 'أعزب',
      left_work_since:              endDate
                                    ? new Date(endDate).toISOString().split('T')[0]
                                    : null,
      leave_reason:                 e.leave_reason ?? 'استقالة',
      current_job:                  e.current_job ?? e.job_position ?? null,
      salary_at_leave_date:         e.salary_at_leave_date ??
                                    (e.basic_salary
                                      ? String(Math.round(e.basic_salary))
                                      : null),
      beirut_date:                  new Date().toISOString().split('T')[0],
      employee_signed_name:         e.employee_signed_name ?? e.full_name ?? null,
      center_number:                e.center_number ?? null,
      registration_department_name: e.registration_department_name ?? null,
      registration_department_date: e.registration_department_date ?? null,
      registration_processed_date:  e.registration_processed_date ?? null,
    };

    const fields = Object.keys(autoData).filter(
      k => autoData[k] !== null && autoData[k] !== undefined
    );
    if (fields.length > 0) {
      const values = fields.map(k => autoData[k]);
      const setClause = fields.map((f, i) => `${f} = $${i + 1}`).join(', ');
      values.push(e.id);
      await pool.query(
        `UPDATE employees SET ${setClause}, updated_at = NOW() WHERE id = $${values.length}`,
        values
      );
    }

    res.json({ success: true, data: autoData });
  } catch (err) {
    console.error("AUTO E3LAM ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

// ⚠️ AFTER all specific /employees/* routes
app.get("/api/employees/:id", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM employees WHERE id = $1", [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: "Not found" });
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post("/api/employees", async (req, res) => {
  try {
    const b = req.body;
    const keys = Object.keys(b).filter(
      k => b[k] !== null && b[k] !== undefined && b[k] !== ""
    );
    const values = keys.map(k => b[k]);
    const placeholders = keys.map((_, i) => `$${i + 1}`);
    const result = await pool.query(
      `INSERT INTO employees (${keys.join(", ")}) VALUES (${placeholders.join(", ")}) RETURNING *`,
      values
    );
    res.status(201).json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put("/api/employees/:id", async (req, res) => {
  try {
    const b = req.body;

    const dateColumns = [
      "joining_date", "start_date", "end_date", "left_date",
      "hiring_date", "work_start_date", "left_2_date", "hiring_2_date",
      "date_of_birth", "spouse_date_of_birth",
      "r3_social_security_start_date", "r3_registration_date",
      "left_work_since"  // Add left_work_since to date columns
    ];
    const boolColumns    = ["has_financial_number", "spouse_works"];
    const intColumns     = ["number_of_children"];
    const numericColumns = ["basic_salary", "other_allowances"];

    const cleaned = {};
    for (const [key, val] of Object.entries(b)) {
      if (key === "id" || key === "created_at" || key === "updated_at") continue;

      if (dateColumns.includes(key)) {
        cleaned[key] = (val === "" || val === null || val === undefined) ? null : val;
      } else if (boolColumns.includes(key)) {
        cleaned[key] = val === true || val === "true";
      } else if (intColumns.includes(key) || key.includes("children")) {
        cleaned[key] = (val === "" || val === null || val === undefined)
          ? null : parseInt(val);
      } else if (numericColumns.includes(key)) {
        cleaned[key] = (val === "" || val === null || val === undefined)
          ? null : parseFloat(val);
      } else {
        cleaned[key] = (val === "") ? null : val;
      }
    }

    const fields = Object.keys(cleaned);
    if (fields.length === 0) return res.status(400).json({ error: "No fields to update" });

    const values = Object.values(cleaned);
    const setClause = fields.map((f, i) => `${f} = $${i + 1}`).join(", ");
    values.push(req.params.id);

    const result = await pool.query(
      `UPDATE employees SET ${setClause}, updated_at = NOW() WHERE id = $${values.length} RETURNING *`,
      values
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error("UPDATE EMPLOYEE ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

app.delete("/api/employees/:id", async (req, res) => {
  try {
    await pool.query("DELETE FROM employees WHERE id = $1", [req.params.id]);
    res.json({ success: true });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get("/api/employees/:id/documents", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM employee_documents WHERE employee_id = $1 ORDER BY uploaded_at DESC",
      [req.params.id]
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post("/api/employees/:employeeId/upload", upload.array("files", 10), async (req, res) => {
  try {
    const uploaded = [];
    for (const file of req.files) {
      const filePath = `${req.params.employeeId}/${file.filename}`;
      const result = await pool.query(
        `INSERT INTO employee_documents (employee_id, file_name, file_path, file_size, mime_type)
         VALUES ($1, $2, $3, $4, $5) RETURNING *`,
        [req.params.employeeId, file.originalname, filePath, file.size, file.mimetype]
      );
      uploaded.push(result.rows[0]);
    }
    res.status(201).json(uploaded);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ═══════════════════════════════════════════════════════════
// COMPANY
// ═══════════════════════════════════════════════════════════

app.get("/api/company", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM company_info ORDER BY id LIMIT 1");
    if (result.rows.length === 0) return res.json({});
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put("/api/company", async (req, res) => {
  try {
    const b = req.body;
    const skip = ['id', 'created_at'];
    const fields = Object.keys(b).filter(
      k => !skip.includes(k) && b[k] !== undefined
    );
    if (fields.length === 0) return res.status(400).json({ error: "No fields" });

    const values = fields.map(k => {
      const v = b[k];
      return (v === '' || v === null) ? null : v;
    });
    const setClause = fields.map((f, i) => `${f} = $${i + 1}`).join(", ");

    const check = await pool.query("SELECT id FROM company_info LIMIT 1");
    let result;
    if (check.rows.length === 0) {
      const placeholders = fields.map((_, i) => `$${i + 1}`);
      result = await pool.query(
        `INSERT INTO company_info (${fields.join(", ")}) VALUES (${placeholders.join(", ")}) RETURNING *`,
        values
      );
    } else {
      values.push(check.rows[0].id);
      result = await pool.query(
        `UPDATE company_info SET ${setClause} WHERE id = $${values.length} RETURNING *`,
        values
      );
    }
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get("/api/company/documents", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM company_documents ORDER BY uploaded_at DESC"
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post("/api/company/upload", uploadCompany.single("file"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: "No file uploaded" });
    const filePath = `company/${req.file.filename}`;
    const result = await pool.query(
      `INSERT INTO company_documents (file_name, file_path, file_size, mime_type)
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [req.file.originalname, filePath, req.file.size, req.file.mimetype]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get("/api/company/documents/:id/download", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM company_documents WHERE id = $1", [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: "Not found" });
    const doc = result.rows[0];
    const fullPath = path.join(__dirname, "uploads", doc.file_path);
    if (!fs.existsSync(fullPath)) return res.status(404).json({ error: "File not found" });
    res.download(fullPath, doc.file_name);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.delete("/api/company/documents/:id", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM company_documents WHERE id = $1", [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: "Not found" });
    const doc = result.rows[0];
    const fullPath = path.join(__dirname, "uploads", doc.file_path);
    if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
    await pool.query("DELETE FROM company_documents WHERE id = $1", [req.params.id]);
    res.json({ success: true });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ═══════════════════════════════════════════════════════════
// SEARCH
// ═══════════════════════════════════════════════════════════

app.get("/api/search", async (req, res) => {
  try {
    const { q } = req.query;
    if (!q || q.trim() === "") return res.json([]);
    const result = await pool.query("SELECT * FROM search_employees($1)", [q.trim()]);
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ═══════════════════════════════════════════════════════════
// DOCUMENTS
// ═══════════════════════════════════════════════════════════

app.get("/api/document-counts", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT employee_id, COUNT(*) as count FROM employee_documents GROUP BY employee_id"
    );
    const counts = {};
    result.rows.forEach(r => (counts[r.employee_id] = parseInt(r.count)));
    res.json(counts);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get("/api/documents/:id/download", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM employee_documents WHERE id = $1", [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: "Not found" });
    const doc = result.rows[0];
    const fullPath = path.join(__dirname, "uploads", doc.file_path);
    if (!fs.existsSync(fullPath)) return res.status(404).json({ error: "File not found" });
    res.download(fullPath, doc.file_name);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.delete("/api/documents/:id", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM employee_documents WHERE id = $1", [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: "Not found" });
    const doc = result.rows[0];
    const fullPath = path.join(__dirname, "uploads", doc.file_path);
    if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
    await pool.query("DELETE FROM employee_documents WHERE id = $1", [req.params.id]);
    res.json({ success: true });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ═══════════════════════════════════════════════════════════
// R7 — specific routes MUST come before /:employeeId
// ═══════════════════════════════════════════════════════════

// ⚠️ BEFORE /:employeeId
app.post("/api/r7/auto-populate/:year", async (req, res) => {
  try {
    const year = parseInt(req.params.year);
    if (isNaN(year)) {
      return res.status(400).json({ error: "Invalid year" });
    }

    console.log(`R7 auto-populate for year ${year}`);

    const companyResult = await pool.query(
      "SELECT * FROM company_info ORDER BY id LIMIT 1"
    );
    const company = companyResult.rows[0] ?? {};

    // UPDATED QUERY: Now includes left_work_since
    const empResult = await pool.query(`
      SELECT
        id, full_name, first_name, father_name, last_name,
        start_date, end_date, left_date, left_work_since,
        personal_financial_number, social_security_number
      FROM employees
      WHERE
        (end_date IS NOT NULL AND EXTRACT(YEAR FROM end_date) = $1)
        OR
        (left_date IS NOT NULL AND EXTRACT(YEAR FROM left_date) = $1)
        OR
        (
          left_work_since IS NOT NULL
          AND left_work_since != ''
          AND EXTRACT(YEAR FROM left_work_since::date) = $1
        )
      ORDER BY COALESCE(end_date, left_date, left_work_since::date) ASC
    `, [year]);

    const departed = empResult.rows;
    console.log(`Found ${departed.length} departed employees in ${year}`);

    const fmtDate = (d) => {
      if (!d) return null;
      const s = d.toString();
      return s.length >= 10 ? s.substring(0, 10) : s;
    };

    const employeeRows = [];
    for (let i = 0; i < 13; i++) {
      if (i < departed.length) {
        const e = departed[i];
        const nameParts = [e.first_name, e.father_name, e.last_name]
          .filter(p => p && p.trim());
        const fullName = nameParts.length > 0
          ? nameParts.join(' ')
          : (e.full_name ?? '');
        employeeRows.push({
          employee_name:           fullName || null,
          personal_finance_number: e.personal_financial_number || null,
          membership_number:       e.social_security_number || null,
          start_date:              fmtDate(e.start_date),
          // UPDATED: Now falls back to left_work_since if end_date and left_date are null
          end_date:                fmtDate(e.end_date ?? e.left_date ?? e.left_work_since),
        });
      } else {
        employeeRows.push({
          employee_name: null, personal_finance_number: null,
          membership_number: null, start_date: null, end_date: null,
        });
      }
    }

    const r7Data = {
      company_name:                company.company_name ?? null,
      year:                        String(year),
      trade_name:                  company.trade_name ?? null,
      finance_registration_number: company.ministry_reg_number ?? null,
      nssf_registration_number:    company.social_security_number ?? null,
      employees:                   employeeRows,
    };

    await pool.query(`
      INSERT INTO r7_annual (year, data, employee_count, updated_at)
      VALUES ($1, $2, $3, NOW())
      ON CONFLICT (year) DO UPDATE
        SET data           = EXCLUDED.data,
            employee_count = EXCLUDED.employee_count,
            updated_at     = NOW()
    `, [year, r7Data, departed.length]);

    res.json({
      success: true, year,
      employee_count: departed.length,
      data: r7Data,
    });
  } catch (err) {
    console.error("R7 AUTO-POPULATE ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

// ⚠️ BEFORE /annual/:year GET
app.post("/api/r7/annual/:year/save", async (req, res) => {
  try {
    const year = parseInt(req.params.year);
    if (isNaN(year)) {
      return res.status(400).json({ error: "Invalid year" });
    }
    const data = req.body;
    console.log(`R7 manual save for year ${year}`);
    const employeeCount = (data.employees ?? [])
      .filter(e => e && e.employee_name).length;
    await pool.query(`
      INSERT INTO r7_annual (year, data, employee_count, updated_at)
      VALUES ($1, $2, $3, NOW())
      ON CONFLICT (year) DO UPDATE
        SET data           = EXCLUDED.data,
            employee_count = EXCLUDED.employee_count,
            updated_at     = NOW()
    `, [year, data, employeeCount]);
    res.json({ success: true, year, employee_count: employeeCount });
  } catch (err) {
    console.error("R7 ANNUAL SAVE ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

// ⚠️ BEFORE /:employeeId
app.get("/api/r7/annual/:year", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM r7_annual WHERE year = $1",
      [parseInt(req.params.year)]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "No R7 data for this year" });
    }
    const row = result.rows[0];
    res.json({ ...row.data, year: String(row.year) });
  } catch (err) {
    console.error("R7 ANNUAL GET ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

// ⚠️ BEFORE /:employeeId
app.get("/api/r7/latest", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM r7_annual ORDER BY year DESC LIMIT 1"
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "No R7 data found" });
    }
    const row = result.rows[0];
    res.json({ ...row.data, year: String(row.year) });
  } catch (err) {
    console.error("R7 LATEST GET ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

// ⚠️ AFTER all specific /r7/* routes
app.get("/api/r7/:employeeId", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM r7_forms WHERE employee_id = $1",
      [req.params.employeeId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Not found" });
    }
    const row  = result.rows[0];
    const data = row.data ?? {};
    res.json({
      employee_id:                 row.employee_id,
      company_name:                data.company_name ?? null,
      year:                        data.year ?? null,
      trade_name:                  data.trade_name ?? null,
      finance_registration_number: data.finance_registration_number ?? null,
      nssf_registration_number:    data.nssf_registration_number ?? null,
      employees:                   data.employees ?? [],
    });
  } catch (err) {
    console.error("R7 GET ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post("/api/r7", async (req, res) => {
  try {
    console.log("R7 POST received:", JSON.stringify(req.body).substring(0, 200));
    const { employee_id, ...rest } = req.body;

    if (employee_id == null) {
      return res.status(400).json({ error: "employee_id is required" });
    }

    const existing = await pool.query(
      "SELECT id FROM r7_forms WHERE employee_id = $1", [employee_id]
    );

    let result;
    if (existing.rows.length > 0) {
      result = await pool.query(
        `UPDATE r7_forms SET data = $1, updated_at = NOW()
         WHERE employee_id = $2 RETURNING *`,
        [rest, employee_id]
      );
    } else {
      result = await pool.query(
        `INSERT INTO r7_forms (employee_id, data) VALUES ($1, $2) RETURNING *`,
        [employee_id, rest]
      );
    }

    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error("R7 SAVE ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

// ═══════════════════════════════════════════════════════════
// START
// ═══════════════════════════════════════════════════════════

app.listen(PORT, () => {
  console.log(`\n🚀 Employee Hub API running at http://127.0.0.1:${PORT}\n`);
});