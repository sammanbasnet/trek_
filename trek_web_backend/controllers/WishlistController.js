const Wishlist = require("../models/Wishlist");
const Package = require("../models/Package");

// Add package to wishlist
exports.addToWishlist = async (req, res) => {
    try {
        const { packageId } = req.body;
        const customerId = req.user.id; // Assuming authentication middleware sets req.user

        // Check if the package exists
        const packageExists = await Package.findById(packageId);
        if (!packageExists) {
            return res.status(404).json({ success: false, message: "Package not found" });
        }

        // Find or create wishlist for the customer
        let wishlist = await Wishlist.findOne({ customer: customerId });
        if (!wishlist) {
            wishlist = new Wishlist({ customer: customerId, packages: [] });
        }

        // Check if the package is already in the wishlist
        if (wishlist.packages.includes(packageId)) {
            return res.status(400).json({ success: false, message: "Package already in wishlist" });
        }

        // Add package to wishlist
        wishlist.packages.push(packageId);
        await wishlist.save();

        // Fetch updated count
        const updatedCount = wishlist.packages.length;

        res.status(200).json({ 
            success: true, 
            message: "Added to wishlist", 
            wishlist, 
            count: updatedCount // Return count to update frontend 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};


// Remove package from wishlist
exports.removeFromWishlist = async (req, res) => {
    try {
        const { packageId } = req.params;  // Use body instead of params
        const customerId = req.user.id;

        console.log("Customer ID:", customerId); // Debugging log

        const wishlist = await Wishlist.findOne({ customer: customerId });
        if (!wishlist) {
            return res.status(404).json({ success: false, message: "Wishlist not found" });
        }

        if (!wishlist.packages.includes(packageId)) {
            return res.status(400).json({ success: false, message: "Package not in wishlist" });
        }

        // Remove package from wishlist
        wishlist.packages = wishlist.packages.filter(id => id.toString() !== packageId);
        await wishlist.save();

        // Fetch updated wishlist with populated packages
        const updatedWishlist = await Wishlist.findOne({ customer: customerId }).populate("packages");

        // Return updated wishlist count
        res.status(200).json({
            success: true,
            message: "Removed from wishlist",
            wishlist: updatedWishlist,
            count: updatedWishlist.packages.length, // Send updated count
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};


exports.getWishlistCount = async (req, res) => {
  try {
    const wishlist = await Wishlist.findOne({ user: req.user.id });

    if (!wishlist) {
      return res.status(200).json({ success: true, count: 0 });
    }

    return res.status(200).json({ success: true, count: wishlist.packages.length });
  } catch (error) {
    console.error("Error fetching wishlist count:", error);
    return res.status(500).json({ success: false, message: "Server Error" });
  }
};

// Get wishlist of a customer
exports.getWishlist = async (req, res) => {
    try {
        const customerId = req.user.id;
        const wishlist = await Wishlist.findOne({ customer: customerId }).populate("packages");

        if (!wishlist) {
            return res.status(404).json({ success: false, message: "Wishlist not found" });
        }

        res.status(200).json({ success: true, wishlist });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.deleteWishlistItem = async (req, res) => {
    try {
      const userId = req.user.id; // Get user ID from `protect` middleware
      const packageId = req.params.packageId;
  
      // Find the user's wishlist
      const wishlist = await Wishlist.findOne({ customer: userId });
  
      if (!wishlist) {
        return res.status(404).json({ success: false, message: "Wishlist not found" });
      }
  
      // Check if package exists in wishlist
      const packageIndex = wishlist.packages.findIndex(pkg => pkg._id.toString() === packageId);
      if (packageIndex === -1) {
        return res.status(404).json({ success: false, message: "Package not found in wishlist" });
      }
  
      // Remove package from wishlist array
      wishlist.packages.splice(packageIndex, 1);
      await wishlist.save();
  
      res.status(200).json({ success: true, message: "Package deleted from wishlist" });
    } catch (error) {
      console.error("Error deleting from wishlist:", error);
      res.status(500).json({ success: false, message: "Server error" });
    }
};
