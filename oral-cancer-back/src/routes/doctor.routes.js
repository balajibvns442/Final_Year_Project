const express = require('express');
const router = express.Router();

const { authenticate } = require('../middleware/auth.middleware');
const { allowRoles } = require('../middleware/role.middleware');
const {
  getPendingReviews,
  // submitReview
} = require('../controllers/doctor.controller');

router.get(
  '/pending',
  authenticate,
  allowRoles('DOCTOR'),
  getPendingReviews
);

// router.post(
//   '/submit',
//   authenticate,
//   allowRoles('DOCTOR'),
//   submitReview
// );

module.exports = router;
