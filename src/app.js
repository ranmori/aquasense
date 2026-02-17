const express = require("express");
const app = express();
require("dotenv").config();

// Middleware to read JSON
app.use(express.json());

// Health check (NO AUTH)
app.get("/health", (req, res) => {
  res.json({ status: "API running" });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
