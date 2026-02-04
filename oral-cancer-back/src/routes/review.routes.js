const router = require('express').Router();
const { authenticate } = require('../middleware/auth.middleware');
const { allowRoles } = require('../middleware/role.middleware');
const { getPendingReviews} = require('../controllers/review.controller');

router.get('/pending', authenticate, allowRoles('DOCTOR'), getPendingReviews);
// router.post('/submit', authenticate, allowRoles('DOCTOR'), submitReview);

module.exports = router;
