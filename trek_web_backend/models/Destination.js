const mongoose = require("mongoose")
const destinationSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    popular_spots: {
        type: String,
        required: true
    },
    region: {
        type: String,
        required: true
    }

})
const Destination = mongoose.model("destinations", destinationSchema);

module.exports = Destination
;