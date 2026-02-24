const Alert = require('../models/model alerts');
const Reading = require('../models/model reading');
const Sensor = require('../models/model sensor');

// =========================
// GET user alerts
// =========================
exports.getUserAlerts = async (req, res) => {
  try {
    const { userId } = req.params;

    const alerts = await Alert.findAll({
      include: [{
        model: Reading,
        include: [{
          model: Sensor,
          where: { userId }
        }]
      }],
      order: [['createdAt', 'DESC']]
    });

    res.status(200).json(alerts);
  } catch (error) {
    res.status(500).json({
      message: 'Error fetching alerts',
      error: error.message
    });
  }
};

// =========================
// PATCH resolve alert
// =========================
exports.resolveAlert = async (req, res) => {
  try {
    const { id } = req.params;

    const alert = await Alert.findByPk(id);

    // Defensive programming (you were missing this)
    if (!alert) {
      return res.status(404).json({ message: 'Alert not found' });
    }

    // Prevent double-resolution (important)
    if (alert.status === 'resolved') {
      return res.status(400).json({ message: 'Alert already resolved' });
    }

    alert.status = 'resolved';
    alert.resolvedAt = new Date(); // optional but smart
    await alert.save();

    res.status(200).json({
      message: 'Alert resolved successfully',
      alert
    });

  } catch (error) {
    res.status(500).json({
      message: 'Error resolving alert',
      error: error.message
    });
  }
};