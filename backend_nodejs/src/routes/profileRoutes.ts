import { Router } from 'express';
import upload from '../middlewares/cloudinaryUpload';
import { verifyToken } from '../middlewares/authMiddleware'
import { getProfile, updateProfile, uploadProfilePic } from '../controllers/profileController';
import path from 'path';

const router = Router();

// GET profile
router.get('/', verifyToken, getProfile);

// PUT update profile
router.put('/', verifyToken, updateProfile);

// POST upload profile picture
router.post('/upload', verifyToken, upload.single('profilePic'), uploadProfilePic);

export default router;
