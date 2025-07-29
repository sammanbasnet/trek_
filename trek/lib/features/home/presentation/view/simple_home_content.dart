import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../trips/presentation/view/trip_detail_page.dart';
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
                                  const Icon(Icons.favorite_border, size: 18),
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
      ],
    );
  }
} 