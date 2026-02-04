const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload.middleware');
const { uploadImage, getImage , getImageByPath} = require('../controllers/image.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.post(
  '/upload',
  authenticate,
  upload.single('image'),
  uploadImage
);

router.get('/getImage/:imageId', authenticate, getImage);

router.get('/:image_path',authenticate,getImageByPath) ;

module.exports = router;
