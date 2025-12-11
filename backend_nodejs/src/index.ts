import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import cors from 'cors';
import path from 'path';
import http from 'http';
import { Server } from 'socket.io';
import pool from './models/db'; // Import your database pool

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

app.use(cors({ origin: '*', credentials: true }));
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

import authRoutes from './routes/authRoutes';
import profileRoutes from './routes/profileRoutes';
import conversationRoutes from './routes/conversationRoutes';
import messageRoutes from './routes/messageRoutes';
import contactRoutes from './routes/contactRoutes';

app.use('/auth', authRoutes);
app.use('/profile', profileRoutes);
app.use('/conversations', conversationRoutes);
app.use('/messages', messageRoutes);
app.use('/contacts', contactRoutes);

app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    environment: process.env.NODE_ENV,
    baseUrl: process.env.BASE_URL,
    host: process.env.HOST,
    port: process.env.PORT
  });
});

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('joinConversation', (conversationId) => {
    socket.join(conversationId);
    console.log(`User ${socket.id} joined conversation ${conversationId}`);
  });

  socket.on('sendMessage', async (data) => {
    console.log('Received sendMessage:', data);
    
    const { conversationId, senderId, content } = data;

    // Validate required fields
    if (!conversationId || !senderId || !content) {
      console.error('Missing required fields in sendMessage');
      socket.emit('error', { message: 'Missing required fields' });
      return;
    }

    try {
      // Save message to database
      const result = await pool.query(
        `
        INSERT INTO messages (conversation_id, sender_id, content)
        VALUES ($1, $2, $3)
        RETURNING id, content, sender_id, conversation_id, created_at;
        `,
        [conversationId, senderId, content]
      );

      const savedMessage = result.rows[0];
      console.log('Message saved to database:', savedMessage);

      // Broadcast the COMPLETE message (with id and created_at from DB)
      io.to(conversationId).emit('newMessage', {
        id: savedMessage.id,
        conversation_id: savedMessage.conversation_id,
        sender_id: savedMessage.sender_id,
        content: savedMessage.content,
        created_at: savedMessage.created_at
      });

      console.log(`Message broadcasted to conversation ${conversationId}`);

    } catch (error) {
      console.error('Error saving message to database:', error);
      socket.emit('error', { message: 'Failed to save message' });
    }
  });

  socket.on('leaveConversation', (conversationId) => {
    socket.leave(conversationId);
    console.log(`User ${socket.id} left conversation ${conversationId}`);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = parseInt(process.env.PORT || '3000', 10);
const HOST = process.env.HOST || '0.0.0.0';

server.listen(PORT, HOST, () => {
  console.log(`Server: http://${HOST}:${PORT}`);
});

export { io };