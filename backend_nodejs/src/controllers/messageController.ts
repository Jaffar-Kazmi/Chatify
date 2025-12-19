import { Request, Response } from "express";
import pool from "../models/db";
import uploadMessageImage from "../middlewares/uploadMessageImage";

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
  const user = (req as any).user;
  
  // Wrap multer upload inside the controller
  uploadMessageImage.single('image')(req, res, async (err: any) => {
    if (err) {
      console.error('Multer error:', err);
      return res.status(400).json({ error: 'Failed to upload image' });
    }

    const { conversationId, content } = req.body;

    if (!conversationId) {
      return res.status(400).json({ error: 'conversationId is required' });
    }

    // Determine the message content: text or image URL
    let messageContent = content || null;
    if (req.file) {
      messageContent = (req.file as any).path; // Cloudinary URL
    }

    if (!messageContent) {
      return res.status(400).json({ error: 'Message content or image is required' });
    }

    try {
      const result = await pool.query(
        `
        INSERT INTO messages (conversation_id, sender_id, content)
        VALUES ($1, $2, $3)
        RETURNING id, content, sender_id, conversation_id, created_at;
        `,
        [conversationId, user.id, messageContent]
      );

      const message = result.rows[0];
      console.log('createMessage: inserted', message);

      return res.status(201).json(message);
    } catch (err) {
      console.error('Error saving message:', err);
      return res.status(500).json({ error: 'Failed to save message' });
    }
  });
};
