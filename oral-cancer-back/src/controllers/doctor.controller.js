const pool = require('../db');

exports.getPendingReviews = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        r.id AS review_id,
        p.id AS prediction_id,
        p.risk,
        p.confidence,
        i.id,
        v.id AS visit_id,
        pt.name AS patient_name,
        pt.phone
      FROM reviews r
      JOIN predictions p ON r.prediction_id = p.id
      JOIN images i ON p.image_id = i.id
      JOIN visits v ON i.visit_id = v.id
      JOIN patients pt ON v.patient_id = pt.id
      WHERE r.status = 'PENDING'
      ORDER BY p.id DESC
    `);

    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch pending reviews' });
  }
};


exports.submitReview = async (req, res) => {
  const { review_id, notes } = req.body;
  const doctorId = req.user.userId;

  if (!review_id || !notes) {
    return res.status(400).json({
      error: 'review_id and notes required'
    });
  }

  try {
    await pool.query(
      `UPDATE reviews
       SET notes = ?, status = 'REVIEWED', doctor_id = ?, reviewed_at = NOW()
       WHERE id = ?`,
      [notes, doctorId, review_id]
    );

    res.json({ message: 'Review submitted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Review submission failed' });
  }
};
