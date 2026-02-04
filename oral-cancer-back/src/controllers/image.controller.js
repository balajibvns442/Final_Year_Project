const pool = require('../db');
const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

exports.uploadImage = async (req, res) => {
  const { visit_id } = req.body;

  if (!visit_id) {
    return res.status(400).json({ error: 'visit_id required' });
  }

  if (!req.file) {
    return res.status(400).json({ error: 'image file required' });
  }

  const imagePath = req.file.path;

  try {
    // 1️⃣ Save image record
    const [imageResult] = await pool.query(
      'INSERT INTO images (visit_id, image_path) VALUES (?, ?)',
      [visit_id, imagePath]
    );

    const imageId = imageResult.insertId;

    // 2️⃣ Prepare ML request
    const formData = new FormData();
    formData.append('file', fs.createReadStream(imagePath));

    // 3️⃣ Call Flask ML server
    const mlResponse = await axios.post(
      'http://localhost:5000/predict',
      formData,
      {
        headers: formData.getHeaders(),
        timeout: 15000
      }
    );

    const { risk, confidence } = mlResponse.data;

    const [predResult] = await pool.query(
      'INSERT INTO predictions (image_id, risk, confidence) VALUES (?, ?, ?)',
      [imageId, risk, confidence]
    );

    const predictionId = predResult.insertId;

    // 🔹 CREATE REVIEW ENTRY
    await pool.query(
      'INSERT INTO reviews (prediction_id, status) VALUES (?, "PENDING")',
      [predictionId]
    );


    // after image, prediction, review are created

    const reviewId = reviewResult.insertId;

    // fetch snapshot data ONCE (single join, one-time cost)
    const [rows] = await db.query(`
  SELECT
    p.name AS patient_name,
    p.phone AS patient_phone,
    v.age,
    DATE(v.visit_date) AS visit_date,
    i.image_path,
    pr.risk,
    pr.confidence
  FROM predictions pr
  JOIN images i ON pr.image_id = i.id
  JOIN visits v ON i.visit_id = v.id
  JOIN patients p ON v.patient_id = p.id
  WHERE pr.id = ?
`, [predictionId]);

    const snap = rows[0];

    // insert snapshot
    await db.query(`
  INSERT INTO review_queue (
    review_id,
    prediction_id,
    patient_name,
    patient_phone,
    age,
    visit_date,
    image_url,
    risk,
    confidence
  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
`, [
      reviewId,
      predictionId,
      snap.patient_name,
      snap.patient_phone,
      snap.age,
      snap.visit_date,
      snap.image_path,
      snap.risk,
      snap.confidence
    ]);



    // 5️⃣ Respond
    res.json({
      image_id: imageId,
      risk,
      confidence
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Image processing failed' });
  }
};



const path = require('path');

exports.getImage = async (req, res) => {
  const { imageId } = req.params;

  try {
    // 1️⃣ Fetch image path from DB
    const [rows] = await pool.query(
      'SELECT image_path FROM images WHERE id = ?',
      [imageId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Image not found' });
    }

    const imagePath = rows[0].image_path;

    // 2️⃣ Resolve absolute path safely
    const absolutePath = path.resolve(imagePath);

    // 3️⃣ Send image file
    res.sendFile(absolutePath);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch image' });
  }
};

exports.getImageByPath = async (req, res) => {
  console.log(req.params) ;
  const { image_path } = req.params;

  try {
    // 1️⃣ Resolve absolute path safely
    const absolutePath = path.resolve(image_path);

    res.sendFile(absolutePath);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch image' });
  }
};

