import 'package:flutter/material.dart';
import 'package:trek/features/booking/presentation/view/bookings_page.dart';
import 'package:trek/features/home/presentation/view/home_content.dart';
import 'package:trek/features/profile/presentation/view/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const BookingsPage(),
    const ProfilePage(),
  ];

  final List<String> categories = ['Lakes', 'Mountain', 'Forest', 'Sea'];

  final List<Map<String, String>> topTrips = [
    {
      'title': 'Rara Lake',
      'location': 'Nepal',
      'price': '\$40 /visit',
      'rating': '4.5',
      'image': 'https://i.pinimg.com/736x/86/82/e1/8682e16c492f150bd46e07e421adf5f2.jpg'
    },
    {
      'title': 'Tilicho Lake',
      'location': 'Nepal',
      'price': '\$40 /visit',
      'rating': '4.5',
      'image': 'https://i.pinimg.com/736x/6e/75/54/6e7554806054be9939fd9ee89c632e21.jpg'
    },
    {
      'title': 'Shey-Phoksundo Lake',
      'location': 'Nepal',
      'price': '\$40 /visit',
      'rating': '4.5',
      'image': 'https://i.pinimg.com/736x/eb/01/e5/eb01e564d2fc2b5c4c64ef7da9f1480b.jpg'
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.black),
                  SizedBox(width: 4),
                  Text("Kathmandu, Nepal", style: TextStyle(color: Colors.black, fontSize: 16)),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
