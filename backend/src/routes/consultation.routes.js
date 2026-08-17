const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// In-memory room store (use Redis for multi-server production)
const rooms = new Map(); // roomId -> { id, host, participants[], createdAt, appointmentId, active }

// POST /api/consultation/room — create a consultation room
router.post('/room', authenticate, (req, res) => {
  const { appointment_id } = req.body;
  const roomId = uuidv4();
  rooms.set(roomId, {
    id: roomId,
    host: req.user.id,
    participants: [],
    createdAt: new Date().toISOString(),
    appointmentId: appointment_id || null,
    active: true,
  });
  return res.status(201).json({ roomId, joinUrl: `/consultation?room=${roomId}` });
});

// GET /api/consultation/room/:roomId — get room info
router.get('/room/:roomId', authenticate, (req, res) => {
  const room = rooms.get(req.params.roomId);
  if (!room) return res.status(404).json({ error: 'Room not found' });
  return res.json({
    roomId: room.id,
    host: room.host,
    participantCount: room.participants.length,
    createdAt: room.createdAt,
    appointmentId: room.appointmentId,
    active: room.active,
  });
});

// PATCH /api/consultation/room/:roomId/end — end a session
router.patch('/room/:roomId/end', authenticate, (req, res) => {
  const room = rooms.get(req.params.roomId);
  if (!room) return res.status(404).json({ error: 'Room not found' });
  if (room.host !== req.user.id) return res.status(403).json({ error: 'Only the host can end the session' });
  room.active = false;
  return res.json({ roomId: room.id, ended: true });
});

module.exports = { router, rooms };
