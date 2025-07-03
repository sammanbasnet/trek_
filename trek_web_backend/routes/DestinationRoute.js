const express = require("express")
const router = express.Router();
const { findAll, save, findById, deleteById, update } = require("../controller/DestinationController");
const DestinationValidation = require("../validation/DestinationValidation");


router.get("/", findAll);
router.post("/", DestinationValidation, save);
router.get("/:id", findById);
router.delete("/:id", deleteById);
router.put("/:id", update)



module.exports = router;
