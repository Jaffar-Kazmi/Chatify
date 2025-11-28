import { Request , Response } from "express";
import pool from "../models/db";
import { AI_BOT_ID } from "../config";

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
                CASE
                    WHEN u1.id = $1 THEN 
                      CASE 
                        WHEN u2.profile_image IS NOT NULL 
                        THEN 'http://localhost:3000/uploads/profiles/' || u2.profile_image 
                        ELSE NULL 
                      END
                    ELSE 
                      CASE 
                        WHEN u1.profile_image IS NOT NULL 
                        THEN 'http://localhost:3000/uploads/profiles/' || u1.profile_image 
                        ELSE NULL 
                      END
                END AS participant_profile_image,
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

export const checkOrCreateConvesation = async (req: Request, res: Response): Promise<any> => {
    let userId = null;
    if (req.user) {
        userId = req.user.id;
    }

    const{contactId} = req.body

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

        if(existingConversation.rowCount != null && existingConversation.rowCount! > 0) {
            return res.json({conversationId: existingConversation.rows[0].id});
        }

        const newConversation = await pool.query(
            `
            INSERT INTO conversations (participant_one, participant_two)
            VALUES ($1, $2)
            RETURNING id;            
            `,
            [userId, contactId]
        );

        res.json({conversationId: new newConversation.rows[0].id})
    } catch (error) {
        res.status(500).json({error: 'Failed to check or create conversation'})
    }
}

export const getDailyQuestion = async (req: Request, res: Response): Promise<any>  => {
    const conversationId = req.params.id;

    try{

        const result = await pool.query(
            `
            SELECT content FROM messages
            WHERE conversation_id = $1 AND sender_id = $2     
            ORDER BY created_at DESC
            LIMIT 1       
            `,
            [conversationId, AI_BOT_ID]
        )

        if (result.rowCount === 0) {
            return res.status(404).json({error: 'No daily question found'});
        }

        res.json({question: result.rows[0].content});

    } catch (error) {
        console.error('Error fetching daily question: ', error);
        res.status(500).json({error: 'Failed to fetch daily question'});
    }
}

export const deleteConversation = async (req: Request, res: Response) => {
  const { id } = req.params; // conversationId

  try {
    // delete messages first (FK constraint)
    await pool.query(
      "DELETE FROM messages WHERE conversation_id = $1",
      [id]
    );

    // delete conversation
    await pool.query(
      "DELETE FROM conversations WHERE id = $1",
      [id]
    );

    return res.status(200).json({ message: "Conversation deleted" });
  } catch (e) {
    console.error("Delete conversation error:", e);
    return res
      .status(500)
      .json({ error: "Failed to delete conversation" });
  }
};