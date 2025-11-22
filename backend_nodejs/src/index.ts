import express from "express";
import { json } from "body-parser";
import authRoutes from './routes/authRoutes';

const app = express();

app.use(json());

app.use('/auth', authRoutes);


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`);
})