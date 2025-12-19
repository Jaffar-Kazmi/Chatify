import { NextFunction, Request, Response } from "express";
import jwt from 'jsonwebtoken';

interface AuthRequest extends Request {
  user?: { id: string };
}

export const verifyToken = (req: AuthRequest, res: Response, next: NextFunction): void => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
        res.status(403).json({ error: 'No token provided' });
        return;
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_Token || 'chatsecurity');
        req.user = decoded as { id: string };
        next();
    } catch (e) {
        res.status(401).json({ error: 'Invalid token' });
        return;
    }
}
