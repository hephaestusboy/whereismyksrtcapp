const express = require('express');
const router = express.Router();

// Bus routes
router.get('/location', async (req, res) => {
    // Get bus location logic
});

router.post('/update-location', async (req, res) => {
    // Update bus location logic
});

module.exports = router; 