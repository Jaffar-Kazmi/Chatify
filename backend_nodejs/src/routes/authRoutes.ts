import { Router } from "express";
import { register, login, changePassword } from "../controllers/authController";
import { verifyToken } from "../middlewares/authMiddleware";


const router = Router();

router.post('/register', register);
router.post('/login', login);
router.put('/change-password', verifyToken, changePassword);

export default router;