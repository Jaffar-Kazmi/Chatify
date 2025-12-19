import { Router, Request, Response } from 'express';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import multer from 'multer';
import cloudinary from '../config/cloudinary';
import { verifyToken } from '../middlewares/authMiddleware';

const router = Router();

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'chatify_uploads',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
    transformation: [{ width: 800, height: 800, crop: 'limit' }]
  } as any
});

const upload = multer({
  storage,
});

router.post('/upload', verifyToken, upload.single('image'), (req: Request, res: Response) => {
  console.log('Cloudinary upload request received');
  
  if (!req.file) {
    console.log('No file in request');
    return res.status(400).json({ error: 'No file uploaded' });
  }

  console.log('Cloudinary file:', {
    path: req.file.path,      
    filename: req.file.filename
  });

  const imageUrl = req.file.path; 
  console.log('Returning Cloudinary URL:', imageUrl);
  
  res.json({ 
    success: true, 
    imageUrl,        
    filename: req.file.filename 
  });
});

export default router;
