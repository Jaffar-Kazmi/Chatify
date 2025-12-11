import { Server, Socket } from 'socket.io';
import pool from '../models/db';

export const setupSocketHandlers = (io: Server) => {
  // Middleware to authenticate socket connections
  io.use((socket, next) => {
    const token = socket.handshake.headers.authorization;
    
    if (!token) {
      return next(new Error('Authentication error'));
    }
    
    // You can add JWT verification here if needed
    // For now, just allow the connection
    next();
  });

  io.on('connection', (socket: Socket) => {
    console.log('User connected:', socket.id);

    // User joins a conversation room
    socket.on('joinConversation', (conversationId: string) => {
      socket.join(conversationId);
      console.log(`Socket ${socket.id} joined conversation: ${conversationId}`);
    });

    // Handle incoming messages
    socket.on('sendMessage', async (data: any) => {
      console.log('Received sendMessage:', data);
      
      const { conversationId, senderId, content } = data;

      // Validate required fields
      if (!conversationId || !senderId || !content) {
        console.error('Missing required fields');
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

        // Broadcast the saved message to all users in the conversation
        io.to(conversationId).emit('newMessage', {
          id: savedMessage.id,
          conversation_id: savedMessage.conversation_id,
          sender_id: savedMessage.sender_id,
          content: savedMessage.content,
          created_at: savedMessage.created_at
        });

        console.log('Message broadcasted to room:', conversationId);

      } catch (error) {
        console.error('Error saving message:', error);
        socket.emit('error', { message: 'Failed to save message' });
      }
    });

    // Handle user leaving conversation
    socket.on('leaveConversation', (conversationId: string) => {
      socket.leave(conversationId);
      console.log(`Socket ${socket.id} left conversation: ${conversationId}`);
    });

    socket.on('disconnect', () => {
      console.log('User disconnected:', socket.id);
    });
  });
};