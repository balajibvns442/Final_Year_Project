const express = require('express');
const mysql = require('mysql2');
const multer = require('multer');
const bodyParser = require('body-parser');
const fs = require('fs');

const app = express();
app.use(bodyParser.json());

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'mysql@9157',
  database: 'testdb'
});

db.connect(err => {
  if (err) throw err;
  console.log('✅ MySQL Connected...');
});

// Multer setup (for handling multipart/form-data)
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// Upload image (POST)
app.post('/upload', upload.single('image'), (req, res) => {
  const name = req.file.originalname;
  const data = req.file.buffer;

  db.query('INSERT INTO images (name, image) VALUES (?, ?)', [name, data], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: 'Image uploaded!', id: result.insertId });
  });
});

app.get("/image/all", (req, res) => {
  console.log("🔍 /image/all endpoint hit");

  db.query('SELECT id, name, image FROM images', (err, results) => {
    if (err) {
      console.error("❌ DB error:", err);
      return res.status(500).send(err);
    }

    console.log("✅ Query executed, rows:", results.length);

    if (results.length === 0) {
      console.log("⚠️ No images in DB");
      return res.status(404).send('Not found');
    }

    const images = results.map(row => ({
      id: row.id,
      name: row.name,
      image: row.image.toString('base64')
    }));

    res.json(images);
  });
});

// Get image by ID (GET)
app.get('/image/:id', (req, res) => {
    console.log("Getting the image ") ;
  const id = req.params.id;
  db.query('SELECT name, image FROM images WHERE id=?', [id], (err, result) => {
    if (err) return res.status(500).send(err);
    if (result.length === 0) return res.status(404).send('Not found');

    res.setHeader('Content-Type', 'image/jpeg');
    res.send(result[0].image);
  });
});

app.listen(3000, () => console.log('🚀 Server running on port 3000'));
