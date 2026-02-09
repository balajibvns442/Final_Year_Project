const pool = require('../db');
const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

exports.uploadImage = async (req, res) => {
  const { visit_id } = req.body;
  const { patient_name, age } = req.body; // snapshot from request (not DB)

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
    const [reviewResult] = await pool.query(
      'INSERT INTO reviews (prediction_id, status) VALUES (?, "PENDING")',
      [predictionId]
    );

    const reviewId = reviewResult.insertId;

    // after image, prediction, review are created

    await pool.query(`
  INSERT INTO review_queue (
    review_id,
    image_id,
    patient_name,
    age,
    risk,
    confidence,
    created_by
  ) VALUES (?, ?, ?, ?, ?, ?)
`, [
      reviewId,
      imageId,
      patient_name,   // from request snapshot
      age,            // visit age snapshot
      risk,           // from ML
      req.user.userId     // technician id (JWT)
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
  console.log(req.params);
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

