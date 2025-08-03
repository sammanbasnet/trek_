const mongoose = require('mongoose');

const wishlistSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Customer',
    required: true
  },
  packageId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Package',
    required: true
  },
  packageTitle: {
    type: String,
    required: true
  },
  packageLocation: {
    type: String,
    required: true
  },
  packagePrice: {
    type: Number,
    required: true
  },
  packageImage: {
    type: String,
    default: null
  },
  addedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Create compound index to prevent duplicate wishlist items
wishlistSchema.index({ userId: 1, packageId: 1 }, { unique: true });

module.exports = mongoose.model('Wishlist', wishlistSchema);
