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

  // ── GET all employees
  app.get("/api/employees", async (req, res) => {
    try {
      const result = await pool.query("SELECT * FROM employees ORDER BY full_name ASC");
      res.json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });





  // ── GET company info
  app.get("/api/company", async (req, res) => {
    try {
      const result = await pool.query("SELECT * FROM company_info ORDER BY id LIMIT 1");
      if (result.rows.length === 0) return res.json({});
      res.json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  // ── UPDATE company info
  app.put("/api/company", async (req, res) => {
    try {
      const b = req.body;
      const skip = ['id', 'created_at'];
      const fields = Object.keys(b).filter(k => !skip.includes(k) && b[k] !== undefined);
      if (fields.length === 0) return res.status(400).json({ error: "No fields" });

      const values = fields.map(k => {
        const v = b[k];
        return (v === '' || v === null) ? null : v;
      });
      const setClause = fields.map((f, i) => `${f} = $${i + 1}`).join(", ");

      // Check if row exists
      const check = await pool.query("SELECT id FROM company_info LIMIT 1");
      let result;
      if (check.rows.length === 0) {
        // Insert new row
        const placeholders = fields.map((_, i) => `$${i + 1}`);
        result = await pool.query(
          `INSERT INTO company_info (${fields.join(", ")}) VALUES (${placeholders.join(", ")}) RETURNING *`,
          values
        );
      } else {
        // Update existing row
        values.push(check.rows[0].id);
        result = await pool.query(
          `UPDATE company_info SET ${setClause} WHERE id = $${values.length} RETURNING *`,
          values
        );
      }
      res.json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

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

// ── GET company documents
app.get("/api/company/documents", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM company_documents ORDER BY uploaded_at DESC"
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── UPLOAD company document
app.post("/api/company/upload", uploadCompany.single("file"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No file uploaded" });
    }

    const filePath = `company/${req.file.filename}`;

    const result = await pool.query(
      `INSERT INTO company_documents (file_name, file_path, file_size, mime_type)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [req.file.originalname, filePath, req.file.size, req.file.mimetype]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── DOWNLOAD company document
app.get("/api/company/documents/:id/download", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM company_documents WHERE id = $1",
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Not found" });
    }

    const doc = result.rows[0];
    const fullPath = path.join(__dirname, "uploads", doc.file_path);

    if (!fs.existsSync(fullPath)) {
      return res.status(404).json({ error: "File not found" });
    }

    res.download(fullPath, doc.file_name);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── DELETE company document
app.delete("/api/company/documents/:id", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM company_documents WHERE id = $1",
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Not found" });
    }

    const doc = result.rows[0];
    const fullPath = path.join(__dirname, "uploads", doc.file_path);

    if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);

    await pool.query("DELETE FROM company_documents WHERE id = $1", [req.params.id]);

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});




  // ── GET single employee
  app.get("/api/employees/:id", async (req, res) => {
    try {
      const result = await pool.query("SELECT * FROM employees WHERE id = $1", [req.params.id]);
      if (result.rows.length === 0) return res.status(404).json({ error: "Not found" });
      res.json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  // ── CREATE employee (dynamic — accepts ANY fields)
  app.post("/api/employees", async (req, res) => {
    try {
      const b = req.body;
      const keys = Object.keys(b).filter((k) => b[k] !== null && b[k] !== undefined && b[k] !== "");
      const values = keys.map((k) => b[k]);
      const placeholders = keys.map((_, i) => `$${i + 1}`);
      const result = await pool.query(
        `INSERT INTO employees (${keys.join(", ")}) VALUES (${placeholders.join(", ")}) RETURNING *`,
        values
      );
      res.status(201).json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  // ── UPDATE employee (dynamic — accepts ANY fields)
  // ── UPDATE employee (dynamic — accepts ANY fields)
  app.put("/api/employees/:id", async (req, res) => {
    try {
      const b = req.body;

      // Date columns that need empty string → null conversion
      const dateColumns = [
  "joining_date",
  "start_date",
  "end_date",
  "left_date",
  "hiring_date",
  "work_start_date",
  "left_2_date",
  "hiring_2_date",
  "date_of_birth",
  "spouse_date_of_birth",
  "r3_social_security_start_date",
  "r3_registration_date"
];

const boolColumns = ["has_financial_number", "spouse_works"];
const intColumns = ["number_of_children"];
const numericColumns = ["basic_salary", "other_allowances"];

const cleaned = {};
for (const [key, val] of Object.entries(b)) {
  if (key === "id" || key === "created_at" || key === "updated_at") continue;

  if (dateColumns.includes(key)) {
    cleaned[key] = (val === "" || val === null || val === undefined) ? null : val;
  } else if (boolColumns.includes(key)) {
    cleaned[key] = val === true || val === "true";
  } else if (intColumns.includes(key) || key.includes("children")) {
    cleaned[key] = (val === "" || val === null || val === undefined) ? null : parseInt(val);
  } else if (numericColumns.includes(key)) {
    cleaned[key] = (val === "" || val === null || val === undefined) ? null : parseFloat(val);
  } else {
    cleaned[key] = (val === "") ? null : val;
  }
}

      const fields = Object.keys(cleaned);
      if (fields.length === 0 ) return res.status(400).json({ error: "No fields to update" });

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

  // ── DELETE employee
  app.delete("/api/employees/:id", async (req, res) => {
    try {
      await pool.query("DELETE FROM employees WHERE id = $1", [req.params.id]);
      res.json({ success: true });
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  // ── SEARCH
  app.get("/api/search", async (req, res) => {
    try {
      const { q } = req.query;
      if (!q || q.trim() === "") return res.json([]);
      const result = await pool.query("SELECT * FROM search_employees($1)", [q.trim()]);
      res.json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  // ── GET documents for employee
  app.get("/api/employees/:id/documents", async (req, res) => {
    try {
      const result = await pool.query(
        "SELECT * FROM employee_documents WHERE employee_id = $1 ORDER BY uploaded_at DESC", [req.params.id]
      );
      res.json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  // ── GET document counts
  app.get("/api/document-counts", async (req, res) => {
    try {
      const result = await pool.query(
        "SELECT employee_id, COUNT(*) as count FROM employee_documents GROUP BY employee_id"
      );
      const counts = {};
      result.rows.forEach((r) => (counts[r.employee_id] = parseInt(r.count)));
      res.json(counts);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  // ── UPLOAD files
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

  // ── DOWNLOAD document
  app.get("/api/documents/:id/download", async (req, res) => {
    try {
      const result = await pool.query("SELECT * FROM employee_documents WHERE id = $1", [req.params.id]);
      if (result.rows.length === 0) return res.status(404).json({ error: "Not found" });
      const doc = result.rows[0];
      const fullPath = path.join(__dirname, "uploads", doc.file_path);
      if (!fs.existsSync(fullPath)) return res.status(404).json({ error: "File not found" });
      res.download(fullPath, doc.file_name);
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  // ── DELETE document
  app.delete("/api/documents/:id", async (req, res) => {
    try {
      const result = await pool.query("SELECT * FROM employee_documents WHERE id = $1", [req.params.id]);
      if (result.rows.length === 0) return res.status(404).json({ error: "Not found" });
      const doc = result.rows[0];
      const fullPath = path.join(__dirname, "uploads", doc.file_path);
      if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
      await pool.query("DELETE FROM employee_documents WHERE id = $1", [req.params.id]);
      res.json({ success: true });
    } catch (err) { res.status(500).json({ error: err.message }); }
  });

  app.listen(PORT, () => {
    console.log(`\n🚀 Employee Hub API running at http://127.0.0.1:${PORT}\n`);
  });