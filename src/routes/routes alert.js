console.log('🔥 routes alert.js LOADED');
const express = require('express');
const router = express.Router();
const alertController = require('../controllers/alertController');
const { protect } = require('../middleware/authMiddleware');

// Get alerts for a user
router.get('/user/:userId', protect, alertController.getUserAlerts);

// ✅ Resolve an alert
router.patch('/resolve/:id', protect, alertController.resolveAlert);

module.exports = router;