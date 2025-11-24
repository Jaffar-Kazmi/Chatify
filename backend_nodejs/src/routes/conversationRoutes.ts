import { Router } from "express";
import { verifyToken } from "../middlewares/authMiddleware";
import { fetchAllConversationsByUserId } from "../controllers/conversationController";

const router = Router();

router.get('/', verifyToken, fetchAllConversationsByUserId);

export default router;