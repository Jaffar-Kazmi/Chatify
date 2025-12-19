import { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';

export const verifyToken = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];

  if (!token) {
    res.status(403).json({ error: 'No token provided' });
    return;
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_Token || 'chatsecurity') as { id: string };
    (req as any).user = { id: decoded.id }; 
    next();
  } catch (e) {
    res.status(401).json({ error: 'Invalid token' });
    return;
  }
};