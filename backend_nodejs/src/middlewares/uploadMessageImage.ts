import { CloudinaryStorage } from 'multer-storage-cloudinary';
import multer from 'multer';
import cloudinary from '../config/cloudinary';

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'chatify_messages',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
  } as any, 
});

const uploadMessageImage = multer({ storage });

export default uploadMessageImage;
