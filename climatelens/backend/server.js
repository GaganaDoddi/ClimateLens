import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import fetch from "node-fetch";

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

const WEATHER_API = "https://api.openweathermap.org/data/2.5/weather";
const AQI_API = "http://api.airvisual.com/v2/nearest_city";

// Mock seed data
const mockWeather = {
  main: { temp: 22, humidity: 65 },
  weather: [{ description: "clear sky" }],
  coord: { lat: 51.5074, lon: -0.1278 }
};

const mockAQI = {
  data: {
    city: "London",
    current: { pollution: { aqius: 42 } }
  }
};

// Weather endpoint
app.get("/api/weather", async (req, res) => {
  const { city } = req.query;
  try {
    const response = await fetch(
      `${WEATHER_API}?q=${city}&appid=${process.env.OPENWEATHER_API}&units=metric`
    );
    if (!response.ok) throw new Error("API failed");
    const data = await response.json();
    res.json(data);
  } catch {
    console.log("⚠️ Using seed weather data");
    res.json(mockWeather);
  }
});

// Air Quality endpoint
app.get("/api/airquality", async (req, res) => {
  const { lat, lon } = req.query;
  try {
    const response = await fetch(
      `${AQI_API}?lat=${lat}&lon=${lon}&key=${process.env.AQI_API}`
    );
    if (!response.ok) throw new Error("API failed");
    const data = await response.json();
    res.json(data);
  } catch {
    console.log("⚠️ Using seed air quality data");
    res.json(mockAQI);
  }
});

// AI Summary endpoint
app.post("/api/ai-summary", async (req, res) => {
  const { text } = req.body;
  try {
    const aiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.OPENAI_API}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: `Summarize this climate data for students: ${text}` }]
      })
    });

    if (!aiResponse.ok) throw new Error("AI API failed");
    const result = await aiResponse.json();
    res.json({ summary: result.choices[0].message.content });
  } catch {
    console.log("⚠️ Using seed AI summary");
    res.json({
      summary: "Today’s weather is clear with mild temperature and healthy air quality. It’s a great day for outdoor activities!"
    });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🌍 Backend running on port ${PORT}`));
