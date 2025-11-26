import { Router } from "express";
import { verifyToken } from "../middlewares/authMiddleware";
import { checkOrCreateConvesation, fetchAllConversationsByUserId } from "../controllers/conversationController";

const router = Router();

router.get('/', verifyToken, fetchAllConversationsByUserId);
router.post('/check-or-create', verifyToken, checkOrCreateConvesation);


export default router;