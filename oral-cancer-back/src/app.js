const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const authRoutes = require('./routes/auth.routes');
const patientRoutes = require('./routes/patient.routes');
const visitRoutes = require('./routes/visit.routes');
const imageRoutes = require('./routes/image.routes');
const reviewRoutes = require('./routes/review.routes');
const doctorRoutes = require('./routes/doctor.routes');

app.use(cors());
app.use(express.json());

app.use('/auth' , authRoutes);
app.use('/patients', patientRoutes);
app.use('/visits', visitRoutes);
app.use('/images', imageRoutes);
app.use('/reviews', reviewRoutes);
app.use('/doctor', doctorRoutes);


app.get('/health', (req, res) => {
  res.json({ status: 'OK' });
});

module.exports = app;

// configures the server ( express ) and middleware
// password hash for password123
// $2b$10$ZdKteTDG68AiQ.R0iB2DCujWVfROSqDu4RqQRR5qy751qINln9S2q 

