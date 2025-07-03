const express = require("express")
const router = express.Router();
const { findAll, save, findById, deleteById, update } = require("../controller/ItineraryController");
const ItineraryValidation = require("../validation/ItineraryValidation");


router.get("/", findAll);
router.post("/", ItineraryValidation, save);
router.get("/:id", findById);
router.delete("/:id", deleteById);
router.put("/:id", update)



module.exports = router;
