import { Router } from 'express';
import multer from 'multer';
import { verifyToken } from '../middlewares/authMiddleware'
import { getProfile, updateProfile, uploadProfilePic } from '../controllers/profileController';
import path from 'path';

const router = Router();
const uploadDir = path.join(__dirname, '../../uploads/profiles');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Initial temp name; will be renamed in controller
    const tempName = `${Date.now()}-${Math.random()
      .toString(36)
      .substring(2, 8)}${path.extname(file.originalname)}`;
    cb(null, tempName);
  },
});

const upload = multer({ storage });

// GET profile
router.get('/', verifyToken, getProfile);

// PUT update profile
router.put('/', verifyToken, updateProfile);

// POST upload profile picture
router.post('/upload', verifyToken, upload.single('profilePic'), uploadProfilePic);

export default router;
