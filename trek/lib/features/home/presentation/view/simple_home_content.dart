import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../trips/presentation/view/trip_detail_page.dart';
import '../../../booking/presentation/view/bookings_page.dart';
import 'wishlist_page.dart';
import 'wishlist_service.dart';
import '../../../../core/network/api_endpoints.dart';

class SimpleHomeContent extends StatefulWidget {
  const SimpleHomeContent({super.key});

  @override
  State<SimpleHomeContent> createState() => _SimpleHomeContentState();
}

class _SimpleHomeContentState extends State<SimpleHomeContent> {
  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    print('SimpleHomeContent: initState called');
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    try {
      print('SimpleHomeContent: Fetching packages...');
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/package'),
      );

      print('SimpleHomeContent: Response status: ${response.statusCode}');
      print('SimpleHomeContent: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          packages = data.map((json) => Map<String, dynamic>.from(json)).toList();
          isLoading = false;
        });
        print('SimpleHomeContent: Loaded ${packages.length} packages');
      } else {
        setState(() {
          error = 'Failed to load packages: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('SimpleHomeContent: Error: $e');
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleWishlist(Map<String, dynamic> package) async {
    try {
      String itemId = package['_id'] ?? package['title'] ?? '';
      if (itemId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid package data'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      bool isInWishlist = await WishlistService.isInWishlist(itemId);
      
      if (isInWishlist) {
        await WishlistService.removeFromWishlist(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from wishlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await WishlistService.addToWishlist(package);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to wishlist'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Refresh the UI
      setState(() {});
    } catch (e) {
      print('Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating wishlist'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SimpleHomeContent: build method called');
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.tune, color: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        // Categories
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final categories = ['Lakes', 'Mountain', 'Forest', 'Sea'];
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F0F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(categories[index], style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Available Packages
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Available Packages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("See All", style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          SizedBox(
            height: 240,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(error!, style: const TextStyle(fontSize: 16, color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: fetchPackages,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (packages.isEmpty)
          const SizedBox(
            height: 240,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No packages available', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: packages.length,
              itemBuilder: (context, index) {
                var package = packages[index];
                print('SimpleHomeContent: Building package ${package['title']}');
                return GestureDetector(
                  onTap: () {
                    print('SimpleHomeContent: Tapped on package ${package['title']}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripDetailPage(trip: {
                          'id': package['_id'] ?? '',
                          'title': package['title'] ?? '',
                          'location': package['location'] ?? '',
                          'price': '\$${package['price']?.toString() ?? '0'} /visit',
                          'rating': '4.5',
                          'image': (package['image'] != null && package['image'].toString().isNotEmpty)
                              ? '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}/uploads/${package['image'].toString().split('/').last}'
                              : 'https://via.placeholder.com/300x200',
                          'description': package['description'] ?? '',
                        }),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            (package['image'] != null && package['image'].toString().isNotEmpty)
                                ? '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}/uploads/${package['image']}'
                                : 'https://via.placeholder.com/150',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(package['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(package['location'] ?? '', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('\$${package['price']?.toString() ?? '0'} /visit', style: const TextStyle(color: Colors.redAccent)),
                                  GestureDetector(
                                    onTap: () async {
                                      await _toggleWishlist(package);
                                    },
                                    child: FutureBuilder<bool>(
                                      future: WishlistService.isInWishlist(package['_id'] ?? package['title'] ?? ''),
                                      builder: (context, snapshot) {
                                        bool isInWishlist = snapshot.data ?? false;
                                        return Icon(
                                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                                          size: 18,
                                          color: isInWishlist ? Colors.red : Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 20),
        
        // Popular Destinations Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Popular Destinations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("View All", style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final destinations = [
                {
                  'name': 'Everest Base Camp', 
                  'image': 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=300&fit=crop', 
                  'rating': '4.8'
                },
                {
                  'name': 'Annapurna Circuit', 
                  'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop', 
                  'rating': '4.7'
                },
                {
                  'name': 'Langtang Valley', 
                  'image': 'https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg?w=400&h=300&fit=crop', 
                  'rating': '4.6'
                },
                {
                  'name': 'Manaslu Trek', 
                  'image': 'https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?w=400&h=300&fit=crop', 
                  'rating': '4.9'
                },
              ];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Different background colors for each destination
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              index == 0 ? Colors.blue.shade400 : 
                              index == 1 ? Colors.green.shade400 :
                              index == 2 ? Colors.orange.shade400 :
                              Colors.purple.shade400,
                              index == 0 ? Colors.blue.shade700 : 
                              index == 1 ? Colors.green.shade700 :
                              index == 2 ? Colors.orange.shade700 :
                              Colors.purple.shade700,
                            ],
                          ),
                        ),
                      ),
                      Image.network(
                        destinations[index]['image']!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destinations[index]['name']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 12),
                                SizedBox(width: 2),
                                Text(
                                  destinations[index]['rating']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 25),
        
        // Special Offers Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Special Offers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("See All", style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_offer, color: Colors.white, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Early Bird Discount",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Book 30 days in advance & get 15% off",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "15% OFF",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 25),
        
        // Travel Tips Section
        Text("Travel Tips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Best Time to Visit",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Spring (March-May) and Autumn (September-November) are the best seasons for trekking in Nepal. The weather is clear and the views are spectacular!",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Quick Actions
        Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingsPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.calendar_today, color: Colors.green.shade700, size: 24),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "My Bookings",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.favorite, color: Colors.purple.shade700, size: 24),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Wishlist",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.purple.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }
} 