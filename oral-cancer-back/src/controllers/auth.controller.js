const pool = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
  const { phone, password } = req.body;

  if (!phone || !password) {
    return res.status(400).json({ error: 'Phone and password required' });
  }

  try {
    const [rows] = await pool.query(
      'SELECT id, name, password, role FROM users WHERE phone = ?',
      [phone]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'No match for the phone number' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: user.id,
        role: user.role 
    },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    console.log(`${user.name} logged in as ${user.role}`);

    res.json({
      token,
      role: user.role,
      name : user.name,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
};
