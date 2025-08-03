const Wishlist = require('../models/Wishlist');
const Customer = require('../models/Customer');

// Add item to wishlist
const addToWishlist = async (req, res) => {
  try {
    const { userId, packageId, packageTitle, packageLocation, packagePrice, packageImage } = req.body;

    // Validate required fields
    if (!userId || !packageId || !packageTitle || !packageLocation || !packagePrice) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    // Check if user exists
    const user = await Customer.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if item already exists in wishlist
    const existingItem = await Wishlist.findOne({ userId, packageId });
    if (existingItem) {
      return res.status(200).json({
        success: true,
        message: 'Item already in wishlist',
        data: existingItem
      });
    }

    // Create new wishlist item
    const wishlistItem = new Wishlist({
      userId,
      packageId,
      packageTitle,
      packageLocation,
      packagePrice,
      packageImage
    });

    await wishlistItem.save();

    res.status(201).json({
      success: true,
      message: 'Item added to wishlist successfully',
      data: wishlistItem
    });

  } catch (error) {
    console.error('Error adding to wishlist:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

// Remove item from wishlist
const removeFromWishlist = async (req, res) => {
  try {
    const { userId } = req.body;
    const { itemId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    // Find and remove the wishlist item
    const deletedItem = await Wishlist.findOneAndDelete({
      userId,
      $or: [
        { packageId: itemId },
        { packageTitle: itemId }
      ]
    });

    if (!deletedItem) {
      return res.status(404).json({
        success: false,
        message: 'Wishlist item not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Item removed from wishlist successfully',
      data: deletedItem
    });

  } catch (error) {
    console.error('Error removing from wishlist:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

// Get user's wishlist
const getUserWishlist = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    // Check if user exists
    const user = await Customer.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get user's wishlist items
    const wishlistItems = await Wishlist.find({ userId }).sort({ addedAt: -1 });

    res.status(200).json({
      success: true,
      message: 'Wishlist retrieved successfully',
      data: wishlistItems
    });

  } catch (error) {
    console.error('Error getting user wishlist:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

// Check if item is in user's wishlist
const checkWishlistItem = async (req, res) => {
  try {
    const { userId, packageId } = req.params;

    if (!userId || !packageId) {
      return res.status(400).json({
        success: false,
        message: 'User ID and Package ID are required'
      });
    }

    const wishlistItem = await Wishlist.findOne({ userId, packageId });

    res.status(200).json({
      success: true,
      message: 'Wishlist check completed',
      data: {
        isInWishlist: !!wishlistItem,
        item: wishlistItem
      }
    });

  } catch (error) {
    console.error('Error checking wishlist item:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

// Clear user's wishlist
const clearWishlist = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    // Check if user exists
    const user = await Customer.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Remove all wishlist items for the user
    const result = await Wishlist.deleteMany({ userId });

    res.status(200).json({
      success: true,
      message: 'Wishlist cleared successfully',
      data: {
        deletedCount: result.deletedCount
      }
    });

  } catch (error) {
    console.error('Error clearing wishlist:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

module.exports = {
  addToWishlist,
  removeFromWishlist,
  getUserWishlist,
  checkWishlistItem,
  clearWishlist
};
