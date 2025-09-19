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

  // Mock data for Demo Mode
  const mockWeather = {
    main: { temp: 22, humidity: 65 },
    weather: [{ description: "clear sky" }],
    coord: { lat: 51.5074, lon: -0.1278 },
  };
  const mockAQI = {
    data: { city: "London", current: { pollution: { aqius: 42 } } },
  };

  useEffect(() => {
    if (demoMode) {
      setWeather(mockWeather);
      setAirQuality(mockAQI);
      return;
    }

    // Fetch weather
    fetch(`http://localhost:5000/api/weather?city=${city}`)
      .then((res) => res.json())
      .then((data) => {
        setWeather(data);
        if (data.coord) {
          // Fetch AQI using coordinates
          fetch(
            `http://localhost:5000/api/airquality?lat=${data.coord.lat}&lon=${data.coord.lon}`
          )
            .then((res) => res.json())
            .then((aqi) => setAirQuality(aqi));
        }
      });
  }, [city, demoMode]);

  const generateSummary = async () => {
    if (demoMode) {
      setSummary(
        "Today’s weather is clear with mild temperature and healthy air quality. It’s a great day for outdoor activities!"
      );
      return;
    }

    const response = await fetch("http://localhost:5000/api/ai-summary", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        text: `Weather: ${JSON.stringify(
          weather
        )}, Air Quality: ${JSON.stringify(airQuality)}`,
      }),
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
        className={`mb-4 px-4 py-2 rounded ${
          demoMode ? "bg-yellow-500 text-white" : "bg-blue-500 text-white"
        }`}
      >
        {demoMode ? "🔄 Switch to Live Mode" : "🧪 Switch to Demo Mode"}
      </button>

      {/* City Input */}
      <input
        className="border p-2 mb-4 block"
        value={city}
        onChange={(e) => setCity(e.target.value)}
        placeholder="Enter city"
        disabled={demoMode}
      />

      {/* Data Cards */}
      <div className="grid grid-cols-2 gap-4">
        {weather && <WeatherCard data={weather} />}
        {airQuality && <AirQualityCard data={airQuality} city={city} />}
      </div>

      {/* AI Summary */}
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
