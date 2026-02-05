const router = require('express').Router();
const { authenticate } = require('../middleware/auth.middleware');
const { allowRoles } = require('../middleware/role.middleware');
const { getPendingReviews, completeReview} = require('../controllers/review.controller');

router.get('/pending', authenticate, allowRoles('DOCTOR'), getPendingReviews);
// router.post('/submit', authenticate, allowRoles('DOCTOR'), submitReview);
router.post('/:reviewId',authenticate,allowRoles('DOCTOR'),completeReview) ;

module.exports = router;
