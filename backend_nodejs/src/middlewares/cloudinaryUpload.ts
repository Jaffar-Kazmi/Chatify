import cloudinary from '../config/cloudinary';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import multer from 'multer';

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'chatify_profiles',
    allowed_formats: ['jpg', 'png', 'jpeg', 'webp'],
    limits: { fileSize: 10 * 1024 * 1024 }
    // transformation: [{ width: 512, height: 512, crop: 'limit' }],
  } as any,
});

const upload = multer({ storage });

export default upload;
