import { Request, Response } from 'express';
import pool from '../models/db';
import path from 'path';
import fs from 'fs';

const baseUrl = process.env.BASE_URL;


export const getProfile = async (req: Request, res: Response) => {
  const userId = req.user!.id;

  try {
    const result = await pool.query(
      'SELECT id, username, email, profile_image FROM users WHERE id = $1',
      [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = result.rows[0];

    const profileWithUrl = {
      ...user,
      profile_image: user.profile_image
        ? `${baseUrl}/uploads/profiles/${user.profile_image}`
        : null
    };

    res.json(profileWithUrl);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { username, email } = req.body;

  try {
    const result = await pool.query(
      'UPDATE users SET username = $1, email = $2 WHERE id = $3 RETURNING *',
      [username, email, userId]
    );

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update profile' });
  }
};

export const uploadProfilePic = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const file = req.file;

  if (!file) {
    console.error('No file in request');
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const uploadDir = path.join(__dirname, '../../uploads/profiles');
  const tempPath = path.join(uploadDir, file.filename);

  console.log('Upload dir:', uploadDir);
  console.log('Temp file path:', tempPath);
  console.log('File from multer:', file);
  try {
    // Delete old profile pic if exists
    const user = await pool.query(
      'SELECT profile_image FROM users WHERE id = $1', [userId]
    );

    const oldFile = user.rows[0]?.profile_image
      ? path.join(uploadDir, user.rows[0].profile_image)
      : null;

    if (oldFile && fs.existsSync(oldFile)) {
      fs.unlinkSync(oldFile);
    }

    const newFilename = `${userId}_${Date.now()}${path.extname(file.originalname)}`;
    const newPath = path.join(uploadDir, newFilename);

    // Make sure temp file exists before renaming
    if (!fs.existsSync(tempPath)) {
      console.error('Temp upload file not found:', tempPath);
      return res.status(500).json({ error: 'Upload temp file missing' });
    }

    fs.renameSync(tempPath, newPath);

    await pool.query(
      'UPDATE users SET profile_image = $1 WHERE id = $2',
      [newFilename, userId]
    );

    return res.json({ profilePic: `${baseUrl}/uploads/profiles/${newFilename}` });
  } catch (error) {
    console.error('Upload profile pic error:', error);
    if (fs.existsSync(tempPath)) {
      try {
        fs.unlinkSync(tempPath);
      } catch (e) {
        console.error('Failed to cleanup temp file:', e);
      }
    }
    return res.status(500).json({ error: 'Failed to upload profile picture' });
  }
};
