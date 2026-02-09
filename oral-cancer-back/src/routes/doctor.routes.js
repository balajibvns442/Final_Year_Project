const express = require('express');
const router = express.Router();

const { authenticate } = require('../middleware/auth.middleware');
const { allowRoles } = require('../middleware/role.middleware');
const {
  getPendingReviews,
  getCompletedReviews
  // submitReview
} = require('../controllers/doctor.controller');

router.get('/completed-reviews', authenticate, allowRoles('DOCTOR'), getCompletedReviews);

module.exports = router;
