import { Request, Response } from "express";
import pool from "../models/db";
import bcrypt from 'bcrypt';
import jwt from "jsonwebtoken";

const SALT_ROUNDS = 10;
const JWT_SECRET = process.env.JWT_SECRET || 'chatsecurity';

interface AuthRequest extends Request {
  user?: any;
}

export const register = async (req: Request, res: Response) => {
  const { username, email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    const result = await pool.query(
      'INSERT INTO users (username, email, password) VALUES ($1, $2, $3) RETURNING id, username, email',
      [username, email, hashedPassword]
    );

    const user = result.rows[0];

    return res.status(201).json({
      message: 'User registered successfully',
      user,
    });
  } catch (error: any) {
    console.error('Register error:', error);

    // Postgres unique violation
    if (error.code === '23505') {
      // You can inspect error.constraint if you have multiple uniques
      if (error.constraint === 'users_username_key') {
        return res.status(400).json({ error: 'Username already taken' });
      }
      if (error.constraint === 'users_email_key') {
        return res.status(400).json({ error: 'Email already registered' });
      }

      // Generic duplicate
      return res.status(400).json({ error: 'User with these credentials already exists' });
    }

    return res.status(500).json({ error: 'Failed to register' });
  }
};

export const login = async (req: Request, res: Response): Promise<any> => {
  const { email, password } = req.body;

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    const user = result.rows[0];
    if (!user) return res.status(404).json({ error: "User not found" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ error: 'Invalid credentials' });

    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '10h' });
    let finalResult = { ...user, token };
    res.json({ user: finalResult });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: "Failed to login" });
  }
}

export const changePassword = async (req: Request, res: Response) => {
  const userId = (req as AuthRequest).user?.id; 
  const { currentPassword, newPassword } = req.body;

  console.log('Change password request:', { userId, hasCurrentPass: !!currentPassword, hasNewPass: !!newPassword });

  if (!userId || !currentPassword || !newPassword) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  try {
    const result = await pool.query(
      'SELECT password FROM users WHERE id = $1',
      [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = result.rows[0];

    const isMatch = await bcrypt.compare(currentPassword, user.password);

    if (!isMatch) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    const hashed = await bcrypt.hash(newPassword, 10);
    await pool.query(
      'UPDATE users SET password = $1 WHERE id = $2',
      [hashed, userId]
    );

    console.log('Password changed successfully for user:', userId);
    res.json({ message: 'Password changed successfully' });
  } catch (err) {
    console.error('Change password error:', err);
    res.status(500).json({ error: 'Failed to change password' });
  }
}
