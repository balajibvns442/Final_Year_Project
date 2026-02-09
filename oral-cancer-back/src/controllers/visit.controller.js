const pool = require('../db');

exports.createVisit = async (req, res) => {
  const { patient_id, age, symptoms, history } = req.body;

  if (!patient_id || !age) {
    return res.status(400).json({
      error: 'patient_id and age are required'
    });
  }

  if( req.user.role !== 'TECHNICIAN' ) {
    return res.status(403).json({
      error: 'Access denied'
    });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO visits (patient_id, age, visit_date, symptoms, history) VALUES (?, ?, CURDATE(), ?, ?)',
      [patient_id, age, symptoms, history]
    );

    console.log("creating visit for patient " + patient_id + " by user " + req.user.userId + " with symptoms: " + symptoms + ", history: " + history);

    res.json({
      message: 'Visit created',
      visit_id: result.insertId
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Visit creation failed' });
  }
};
