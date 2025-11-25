import { Router } from "express";
import { verifyToken } from "../middlewares/authMiddleware";
import { fetchAllMessagessByConversationId } from "../controllers/messageController";


const router = Router();

router.get('/:conversationId', verifyToken, fetchAllMessagessByConversationId);

export default router;