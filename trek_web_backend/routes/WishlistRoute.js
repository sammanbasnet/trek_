const express = require('express');
const router = express.Router();
const {
  addToWishlist,
  removeFromWishlist,
  getUserWishlist,
  checkWishlistItem,
  clearWishlist
} = require('../controllers/WishlistController');

// Add item to wishlist
router.post('/wishlist', addToWishlist);

// Remove item from wishlist
router.delete('/wishlist/:itemId', removeFromWishlist);

// Get user's wishlist
router.get('/wishlist/user/:userId', getUserWishlist);

// Check if item is in user's wishlist
router.get('/wishlist/check/:userId/:packageId', checkWishlistItem);

// Clear user's wishlist
router.delete('/wishlist/clear/:userId', clearWishlist);

module.exports = router;
