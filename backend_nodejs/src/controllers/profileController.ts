import { Request, Response } from 'express';
import pool from '../models/db';
import path from 'path';
import fs from 'fs';

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
        ? `http://localhost:3000/uploads/profiles/${user.profile_image}`
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
    return res.status(400).json({ error: 'No file uploaded' });
  }
  
  try {
    // Delete old profile pic if exists
    const user = await pool.query(
      'SELECT profile_image FROM users WHERE id = $1', [userId]
    );
    if (user.rows[0]?.profile_image) {
      fs.unlinkSync(path.join(__dirname, '../../uploads/profiles/', user.rows[0].profile_image));
    }
    
    // Save new filename (userId_timestamp.jpg)
    const newFilename = `${userId}_${Date.now()}${path.extname(file.originalname)}`;
    
    fs.renameSync(
      path.join(__dirname, '../../uploads/profiles/', file.filename),
      path.join(__dirname, '../../uploads/profiles/', newFilename)
    );
    
    await pool.query(
      'UPDATE users SET profile_image = $1 WHERE id = $2',
      [newFilename, userId]
    );
    
    res.json({ profilePic: `http://10.0.2.2:3000/uploads/profiles/${newFilename}` });
  } catch (error) {
    fs.unlinkSync(path.join(__dirname, '../../uploads/profiles/', file.filename));
    res.status(500).json({ error: 'Failed to upload profile picture' });
  }
};
