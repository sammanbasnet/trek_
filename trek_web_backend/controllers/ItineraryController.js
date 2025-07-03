const Itinerary = require('../model/Itinerary')
const findAll = async (req, res) => {
    try {
        const itinerarys = await Itinerary.find().populate(["bookingId"]);
        res.status(200).json(itinerarys);
    } catch (e) {
        res.json(e)
    }

}
const save = async (req, res) => {
    try {
        const { amount, itineraryMethod, itineraryStatus, PaidAt, } = req.body
        const Itinerary = new Itinerary({
            amount,
            itineraryMethod,
            itineraryStatus,
            PaidAt,
            bookingId: req.body.bookingId




        });
        await itinerary.save();
        res.status(201).json(itinerary)
    } catch (e) {
        res.json(e)
    }

}
const findById = async (req, res) => {
    try {
        const itinerary = await Itinerary.findById(req.params.id);
        res.status(200).json(itinerary)
    } catch (e) {
        res.json(e)

    }


}
const deleteById = async (req, res) => {
    try {
        const itinerary = await Itinerary.findByIdAndDelete(req.params.id);
        res.status(200).json("data Deleted")
    } catch (e) {
        res.json(e)

    }


}
const update = async (req, res) => {
    try {
        const itinerary = await Itinerary.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.status(201).json(itinerary)
    } catch (e) {
        res.json(e)

    }


}

module.exports = {
    findAll,
    save,
    findById,
    deleteById,
    update

}