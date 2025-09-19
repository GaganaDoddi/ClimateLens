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
