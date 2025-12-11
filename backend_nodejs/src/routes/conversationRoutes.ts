import { Router } from "express";
import { verifyToken } from "../middlewares/authMiddleware";
import { checkOrCreateConvesation, deleteConversation, fetchAllConversationsByUserId, getDailyQuestion, markConversationRead } from "../controllers/conversationController";

const router = Router();

router.get('/', verifyToken, fetchAllConversationsByUserId);
router.post('/check-or-create', verifyToken, checkOrCreateConvesation);
router.post('/:id/daily-question', verifyToken, getDailyQuestion);
router.delete('/:id', verifyToken, deleteConversation);
router.put('/:id/read', verifyToken, markConversationRead);



export default router;