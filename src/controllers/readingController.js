const Reading = require('../models/model reading');
const Sensor = require('../models/model sensor');
const Alert = require('../models/model alerts');

exports.uploadReading = async (req, res) => {
    try {
        const { api_key, ph, turbidity, temperature, tds, dissolved_oxygen } = req.body;

        const sensor = await Sensor.findOne({ where: { api_key } });
        if (!sensor) return res.status(401).json({ message: "Invalid API Key" });

        // --- Intelligence: Define the Advisory Messages from the Handoff Doc ---
        let phMsg = "";
        if (ph < 6.5) phMsg = "LOW, The water is acidic, treat with alkaline solution to neutralise it"; // [cite: 7]
        else if (ph <= 8.5) phMsg = "MEDIUM / OPTIMUM, The water is ideal and safe for use"; // [cite: 10]
        else phMsg = "HIGH, The water is alkaline, treat with acidic solution to neutralize it"; // [cite: 13]

        let turbMsg = "";
        if (turbidity <= 5) turbMsg = "LOW / OPTIMUM, The water is safe and good for use"; // [cite: 16]
        else if (turbidity <= 50) turbMsg = "MEDIUM, The water is slightly turbid. Apply coagulation, sedimentation and filtration"; // [cite: 18]
        else turbMsg = "HIGH, The water is dangerous. Do not use without treatment"; // [cite: 20]
        
        let doMsg = "";
        if (dissolved_oxygen < 5) doMsg = "LOW, Poor water quality. Improve aeration"; // [cite: 23]
        else if (dissolved_oxygen <= 6.5) doMsg = "MEDIUM, Acceptable but monitor freshness"; // [cite: 25]
        else if (dissolved_oxygen <= 8) doMsg = "HIGH, Water is fresh and fit for consumption"; // [cite: 28]
        else doMsg = "VERY HIGH, May increase corrosion risk. Degasify"; // [cite: 30]

        // 1. Save the Reading to Database
        const newReading = await Reading.create({
            sensorId: sensor.id,
            ph, turbidity, temperature, tds, dissolved_oxygen
        });

        // 2. Memory: Auto-generate Alert if quality is not OPTIMUM
        if (ph < 6.5 || ph > 8.5 || turbidity > 5 || dissolved_oxygen < 5) {
            await Alert.create({
                ReadingId: newReading.id,
                severity: (turbidity > 50 || ph < 5) ? "CRITICAL" : "WARNING",
                message: `Issue Detected: pH is ${ph}, Turbidity is ${turbidity}. Advisory: ${phMsg}`
            });
        }

        // 3. Response: Return the "Intelligence" to the user
        res.status(201).json({
            message: "Data analyzed and recorded",
            PH: { value: ph, result: phMsg }, // Now the long explanation is back!
            Turbidity: { value: turbidity, result: turbMsg },
            Dissolved_Oxygen: { value: dissolved_oxygen, result: doMsg }
        });

    } catch (error) {
        res.status(500).json({ message: "Error", error: error.message });
    }
};
