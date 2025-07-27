const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");
const upload = require("../middleware/uploads");

const {
    getCustomers,
    getCustomer,
    register,
    login,
    uploadImage,
    updateCustomer,
    deleteCustomer
} = require("../controllers/customer");

// Register and login
router.post("/register", upload.single("profilePicture"), register);
router.post("/login", login);

// RESTful customer routes
router.get("/", protect, authorize("admin"), getCustomers); // GET /api/v1/customers
router.get("/:id", protect, authorize("admin", "customer"), getCustomer); // GET /api/v1/customers/:id
router.put("/update/:id", protect, authorize("admin", "customer"), upload.single("profilePicture"), updateCustomer); // PUT /api/v1/customers/update/:id
router.delete("/:id", protect, authorize("admin"), deleteCustomer); // DELETE /api/v1/customers/:id

// Image upload
router.post("/uploadImage", protect, authorize("admin", "customer"), upload.single("profilePicture"), uploadImage);

module.exports = router;