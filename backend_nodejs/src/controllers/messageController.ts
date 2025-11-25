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

export const saveMessage = async (conversation_id: string, sender_id: string, content: string) => {
    try {
        const result = await pool.query(
            `
            INSERT INTO messages (conversation_id, sender_id, content)
            VALUES ($1, $2, $3)
            RETURNING *;
            `,
            [conversation_id, sender_id, content]
        );

        return result.rows[0];
    } catch (err) {
        console.error('Error saving messade: ', err);
        throw new Error('Failed to save to message');
    }

}