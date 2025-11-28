import { Router } from "express";
import { verifyToken } from "../middlewares/authMiddleware";
import { checkOrCreateConvesation, deleteConversation, fetchAllConversationsByUserId, getDailyQuestion } from "../controllers/conversationController";

const router = Router();

router.get('/', verifyToken, fetchAllConversationsByUserId);
router.post('/check-or-create', verifyToken, checkOrCreateConvesation);
router.post('/:id/daily-question', verifyToken, getDailyQuestion);
router.delete('/:id', verifyToken, deleteConversation);



export default router;