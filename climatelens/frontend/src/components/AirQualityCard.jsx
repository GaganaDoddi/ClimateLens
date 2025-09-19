import React from "react";

export default function AirQualityCard({ data, city }) {
  return (
    <div className="bg-white p-4 shadow rounded">
      <h2 className="font-bold text-xl">Air Quality</h2>
      <p>📍 City: {city}</p> {/* force display from input */}
      <p>🟢 AQI: {data.data.current.pollution.aqius}</p>
    </div>
  );
}
