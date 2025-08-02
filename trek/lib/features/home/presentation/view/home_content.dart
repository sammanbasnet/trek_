import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../trips/presentation/view/trip_detail_page.dart';
import '../../../../core/network/api_endpoints.dart';
import 'trek_detail_page.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;
  String? error;

  // Popular Destinations data based on web research
  final List<Map<String, dynamic>> popularDestinations = [
    {
      'name': 'Everest Base Camp',
      'location': 'Solukhumbu, Nepal',
      'rating': '4.8',
      'image': 'assets/image/mountains.jpg',
      'duration': '14 Days',
      'maxAltitude': '5,364m',
      'difficulty': 'Moderate',
      'description': 'The Everest Base Camp trek is one of the most iconic treks in the world, taking you to the base of Mount Everest, the highest peak on Earth. This trek offers breathtaking views of the Himalayas, including Everest, Lhotse, Nuptse, and Ama Dablam.',
      'highlights': [
        'Stand at the base of Mount Everest',
        'Visit the famous Kala Patthar viewpoint',
        'Experience Sherpa culture and hospitality',
        'Cross the Hillary Suspension Bridge',
        'Visit Tengboche Monastery',
        'Witness stunning sunrise over the Himalayas'
      ],
      'bestTime': 'The best time to visit Everest Base Camp is during the pre-monsoon (March to May) and post-monsoon (September to November) seasons. These months offer clear skies, stable weather, and excellent visibility of the mountains.',
      'route': [
        {
          'day': 1,
          'title': 'Kathmandu to Lukla to Phakding',
          'description': 'Fly to Lukla and trek to Phakding (2,610m)'
        },
        {
          'day': 2,
          'title': 'Phakding to Namche Bazaar',
          'description': 'Trek to Namche Bazaar (3,440m), the gateway to Everest'
        },
        {
          'day': 3,
          'title': 'Acclimatization Day',
          'description': 'Rest day in Namche with optional hike to Everest View Hotel'
        },
        {
          'day': 4,
          'title': 'Namche to Tengboche',
          'description': 'Trek to Tengboche (3,860m) and visit the monastery'
        },
        {
          'day': 5,
          'title': 'Tengboche to Dingboche',
          'description': 'Continue to Dingboche (4,410m)'
        },
        {
          'day': 6,
          'title': 'Acclimatization Day',
          'description': 'Rest day with optional hike to Nangkartshang Peak'
        },
        {
          'day': 7,
          'title': 'Dingboche to Lobuche',
          'description': 'Trek to Lobuche (4,910m)'
        },
        {
          'day': 8,
          'title': 'Lobuche to Gorak Shep',
          'description': 'Trek to Gorak Shep (5,140m) and hike to EBC'
        },
        {
          'day': 9,
          'title': 'Gorak Shep to Kala Patthar',
          'description': 'Early morning hike to Kala Patthar (5,545m) for sunrise views'
        },
        {
          'day': 10,
          'title': 'Gorak Shep to Pheriche',
          'description': 'Begin descent to Pheriche (4,240m)'
        },
        {
          'day': 11,
          'title': 'Pheriche to Namche',
          'description': 'Continue descent to Namche Bazaar'
        },
        {
          'day': 12,
          'title': 'Namche to Lukla',
          'description': 'Final day of trekking to Lukla'
        },
        {
          'day': 13,
          'title': 'Lukla to Kathmandu',
          'description': 'Fly back to Kathmandu'
        },
        {
          'day': 14,
          'title': 'Departure',
          'description': 'Transfer to airport for departure'
        }
      ]
    },
    {
      'name': 'Annapurna Circuit',
      'location': 'Annapurna Region, Nepal',
      'rating': '4.7',
      'image': 'assets/image/mountains.jpg',
      'duration': '18 Days',
      'maxAltitude': '5,416m',
      'difficulty': 'Moderate to Challenging',
      'description': 'The Annapurna Circuit is one of the most diverse treks in Nepal, offering a complete circumnavigation of the Annapurna massif. This trek takes you through varied landscapes from subtropical valleys to high alpine passes.',
      'highlights': [
        'Cross the famous Thorong La Pass (5,416m)',
        'Experience diverse landscapes and cultures',
        'Visit the sacred Muktinath Temple',
        'Witness stunning views of Annapurna range',
        'Walk through beautiful rhododendron forests',
        'Experience both Hindu and Buddhist cultures'
      ],
      'bestTime': 'The best time for the Annapurna Circuit is during the pre-monsoon (March to May) and post-monsoon (September to November) seasons. The weather is generally clear and stable during these periods.',
      'route': [
        {
          'day': 1,
          'title': 'Kathmandu to Besisahar',
          'description': 'Drive to Besisahar and trek to Bhulbhule'
        },
        {
          'day': 2,
          'title': 'Bhulbhule to Jagat',
          'description': 'Trek through beautiful rice terraces'
        },
        {
          'day': 3,
          'title': 'Jagat to Dharapani',
          'description': 'Enter the Manang district'
        },
        {
          'day': 4,
          'title': 'Dharapani to Chame',
          'description': 'Trek to Chame, the district headquarters'
        },
        {
          'day': 5,
          'title': 'Chame to Pisang',
          'description': 'Continue through pine forests'
        },
        {
          'day': 6,
          'title': 'Pisang to Manang',
          'description': 'Trek to Manang (3,540m)'
        },
        {
          'day': 7,
          'title': 'Acclimatization Day',
          'description': 'Rest day in Manang with optional hikes'
        },
        {
          'day': 8,
          'title': 'Manang to Yak Kharka',
          'description': 'Trek to Yak Kharka (4,018m)'
        },
        {
          'day': 9,
          'title': 'Yak Kharka to Thorong Phedi',
          'description': 'Trek to Thorong Phedi (4,540m)'
        },
        {
          'day': 10,
          'title': 'Thorong Phedi to Muktinath',
          'description': 'Cross Thorong La Pass (5,416m) to Muktinath'
        },
        {
          'day': 11,
          'title': 'Muktinath to Marpha',
          'description': 'Visit Muktinath Temple and trek to Marpha'
        },
        {
          'day': 12,
          'title': 'Marpha to Kalopani',
          'description': 'Trek through the Kali Gandaki Valley'
        },
        {
          'day': 13,
          'title': 'Kalopani to Tatopani',
          'description': 'Descend to Tatopani and enjoy hot springs'
        },
        {
          'day': 14,
          'title': 'Tatopani to Ghorepani',
          'description': 'Trek to Ghorepani through rhododendron forests'
        },
        {
          'day': 15,
          'title': 'Ghorepani to Poon Hill',
          'description': 'Early morning hike to Poon Hill for sunrise'
        },
        {
          'day': 16,
          'title': 'Ghorepani to Tikhedhunga',
          'description': 'Continue descent to Tikhedhunga'
        },
        {
          'day': 17,
          'title': 'Tikhedhunga to Nayapul',
          'description': 'Final day of trekking to Nayapul'
        },
        {
          'day': 18,
          'title': 'Nayapul to Pokhara',
          'description': 'Drive to Pokhara and fly to Kathmandu'
        }
      ]
    },
    {
      'name': 'Langtang Valley',
      'location': 'Langtang Region, Nepal',
      'rating': '4.6',
      'image': 'assets/image/mountains.jpg',
      'duration': '10 Days',
      'maxAltitude': '4,984m',
      'difficulty': 'Moderate',
      'description': 'The Langtang Valley trek is a beautiful and less crowded alternative to the more popular treks in Nepal. This trek takes you through pristine forests, traditional villages, and offers stunning views of the Langtang range.',
      'highlights': [
        'Visit the sacred Kyanjin Gompa',
        'Witness stunning Langtang Lirung views',
        'Experience Tamang culture and hospitality',
        'Walk through beautiful rhododendron forests',
        'Visit the cheese factory at Kyanjin',
        'Enjoy panoramic mountain views'
      ],
      'bestTime': 'The best time to visit Langtang Valley is during the pre-monsoon (March to May) and post-monsoon (September to November) seasons. The weather is pleasant and the views are clear during these months.',
      'route': [
        {
          'day': 1,
          'title': 'Kathmandu to Syabrubesi',
          'description': 'Drive to Syabrubesi (1,460m)'
        },
        {
          'day': 2,
          'title': 'Syabrubesi to Lama Hotel',
          'description': 'Trek to Lama Hotel (2,480m)'
        },
        {
          'day': 3,
          'title': 'Lama Hotel to Langtang',
          'description': 'Trek to Langtang village (3,430m)'
        },
        {
          'day': 4,
          'title': 'Langtang to Kyanjin Gompa',
          'description': 'Trek to Kyanjin Gompa (3,830m)'
        },
        {
          'day': 5,
          'title': 'Acclimatization Day',
          'description': 'Rest day with optional hikes around Kyanjin'
        },
        {
          'day': 6,
          'title': 'Kyanjin Ri Hike',
          'description': 'Hike to Kyanjin Ri (4,773m) for panoramic views'
        },
        {
          'day': 7,
          'title': 'Kyanjin to Langtang',
          'description': 'Begin descent to Langtang village'
        },
        {
          'day': 8,
          'title': 'Langtang to Lama Hotel',
          'description': 'Continue descent to Lama Hotel'
        },
        {
          'day': 9,
          'title': 'Lama Hotel to Syabrubesi',
          'description': 'Final day of trekking to Syabrubesi'
        },
        {
          'day': 10,
          'title': 'Syabrubesi to Kathmandu',
          'description': 'Drive back to Kathmandu'
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    print('HomeContent: initState called');
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    try {
      print('HomeContent: Fetching packages...');
      print('HomeContent: URL: \'${ApiEndpoints.baseUrl}/package\'');
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/package'),
      );

      print('HomeContent: Response status: ${response.statusCode}');
      print('HomeContent: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          packages = data.map((json) => Map<String, dynamic>.from(json)).toList();
          isLoading = false;
        });
        print('HomeContent: Loaded ${packages.length} packages');
        for (var package in packages) {
          print('HomeContent: Package: ${package['title']} - \$${package['price']}');
        }
      } else {
        setState(() {
          error = 'Failed to load packages: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('HomeContent: Error: $e');
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('HomeContent: build method called');
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
                    onPressed: () {
                      print('HomeContent: Retry button pressed');
                      fetchPackages();
                    },
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
                print('HomeContent: Building package ${package['title']}');
              return GestureDetector(
                onTap: () {
                    print('HomeContent: Tapped on package ${package['title']}');
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
                                  onTap: () {
                                    // Add to wishlist functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Added ${package['title']} to wishlist')),
                                    );
                                  },
                                  child: const Icon(Icons.favorite_border, size: 18),
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
        // Popular Destinations
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Popular Destinations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            GestureDetector(
              onTap: () {
                // Navigate to all destinations page
                Navigator.pushNamed(context, '/destinations');
              },
              child: const Text("View All", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularDestinations.length,
            itemBuilder: (context, index) {
              final destination = popularDestinations[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrekDetailPage(trek: destination),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
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
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          destination['image'],
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
                            Text(
                              destination['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  destination['rating'],
                                  style: const TextStyle(fontSize: 12),
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
                    onPressed: () {
                      print('HomeContent: Retry button pressed');
                      fetchPackages();
                    },
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
                print('HomeContent: Building package ${package['title']}');
              return GestureDetector(
                onTap: () {
                    print('HomeContent: Tapped on package ${package['title']}');
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