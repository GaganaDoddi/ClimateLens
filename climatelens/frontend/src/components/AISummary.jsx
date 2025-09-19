import React from "react";

export default function AISummary({ text }) {
  return (
    <div className="bg-yellow-100 p-4 mt-4 rounded">
      <h2 className="font-bold text-xl">AI Summary</h2>
      <p>{text}</p>
    </div>
  );
}
