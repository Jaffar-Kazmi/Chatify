import { Router } from "express";
import { verifyToken } from "../middlewares/authMiddleware";
import { createMessage, fetchAllMessagessByConversationId } from "../controllers/messageController";

const router = Router();

router.get('/:conversationId', verifyToken, fetchAllMessagessByConversationId);
router.post('/', verifyToken, createMessage);

export default router;