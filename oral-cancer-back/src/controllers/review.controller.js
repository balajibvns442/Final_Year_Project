const pool = require('../db');

exports.getPendingReviews = async (req, res) => {
  const [rows] = await pool.query(`
    SELECT
      review_id,
      patient_name,
      patient_phone,
      age,
      visit_date,
      image_url,
      risk,
      confidence
    FROM review_queue
    WHERE status = 'PENDING'
    ORDER BY created_at DESC
  `);

  res.json(rows);
};

exports.completeReview = async (req, res) => {
  const { reviewId } = req.params;
  const { notes } = req.body;
  const doctorId = req.user.userId;

  console.log('Completing review', { reviewId, doctorId, notes });

  await pool.query(`
    UPDATE reviews
    SET
      notes = ?,
      doctor_id = ?,
      status = 'REVIEWED',
      reviewed_at = NOW()
    WHERE id = ?
  `, [notes, doctorId, reviewId]);

  await pool.query(`
    UPDATE review_queue
    SET status = 'REVIEWED'
    WHERE review_id = ?
  `, [reviewId]);

  res.json({ message: 'Review completed' });
};
