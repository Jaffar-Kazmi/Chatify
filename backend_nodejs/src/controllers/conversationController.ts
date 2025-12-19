import { Request, Response } from "express";
import pool from "../models/db";

const AI_BOT_ID = 'ai-bot-id';

interface AuthRequest extends Request {
  user?: any; 
}

export const fetchAllConversationsByUserId = async (req: Request, res: Response) => {
    const userId = (req as AuthRequest).user?.id; 

    console.log('Fetch conversations for user:', userId);

    try {
        const result = await pool.query(
            `
            SELECT
            c.id AS conversation_id,
            CASE WHEN u1.id = $1 THEN u2.username ELSE u1.username END AS participant_name,
            CASE WHEN u1.id = $1 THEN u2.profile_image ELSE u1.profile_image END AS participant_profile_image,
            m.content AS last_message,
            m.created_at AS last_message_time,
            (
            SELECT COUNT(*)
            FROM messages mm
            LEFT JOIN message_reads mr
            ON mr.conversation_id = c.id AND mr.user_id = $1
            WHERE mm.conversation_id = c.id
            AND mm.sender_id <> $1
            AND (mr.last_read_at IS NULL OR mm.created_at > mr.last_read_at)
            ) AS unread_count
            FROM conversations c
            JOIN users u1 ON u1.id = c.participant_one
            JOIN users u2 ON u2.id = c.participant_two
            LEFT JOIN LATERAL (
            SELECT content, created_at
            FROM messages
            WHERE conversation_id = c.id
            ORDER BY created_at DESC
            LIMIT 1
            ) m ON true
            WHERE c.participant_one = $1 OR c.participant_two = $1
            ORDER BY m.created_at DESC NULLS LAST;           
            `,
            [userId]
        );

        console.log('Found conversations:', result.rows.length);

        const conversations = result.rows.map(row => ({
            ...row,
            participant_profile_image: row.participant_profile_image
                ? `${process.env.BASE_URL}/uploads/profiles/${row.participant_profile_image}`
                : null
        }));

        res.json(conversations);
    } catch (e) {
        console.error('Fetch conversations error:', e);
        res.status(500).json({ error: 'Failed to fetch conversation' });
    }
}

export const checkOrCreateConvesation = async (req: Request, res: Response): Promise<any> => {
    const userId = (req as AuthRequest).user?.id; 


    const { contactId } = req.body;

    console.log('Check/create conversation:', { userId, contactId });

    try {
        const existingConversation = await pool.query(
            `
            SELECT id FROM conversations
            WHERE (participant_one = $1 AND participant_two = $2)
            OR (participant_one = $2 AND participant_two = $1)
            LIMIT 1;
            `,
            [userId, contactId]
        );

        if (existingConversation.rowCount != null && existingConversation.rowCount! > 0) {
            console.log('Existing conversation found:', existingConversation.rows[0].id);
            return res.json({ conversationId: existingConversation.rows[0].id });
        }

        const newConversation = await pool.query(
            `
            INSERT INTO conversations (participant_one, participant_two)
            VALUES ($1, $2)
            RETURNING id;            
            `,
            [userId, contactId]
        );

        console.log('New conversation created:', newConversation.rows[0].id);
        res.json({ conversationId: newConversation.rows[0].id });
    } catch (error) {
        console.error('Check/create conversation error:', error);
        res.status(500).json({ error: 'Failed to check or create conversation' });
    }
}

export const getDailyQuestion = async (req: Request, res: Response): Promise<any> => {
    const conversationId = req.params.id;

    console.log('Get daily question for conversation:', conversationId);

    try {
        const result = await pool.query(
            `
            SELECT content FROM messages
            WHERE conversation_id = $1 AND sender_id = $2     
            ORDER BY created_at DESC
            LIMIT 1       
            `,
            [conversationId, AI_BOT_ID]
        );

        if (result.rowCount === 0) {
            console.log('No daily question found');
            return res.status(404).json({ error: 'No daily question found' });
        }

        res.json({ question: result.rows[0].content });
    } catch (error) {
        console.error('Error fetching daily question:', error);
        res.status(500).json({ error: 'Failed to fetch daily question' });
    }
}

export const deleteConversation = async (req: Request, res: Response) => {
    const { id } = req.params;

    console.log('Delete conversation:', id);

    try {
        await pool.query(
            "DELETE FROM messages WHERE conversation_id = $1",
            [id]
        );

        await pool.query(
            "DELETE FROM conversations WHERE id = $1",
            [id]
        );

        console.log('Conversation deleted:', id);
        return res.status(200).json({ message: "Conversation deleted" });
    } catch (e) {
        console.error("Delete conversation error:", e);
        return res.status(500).json({ error: "Failed to delete conversation" });
    }
};

export const markConversationRead = async (req: Request, res: Response) => {
    const userId = (req as AuthRequest).user?.id; 

    const conversationId = req.params.id;

    if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
    }

    try {
        const latest = await pool.query(
            `
            SELECT id, created_at FROM messages WHERE conversation_id = $1 ORDER BY created_at DESC LIMIT 1`,
            [conversationId]
        );
        const latestMessageId = latest.rowCount ? latest.rows[0].id : null;
        
        await pool.query(
            `
            INSERT INTO message_reads (user_id, conversation_id, last_read_at, last_read_message_id)
            VALUES ($1, $2, now(), $3)
            ON CONFLICT (user_id, conversation_id)
            DO UPDATE SET
              last_read_at = EXCLUDED.last_read_at,
              last_read_message_id = EXCLUDED.last_read_message_id
            `,
            [userId, conversationId, latestMessageId]
        );

        return res.status(200).json({ ok: true });

    } catch (e) {
        console.error('markConversationRead error:', e);
        return res.status(500).json({ error: 'Failed to mark conversation as read' });
    }
};
