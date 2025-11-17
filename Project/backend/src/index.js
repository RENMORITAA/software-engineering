import express from "express";
import mysql from "mysql2/promise";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

const pool = mysql.createPool({
  host: "db",
  user: "app",
  password: "apppass",
  database: "appdb"
});

app.get("/", (req, res) => {
  res.json({ message: "API is running!" });
});

app.get("/users", async (req, res) => {
  const [rows] = await pool.query("SELECT * FROM users");
  res.json(rows);
});

app.listen(8000, () => {
  console.log("API running on http://localhost:8000");
});
