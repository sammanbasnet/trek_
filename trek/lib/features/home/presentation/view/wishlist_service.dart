import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';

class WishlistService {
  static const String _wishlistKey = 'wishlist_items';

  // Clear all wishlist data
  static Future<void> clearWishlistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wishlistKey);
      print('WishlistService: Cleared all wishlist data');
    } catch (e) {
      print('Error clearing wishlist data: $e');
    }
  }

  // Add item to wishlist
  static Future<bool> addToWishlist(Map<String, dynamic> package) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      print('WishlistService: Adding package to wishlist: ${package['title']}');
      
      // Get current wishlist
      final currentWishlist = await getWishlistItems();
      print('WishlistService: Current wishlist has ${currentWishlist.length} items');
      
      // Check if item already exists
      final existingIndex = currentWishlist.indexWhere(
        (item) => item['_id'] == package['_id'] || item['title'] == package['title']
      );
      
      if (existingIndex != -1) {
        print('WishlistService: Item already exists in wishlist');
        return true; // Already in wishlist
      }

      // Create a copy of the package with proper image URL
      Map<String, dynamic> packageWithImage = Map<String, dynamic>.from(package);
      if (package['image'] != null && package['image'].toString().isNotEmpty) {
        packageWithImage['image'] = '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}/uploads/${package['image']}';
      }

      // Add to wishlist
      currentWishlist.add(packageWithImage);
      print('WishlistService: Added item to wishlist. New count: ${currentWishlist.length}');
      
      // Save to SharedPreferences
      await prefs.setString(_wishlistKey, json.encode(currentWishlist));
      print('WishlistService: Saved to SharedPreferences');
      
      // Also save to backend
      await _saveToBackend(package, userId);
      
      return true;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  // Remove item from wishlist
  static Future<bool> removeFromWishlist(String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      print('WishlistService: Removing item from wishlist: $itemId');
      
      // Get current wishlist
      final currentWishlist = await getWishlistItems();
      print('WishlistService: Current wishlist has ${currentWishlist.length} items');
      
      // Remove item
      currentWishlist.removeWhere(
        (item) => item['_id'] == itemId || item['title'] == itemId
      );
      
      print('WishlistService: After removal, wishlist has ${currentWishlist.length} items');
      
      // Save to SharedPreferences
      await prefs.setString(_wishlistKey, json.encode(currentWishlist));
      print('WishlistService: Saved to SharedPreferences');
      
      // Also remove from backend
      await _removeFromBackend(itemId, userId);
      
      return true;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  // Check if item is in wishlist
  static Future<bool> isInWishlist(String itemId) async {
    try {
      final wishlistItems = await getWishlistItems();
      final isInWishlist = wishlistItems.any(
        (item) => item['_id'] == itemId || item['title'] == itemId
      );
      print('WishlistService: Checking if $itemId is in wishlist: $isInWishlist');
      return isInWishlist;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  // Get all wishlist items
  static Future<List<Map<String, dynamic>>> getWishlistItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('WishlistService: Getting wishlist items from SharedPreferences');
      
      // First, try to get as string
      try {
        String? wishlistString = prefs.getString(_wishlistKey);
        
        if (wishlistString == null || wishlistString.isEmpty) {
          print('WishlistService: No wishlist items found (string)');
          return [];
        }
        
        print('WishlistService: Raw wishlist string: $wishlistString');
        
        final List<dynamic> decoded = json.decode(wishlistString);
        final items = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        print('WishlistService: Decoded ${items.length} wishlist items');
        return items;
      } catch (stringError) {
        print('WishlistService: String method failed: $stringError');
        
        // If string method fails, try to get as string list
        try {
          List<String>? wishlistStringList = prefs.getStringList(_wishlistKey);
          if (wishlistStringList != null && wishlistStringList.isNotEmpty) {
            print('WishlistService: Found string list with ${wishlistStringList.length} items');
            List<Map<String, dynamic>> items = [];
            for (String itemString in wishlistStringList) {
              try {
                Map<String, dynamic> item = Map<String, dynamic>.from(json.decode(itemString));
                items.add(item);
              } catch (e) {
                print('WishlistService: Error parsing item: $e');
              }
            }
            print('WishlistService: Parsed ${items.length} items from string list');
            return items;
          }
        } catch (listError) {
          print('WishlistService: List method failed: $listError');
        }
        
        // If both methods fail, clear the corrupted data and return empty
        print('WishlistService: Both methods failed, clearing corrupted data');
        await clearWishlistData();
        return [];
      }
    } catch (e) {
      print('Error getting wishlist items: $e');
      // Clear corrupted data on any error
      await clearWishlistData();
      return [];
    }
  }

  // Save to backend
  static Future<void> _saveToBackend(Map<String, dynamic> package, String userId) async {
    try {
      print('WishlistService: Saving to backend...');
      
      // Construct proper image URL for backend
      String imageUrl = '';
      if (package['image'] != null && package['image'].toString().isNotEmpty) {
        imageUrl = '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}/uploads/${package['image']}';
      }
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/wishlist'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'packageId': package['_id'],
          'packageTitle': package['title'],
          'packageLocation': package['location'],
          'packagePrice': package['price'],
          'packageImage': imageUrl,
        }),
      );

      print('WishlistService: Backend response status: ${response.statusCode}');
      print('WishlistService: Backend response body: ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        print('Failed to save wishlist to backend: ${response.statusCode}');
      } else {
        print('WishlistService: Successfully saved to backend');
      }
    } catch (e) {
      print('Error saving wishlist to backend: $e');
    }
  }

  // Remove from backend
  static Future<void> _removeFromBackend(String itemId, String userId) async {
    try {
      print('WishlistService: Removing from backend...');
      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}/wishlist/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
        }),
      );

      print('WishlistService: Backend remove response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('Failed to remove wishlist from backend: ${response.statusCode}');
      } else {
        print('WishlistService: Successfully removed from backend');
      }
    } catch (e) {
      print('Error removing wishlist from backend: $e');
    }
  }

  // Load wishlist from backend
  static Future<void> loadFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/wishlist/user/$userId'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        final wishlistItems = data.map((item) => Map<String, dynamic>.from(item)).toList();
        
        // Convert backend format to frontend format
        final convertedItems = wishlistItems.map((item) => <String, dynamic>{
          '_id': item['packageId'],
          'title': item['packageTitle'],
          'location': item['packageLocation'],
          'price': item['packagePrice'],
          'image': item['packageImage'],
          'rating': '4.5',
          'duration': '14 days',
        }).toList();
        
        // Save to SharedPreferences
        await prefs.setString(_wishlistKey, json.encode(convertedItems));
      }
    } catch (e) {
      print('Error loading wishlist from backend: $e');
    }
  }
} 