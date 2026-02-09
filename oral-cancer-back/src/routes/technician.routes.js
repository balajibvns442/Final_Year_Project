const express = require('express');
const router = express.Router();
const { createOrGetPatient } = require('../controllers/patient.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { getPendingCasesByTechnician} = require('../controllers/technician.controller');

router.post('/', authenticate, createOrGetPatient);
router.get('/pending-cases', authenticate, getPendingCasesByTechnician);
router.get('/reviewed-cases', authenticate, getReviewedCasesByTechnician);

module.exports = router;
