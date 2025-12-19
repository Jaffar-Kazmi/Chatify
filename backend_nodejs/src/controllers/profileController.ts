import { Request, Response } from 'express';
import pool from '../models/db';

const baseUrl = process.env.BASE_URL;

interface AuthRequest extends Request {
  user?: { id: string };
  file?: any;
}

export const getProfile = async (req: Request, res: Response) => {
  const userId = (req as AuthRequest).user?.id; 
  
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
        ? user.profile_image.startsWith('http')
          ? user.profile_image
          : `${baseUrl}/uploads/profiles/${user.profile_image}`
        : null,
    };

    res.json(profileWithUrl);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  const userId = (req as AuthRequest).user?.id; 
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

export const uploadProfilePic = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  if (!req.file) {
    console.error('No file received in request');
    return res.status(400).json({ error: 'No file uploaded' });
  }

  // Determine URL
  const isCloudinary = (req.file as any).path?.startsWith('http');
  const imageUrl = isCloudinary
    ? (req.file as any).path
    : `${baseUrl}/uploads/profiles/${(req.file as any).filename}`;

  console.log('Upload file object:', JSON.stringify(req.file, null, 2));
  console.log('Resolved profile image URL:', imageUrl);

  try {
    await pool.query(
      'UPDATE users SET profile_image = $1 WHERE id = $2',
      [imageUrl, userId]
    );

    console.log(`User ${userId} profile picture updated successfully`);

    return res.json({
      message: 'Profile picture updated successfully',
      profilePic: imageUrl
    });
  } catch (error) {
    console.error('Database error updating profile picture:', error);
    return res.status(500).json({ error: 'Failed to upload profile picture' });
  }
};
