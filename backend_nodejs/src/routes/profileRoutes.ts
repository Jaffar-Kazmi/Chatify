import { Router } from 'express';
import multer from 'multer';
import { verifyToken } from '../middlewares/authMiddleware'
import { getProfile, updateProfile, uploadProfilePic } from '../controllers/profileController';

const router = Router();
const upload = multer({ dest: 'uploads/profiles/' });

// GET profile
router.get('/', verifyToken, getProfile);

// PUT update profile
router.put('/', verifyToken, updateProfile);

// POST upload profile picture
router.post('/picture', verifyToken, upload.single('profilePic'), uploadProfilePic);

export default router;
