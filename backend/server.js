require('dotenv').config();
const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const authRoutes = require("./routes/authRoutes");
const busRoutes = require("./routes/busRoutes");

dotenv.config();
const app = express();

app.use(express.json());
app.use(cors());

app.use("/api/auth", authRoutes);
app.use("/api/bus", busRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
