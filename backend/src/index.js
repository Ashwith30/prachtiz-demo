require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const authRoutes        = require('./routes/auth.routes');
const publicRoutes      = require('./routes/public.routes');
const doctorRoutes      = require('./routes/doctor.routes');
const receptionistRoutes = require('./routes/receptionist.routes');
const patientRoutes     = require('./routes/patient.routes');
const { router: consultationRoutes, rooms } = require('./routes/consultation.routes');

const app = express();
const server = http.createServer(app);

// ── Socket.IO setup ───────────────────────────────────────────────────────────
const io = new Server(server, {
  cors: {
    origin: true,
    methods: ['GET', 'POST'],
    credentials: true,
  },
});

// Track socket -> roomId mapping for cleanup
const socketRooms = new Map();

io.on('connection', (socket) => {
  console.log(`🔌 Socket connected: ${socket.id}`);

  // Join a consultation room
  socket.on('join-room', ({ roomId, peerId, role }) => {
    const room = rooms.get(roomId);
    if (!room || !room.active) {
      socket.emit('error', { message: 'Room not found or has ended' });
      return;
    }

    socket.join(roomId);
    socketRooms.set(socket.id, roomId);

    if (!room.participants.includes(socket.id)) {
      room.participants.push(socket.id);
    }

    console.log(`👥 ${role || 'peer'} (${socket.id}) joined room ${roomId}`);

    // Notify others in the room
    socket.to(roomId).emit('peer-joined', { peerId: socket.id, role });

    // Send current participants back to joiner
    socket.emit('room-joined', {
      roomId,
      participantCount: room.participants.length,
      participants: room.participants.filter(id => id !== socket.id),
    });
  });

  // WebRTC offer → relay to specific peer or whole room
  socket.on('offer', ({ roomId, offer, targetId }) => {
    console.log(`📡 Offer from ${socket.id} in room ${roomId}`);
    if (targetId) {
      io.to(targetId).emit('offer', { offer, fromId: socket.id });
    } else {
      socket.to(roomId).emit('offer', { offer, fromId: socket.id });
    }
  });

  // WebRTC answer → relay back to offerer
  socket.on('answer', ({ roomId, answer, targetId }) => {
    console.log(`📡 Answer from ${socket.id} in room ${roomId}`);
    if (targetId) {
      io.to(targetId).emit('answer', { answer, fromId: socket.id });
    } else {
      socket.to(roomId).emit('answer', { answer, fromId: socket.id });
    }
  });

  // ICE candidate → relay to specific peer or whole room
  socket.on('ice-candidate', ({ roomId, candidate, targetId }) => {
    if (targetId) {
      io.to(targetId).emit('ice-candidate', { candidate, fromId: socket.id });
    } else {
      socket.to(roomId).emit('ice-candidate', { candidate, fromId: socket.id });
    }
  });

  // Explicit leave
  socket.on('leave-room', ({ roomId }) => {
    _handleLeave(socket, roomId);
  });

  // Disconnect cleanup
  socket.on('disconnect', () => {
    const roomId = socketRooms.get(socket.id);
    if (roomId) _handleLeave(socket, roomId);
    console.log(`🔌 Socket disconnected: ${socket.id}`);
  });

  function _handleLeave(socket, roomId) {
    socket.leave(roomId);
    socketRooms.delete(socket.id);
    const room = rooms.get(roomId);
    if (room) {
      room.participants = room.participants.filter(id => id !== socket.id);
    }
    socket.to(roomId).emit('peer-left', { peerId: socket.id });
    console.log(`🚪 ${socket.id} left room ${roomId}`);
  }
});

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), service: 'Prachtiz API' });
});

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth',         authRoutes);
app.use('/api/public',       publicRoutes);
app.use('/api/doctor',       doctorRoutes);
app.use('/api/receptionist', receptionistRoutes);
app.use('/api/patient',      patientRoutes);
app.use('/api/consultation', consultationRoutes);

// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: `Route not found: ${req.method} ${req.path}` });
});

// ── Global error handler ──────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// ── Start server ──────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`\n🏥 Prachtiz API running on http://localhost:${PORT}`);
  console.log(`   Health check: http://localhost:${PORT}/health`);
  console.log(`   🎥 WebRTC Signaling: ws://localhost:${PORT}\n`);
});

module.exports = app;

