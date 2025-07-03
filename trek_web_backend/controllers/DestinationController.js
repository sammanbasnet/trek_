const Destination = require('../model/Destination')

const findAll = async (req, res) => {
    try {
        const destinations = await Destination.find();
        res.status(200).json(destinations);
    } catch (e) {
        res.json(e)
    }



}
const save = async (req, res) => {
    try {
        const destination = new Destination(req.body);
        await destination.save();

        res.status(201).json(destination)
    } catch (e) {
        res.json(e)
    }

}
const findById = async (req, res) => {
    try {
        const destination = await Destination.findById(req.params.id);
        res.status(200).json(destination)
    } catch (e) {
        res.json(e)

    }


}
const deleteById = async (req, res) => {
    try {
        const destination = await Destination.findByIdAndDelete(req.params.id);
        res.status(200).json("data Deleted")
    } catch (e) {
        res.json(e)

    }


}
const update = async (req, res) => {
    try {
        const destination = await Destination.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.status(201).json(destination)
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