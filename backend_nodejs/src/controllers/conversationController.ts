import { Request , Response } from "express";
import pool from "../models/db";

export const fetchAllConversationsByUserId = async (req: Request, res: Response) => {
    let userId = null;
    if (req.user) {
        userId = req.user.id;
    }

    try{
        const result = await pool.query(
            `
            SELECT 
                c.id AS conversation_id,
                CASE 
                    WHEN u1.id = $1 THEN u2.username
                    ELSE u1.username
                END AS participant_name,
                m.content AS last_message,
                m.created_at AS last_message_time
            FROM conversations c
            JOIN users u1 ON u1.id = c.participant_one
            JOIN users u2 ON u2.id = c.participant_two
            LEFT JOIN LATERAL (
                SELECT content, created_at
                FROM messages
                WHERE conversation_id = c.id
                ORDER by created_at desc
                LIMIT 1            
            ) m ON true
            WHERE c.participant_one = $1 or c.participant_two = $1
            ORDER by m.created_at DESC;            
            `,
             [userId]            
        );

        res.json(result.rows);
    } catch (e) {
        res.status(500).json({error: 'Failed to fetch conversation'});
    }
}