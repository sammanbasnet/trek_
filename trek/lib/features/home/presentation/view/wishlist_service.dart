import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  static const String _wishlistKey = 'wishlist_items';

  // Add item to wishlist
  static Future<void> addToWishlist(Map<String, dynamic> item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> wishlistItems = prefs.getStringList(_wishlistKey) ?? [];
      
      // Check if item already exists
      String itemId = item['_id'] ?? item['title'] ?? '';
      bool exists = wishlistItems.any((wishlistItem) {
        Map<String, dynamic> parsedItem = json.decode(wishlistItem);
        return parsedItem['_id'] == itemId || parsedItem['title'] == item['title'];
      });
      
      if (!exists) {
        wishlistItems.add(json.encode(item));
        await prefs.setStringList(_wishlistKey, wishlistItems);
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
    }
  }

  // Remove item from wishlist
  static Future<void> removeFromWishlist(String itemId) async {
    try {
      if (itemId.isEmpty) return;
      
      final prefs = await SharedPreferences.getInstance();
      List<String> wishlistItems = prefs.getStringList(_wishlistKey) ?? [];
      
      wishlistItems.removeWhere((wishlistItem) {
        Map<String, dynamic> parsedItem = json.decode(wishlistItem);
        return parsedItem['_id'] == itemId || parsedItem['title'] == itemId;
      });
      
      await prefs.setStringList(_wishlistKey, wishlistItems);
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }

  // Get all wishlist items
  static Future<List<Map<String, dynamic>>> getWishlistItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> wishlistItems = prefs.getStringList(_wishlistKey) ?? [];
      
      return wishlistItems.map((item) => Map<String, dynamic>.from(json.decode(item))).toList();
    } catch (e) {
      print('Error getting wishlist items: $e');
      return [];
    }
  }

  // Check if item is in wishlist
  static Future<bool> isInWishlist(String itemId) async {
    try {
      if (itemId.isEmpty) return false;
      
      final prefs = await SharedPreferences.getInstance();
      List<String> wishlistItems = prefs.getStringList(_wishlistKey) ?? [];
      
      return wishlistItems.any((wishlistItem) {
        Map<String, dynamic> parsedItem = json.decode(wishlistItem);
        return parsedItem['_id'] == itemId || parsedItem['title'] == itemId;
      });
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  // Clear all wishlist items
  static Future<void> clearWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wishlistKey);
    } catch (e) {
      print('Error clearing wishlist: $e');
    }
  }
} 