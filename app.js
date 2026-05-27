const express = require('express');
const mysql = require('mysql2');

const app = express();
app.use(express.json());

// Database connection using Environment Variables (Crucial for DevOps)
const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'password',
    database: process.env.DB_NAME || 'notes_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Initialize Database Table
db.query(`
    CREATE TABLE IF NOT EXISTS notes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        content VARCHAR(255) NOT NULL
    )
`, (err) => {
    if (err) console.error("Database initialization failed:", err);
    else console.log("Database initialized successfully.");
});

// Health Check Route (Kubernetes will use this to check if the pod is alive)
app.get('/health', (req, res) => {
    res.status(200).send("OK");
});

// Get all notes
app.get('/notes', (req, res) => {
    db.query("SELECT * FROM notes", (err, results) => {
        if (err) return res.status(500).send(err);
        res.json(results);
    });
});

// Add a note
app.post('/notes', (req, res) => {
    const { content } = req.body;
    db.query("INSERT INTO notes (content) VALUES (?)", [content], (err, results) => {
        if (err) return res.status(500).send(err);
        res.json({ id: results.insertId, content });
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Notes app running on port ${PORT}`);
});