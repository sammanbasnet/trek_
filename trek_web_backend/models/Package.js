const mongoose = require("mongoose");

const packageSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: { type: String, required: true },
    location: { type: String, required: true },
    price: { type: Number, required: true },
    duration: { type: String, required: true },
    image: { type: String, required: true },
    availableDates: [{ type: Date, required: true }],
    category: { type: String, required: true, enum: ["Adventure", "Luxury", "Budget"] },
    itinerary: [{ type: String, required: true }], // Array of strings for itinerary
  },
  { timestamps: true }
);

module.exports = mongoose.model("Package", packageSchema);
