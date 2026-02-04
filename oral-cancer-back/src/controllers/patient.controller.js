
const pool = require('../db');

exports.createOrGetPatient = async (req, res) => {
  const { name, phone, gender } = req.body;

  if (!name || !phone || phone.trim() === '' ) {
    return res.status(400).json({
      error: 'Name and phone are required'
    });
  }

  if( req.user.role !== 'TECHNICIAN' ) {
    return res.status(403).json({
      error: 'Access denied'
    });
  }

  try {
    // 1️⃣ Check if patient already exists
    const [existing] = await pool.query(
      'SELECT id FROM patients WHERE name = ? AND phone = ?',
      [name, phone]
    );

    if (existing.length > 0) {
      return res.json({
        message: 'Existing patient found',
        patient_id: existing[0].id
      });
    }

    // console.log(req.user.id + " is creating patient");
    // 2️⃣ Create new patient
    const [result] = await pool.query(
      'INSERT INTO patients (name, phone, created_by, gender) VALUES (?, ?, ?, ?)',
      [name, phone, req.user.userId ,gender]
    );

    res.json({
      message: 'Patient created',
      patient_id: result.insertId
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Patient operation failed' });
  }
};
