const pool = require('../db');

exports.getPendingCasesByTechnician = async (req, res) => {
  const technicianId = req.user.userId;

  const [rows] = await pool.query(`
    SELECT
      review_id,
        image_id,
        patient_name,
        age,
        risk,
        confidence,
        created_by

    FROM review_queue
    WHERE status = 'PENDING' AND created_by = ?
    ORDER BY created_at DESC
      `,[technicianId]);
      ;

  res.json(rows);
}

exports.getReviewedCasesByTechnician = async (req, res) => {
  const technicianId = req.user.userId;

  const [rows] = await pool.query(`
    SELECT
      review_id,
        image_id,
        patient_name,
        age,
        risk,
        confidence,
        created_by

    FROM review_queue
    WHERE status = 'REVIEWED' AND created_by = ?
    ORDER BY created_at DESC
      `,[technicianId]);
      ;

  res.json(rows);
  }


