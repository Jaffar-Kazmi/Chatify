import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { verifyToken } from '../middlewares/authMiddleware';

const router = Router();

const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueName = `${Date.now()}-${Math.random().toString(36).substring(2, 9)}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    },
});

const upload = multer({
    storage,
    limits: { fileSize: 1024 * 1024 * 5 },
    fileFilter: (req, file, cb) => {
        const allowed = /jpeg|jpg|png|gif/;
        const ext = path.extname(file.originalname).toLowerCase();
        if (allowed.test(ext)) {
            cb(null, true);
        } else {
            cb(new Error('Only images are allowed'));
        }
    },
});

router.post('/upload', verifyToken, upload.single('image'), (req: Request, res: Response) => {
    console.log('Upload request received');
    console.log('File:', req.file);

    if (!req.file) {
        console.log('No file in request');
        return res.status(400).json({ error: 'No file uploaded' });
    }


  console.log('File saved to:', req.file.path);
  console.log('Filename:', req.file.filename);

    const imageUrl = `${process.env.BASE_URL}/uploads/${req.file.filename}`;

      console.log('Returning imageUrl:', imageUrl);
    res.json({ success: true, imageUrl, filename: req.file.filename });
});

router.use('/uploads', (req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    next();
})

export default router;