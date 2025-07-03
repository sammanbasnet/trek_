import 'package:flutter/material.dart';
import 'package:trek/features/trips/presentation/view/trip_detail_page.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  final List<String> categories = const ['Lakes', 'Mountain', 'Forest', 'Sea'];

  final List<Map<String, String>> topTrips = const [
    {
      'title': 'Rara Lake',
      'location': 'Nepal',
      'price': '\$40 /visit',
      'rating': '4.5',
      'image': 'https://i.pinimg.com/736x/86/82/e1/8682e16c492f150bd46e07e421adf5f2.jpg',
      'description': 'Known as the "Queen of Lakes," Rara is the largest lake in Nepal. Surrounded by lush forests, it offers a tranquil retreat with stunning reflections of the Himalayas.'
    },
    {
      'title': 'Tilicho Lake',
      'location': 'Nepal',
      'price': '\$40 /visit',
      'rating': '4.5',
      'image': 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=800',
      'description': 'One of the highest lakes in the world, Tilicho is a breathtaking turquoise gem nestled in the Annapurna mountain range. A challenging yet rewarding trek for adventurers.'
    },
    {
      'title': 'Shey-Phoksundo Lake',
      'location': 'Nepal',
      'price': '\$40 /visit',
      'rating': '4.5',
      'image': 'https://i.pinimg.com/736x/eb/01/e5/eb01e564d2fc2b5c4c64ef7da9f1480b.jpg',
      'description': 'A sacred alpine lake with mesmerizing deep blue waters, located in the remote Dolpo region. Its unique beauty and cultural significance make it a must-see destination.'
    },
    {
      'title': 'Annapurna Base Camp',
      'location': 'Nepal',
      'price': '\$60 /visit',
      'rating': '4.8',
      'image': 'https://i.pinimg.com/736x/91/51/51/9151510b07cc9fc508a9b57b95d0d766.jpg',
      'description': 'Trek through diverse landscapes to the base of the majestic Annapurna massif. This classic trek offers unparalleled mountain views and a deep cultural experience.'
    },
    {
      'title': 'Gokyo Lakes',
      'location': 'Nepal',
      'price': '\$55 /visit',
      'rating': '4.7',
      'image': 'https://i.pinimg.com/736x/98/5f/40/985f40989da0986230256187a45cc471.jpg',
      'description': 'A series of six spectacular glacial lakes in the Sagarmatha National Park. The trek to Gokyo Ri offers panoramic views of Everest and surrounding peaks.'
    },
  ];

  final List<Map<String, String>> featuredPackages = const [
    {
      'title': 'Everest Base Camp',
      'location': 'Khumbu, Nepal',
      'duration': '14 days',
      'image': 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
    },
    {
      'title': 'Annapurna Circuit',
      'location': 'Annapurna, Nepal',
      'duration': '18 days',
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    }
  ];

  @override
  Widget build(BuildContext context) {
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
            itemCount: categories.length,
            itemBuilder: (context, index) {
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
        // Top Trips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Top Trips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("See All", style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topTrips.length,
            itemBuilder: (context, index) {
              var trip = topTrips[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailPage(trip: trip),
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
                        child: Image.network(trip['image']!, height: 120, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(trip['location']!, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(trip['price']!, style: const TextStyle(color: Colors.redAccent)),
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
        // Featured Packages
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Featured Packages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("See All", style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: featuredPackages.length,
          itemBuilder: (context, index) {
            var package = featuredPackages[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        package['image']!,
                        height: 80,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(package['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          Text(package['location']!, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 5),
                          Text(package['duration']!, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
} 