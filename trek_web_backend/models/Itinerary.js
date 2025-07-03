const mongoose = require("mongoose")
const itinerarySchema = new mongoose.Schema({
    packageId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "packages"
    },
    day_number: {
        type: Number,
        required: true
    },
    activities: {
        type: String,
        required: true
    },
    details: {
        type: String,
        required: true
    }

})
const Itinerary = mongoose.model("itinerarys", itinerarySchema);

module.exports = Itinerary;