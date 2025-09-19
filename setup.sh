#!/bin/bash
# 🚀 ClimateLens Auto-Setup Script (Full Code Included)

# Create root
mkdir climatelens && cd climatelens

#############################################
# BACKEND
#############################################
echo "📦 Setting up backend..."
mkdir backend && cd backend
npm init -y > /dev/null
npm install express dotenv cors node-fetch > /dev/null

# server.js
cat > server.js << 'EOF'
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
EOF

# .env
cat > .env << 'EOF'
OPENWEATHER_API=your_openweathermap_api_key
AQI_API=your_iqair_api_key
OPENAI_API=your_openai_api_key
EOF
cd ..

#############################################
# FRONTEND
#############################################
echo "📦 Setting up frontend..."
npm create vite@latest frontend -- --template react
cd frontend
npm install
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# tailwind.config.js
cat > tailwind.config.js << 'EOF'
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: { extend: {} },
  plugins: [],
};
EOF

# index.css
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

# App.jsx
cat > src/App.jsx << 'EOF'
import React, { useState, useEffect } from "react";
import WeatherCard from "./components/WeatherCard";
import AirQualityCard from "./components/AirQualityCard";
import AISummary from "./components/AISummary";

function App() {
  const [city, setCity] = useState("London");
  const [weather, setWeather] = useState(null);
  const [airQuality, setAirQuality] = useState(null);
  const [summary, setSummary] = useState("");
  const [demoMode, setDemoMode] = useState(false);

  // Mock data
  const mockWeather = {
    main: { temp: 22, humidity: 65 },
    weather: [{ description: "clear sky" }],
    coord: { lat: 51.5074, lon: -0.1278 }
  };
  const mockAQI = {
    data: { city: "London", current: { pollution: { aqius: 42 } } }
  };

  useEffect(() => {
    if (demoMode) {
      setWeather(mockWeather);
      setAirQuality(mockAQI);
      return;
    }

    fetch("http://localhost:5000/api/weather?city=" + city)
      .then((res) => res.json())
      .then((data) => {
        setWeather(data);
        if (data.coord) {
          fetch(`http://localhost:5000/api/airquality?lat=${data.coord.lat}&lon=${data.coord.lon}`)
            .then((res) => res.json())
            .then((aqi) => setAirQuality(aqi));
        }
      });
  }, [city, demoMode]);

  const generateSummary = async () => {
    if (demoMode) {
      setSummary("Today’s weather is clear with mild temperature and healthy air quality. It’s a great day for outdoor activities!");
      return;
    }

    const response = await fetch("http://localhost:5000/api/ai-summary", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        text: `Weather: ${JSON.stringify(weather)}, Air Quality: ${JSON.stringify(airQuality)}`
      })
    });
    const result = await response.json();
    setSummary(result.summary);
  };

  return (
    <div className="p-6 bg-gray-100 min-h-screen">
      <h1 className="text-3xl font-bold mb-4">🌍 ClimateLens Dashboard</h1>

      {/* Demo Mode Toggle */}
      <button
        onClick={() => setDemoMode(!demoMode)}
        className={\`mb-4 px-4 py-2 rounded \${demoMode ? "bg-yellow-500 text-white" : "bg-blue-500 text-white"}\`}
      >
        {demoMode ? "🔄 Switch to Live Mode" : "🧪 Switch to Demo Mode"}
      </button>

      <input
        className="border p-2 mb-4 block"
        value={city}
        onChange={(e) => setCity(e.target.value)}
        placeholder="Enter city"
        disabled={demoMode}
      />

      <div className="grid grid-cols-2 gap-4">
        {weather && <WeatherCard data={weather} />}
        {airQuality && <AirQualityCard data={airQuality} />}
      </div>

      <button
        onClick={generateSummary}
        className="mt-4 bg-green-500 text-white px-4 py-2 rounded"
      >
        Generate AI Summary
      </button>

      {summary && <AISummary text={summary} />}

      {demoMode && (
        <p className="mt-2 text-red-600">
          ⚠️ Demo Mode Active — showing mock London data.
        </p>
      )}
    </div>
  );
}

export default App;
EOF

# Components
mkdir -p src/components
cat > src/components/WeatherCard.jsx << 'EOF'
import React from "react";

export default function WeatherCard({ data }) {
  return (
    <div className="bg-white p-4 shadow rounded">
      <h2 className="font-bold text-xl">Weather</h2>
      <p>🌡 Temp: {data.main.temp} °C</p>
      <p>☁ Condition: {data.weather[0].description}</p>
      <p>💧 Humidity: {data.main.humidity}%</p>
    </div>
  );
}
EOF

cat > src/components/AirQualityCard.jsx << 'EOF'
import React from "react";

export default function AirQualityCard({ data }) {
  return (
    <div className="bg-white p-4 shadow rounded">
      <h2 className="font-bold text-xl">Air Quality</h2>
      <p>📍 City: {data.data.city}</p>
      <p>🟢 AQI: {data.data.current.pollution.aqius}</p>
    </div>
  );
}
EOF

cat > src/components/AISummary.jsx << 'EOF'
import React from "react";

export default function AISummary({ text }) {
  return (
    <div className="bg-yellow-100 p-4 mt-4 rounded">
      <h2 className="font-bold text-xl">AI Summary</h2>
      <p>{text}</p>
    </div>
  );
}
EOF

cd ..

echo "✅ ClimateLens setup complete!"
echo "👉 Next steps:"
echo "1. cd backend && node server.js"
echo "2. cd frontend && npm run dev"
echo "3. Visit http://localhost:5173"
