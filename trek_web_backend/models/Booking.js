const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema({
  packageId: { type: mongoose.Schema.Types.ObjectId, ref: "Package", required: true },
  fullName: { type: String, required: true },
  email: { type: String, required: true },
  phone: { type: String, required: true },
  tickets: { type: Number, required: true, min: 1 },
  pickupLocation: { type: String },
  paymentMethod: { type: String, enum: ["credit-card", "debit-card", "upi", "paypal"], required: true },
  status: { type: String, enum: ["pending", "confirmed", "cancelled"], default: "pending" },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Booking", bookingSchema);
