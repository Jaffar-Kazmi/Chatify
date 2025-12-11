import { Request, Response } from "express";
import pool from "../models/db";

export const fetchAllMessagessByConversationId = async (req: Request, res: Response) => {
    const { conversationId } = req.params;

    try {
        const result = await pool.query(
            `
            SELECT m.id, m.content, m.sender_id, m.conversation_id, m.created_at
            FROM messages m
            WHERE m.conversation_id = $1
            ORDER by m.created_at ASC
            `,
            [conversationId]
        );

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({error: 'Failed to fetch messages'});
    }
}

export const createMessage = async (req: Request, res: Response) => {
  const { conversationId, content } = req.body;
  const user = (req as any).user; // assuming verifyToken sets req.user

  if (!conversationId || !content) {
    return res.status(400).json({ error: 'conversationId and content are required' });
  }

  try {
    const result = await pool.query(
      `
      INSERT INTO messages (conversation_id, sender_id, content)
      VALUES ($1, $2, $3)
      RETURNING id, content, sender_id, conversation_id, created_at;
      `,
      [conversationId, user.id, content]
    );

    const message = result.rows[0];
    console.log('createMessage: inserted', message);

    return res.status(201).json(message);
  } catch (err) {
    console.error('Error saving message:', err);
    return res.status(500).json({ error: 'Failed to save message' });
  }
};