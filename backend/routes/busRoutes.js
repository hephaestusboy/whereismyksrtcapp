const router = require('express').Router();
const auth = require('../middleware/auth');
const pool = require('../db/db');

// Search buses by departure and arrival points
router.get('/search', auth, async (req, res) => {
    try {
        const { departurePoint, arrivalPoint } = req.query;

        const buses = await pool.query(
            `SELECT * FROM buses 
             WHERE departure_point ILIKE $1 
             AND arrival_point ILIKE $2`,
            [`%${departurePoint}%`, `%${arrivalPoint}%`]
        );

        res.json(buses.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
});

// Get bus location
router.get('/location', auth, async (req, res) => {
    try {
        const { busId } = req.query;
        
        const location = await pool.query(
            'SELECT * FROM bus_locations WHERE bus_id = $1',
            [busId]
        );

        if (location.rows.length === 0) {
            return res.status(404).json({ message: 'Bus location not found' });
        }

        res.json(location.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
});

// Update bus location
router.post('/update-location', auth, async (req, res) => {
    try {
        const { busId, latitude, longitude } = req.body;

        const updatedLocation = await pool.query(
            `INSERT INTO bus_locations (bus_id, latitude, longitude) 
             VALUES ($1, $2, $3)
             ON CONFLICT (bus_id) 
             DO UPDATE SET latitude = $2, longitude = $3, updated_at = CURRENT_TIMESTAMP
             RETURNING *`,
            [busId, latitude, longitude]
        );

        res.json(updatedLocation.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
});

module.exports = router; 