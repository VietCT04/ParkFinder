import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package
import 'package:park_finder/core/models/map.dart'; // Assuming this is where your ParkMap is defined
import 'package:park_finder/core/views/settings_Page.dart'; // Assuming this is your settings page
import 'package:park_finder/core/views/favourite_page.dart';
import 'package:park_finder/core/views/hidden_gem.dart';
// Assuming this is your favorites page

class ParkHomeScreen extends StatefulWidget {
  final int initialIndex;
  const ParkHomeScreen({super.key, this.initialIndex = 0});

  @override
  _ParkHomeScreenState createState() => _ParkHomeScreenState();
}

class _ParkHomeScreenState extends State<ParkHomeScreen> {
  // Track the selected bottom navigation index
  int _selectedIndex = 0;

  // List of screens corresponding to each bottom navigation tab
  static final List<Widget> _screens = <Widget>[
    HomeScreen(),
    ParkMap(initialLat: 1.3521, initialLng: 103.8198),
    FavoritesPage(
      favoriteParks: [], // Add FavoritesPage here, replace with actual data
    ),
    Hiddengem(),
    SettingsPage(),
  ];

  // Bottom Navigation Bar Handler
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ParkFinder+"),
        centerTitle: true, // Center the title
        backgroundColor: const Color(0xFF009b50),
      ),
      body: _screens[_selectedIndex], // Show selected screen
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Custom Bottom Navigation Bar outside the Scaffold
class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFF009b50),
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favourites",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.diamond),
          label: "Hidden Gems",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _addressController = TextEditingController();

  // Function to convert address to coordinates
  Future<void> _searchAddress(BuildContext context) async {
    String address = _addressController.text.trim();
    if (address.isEmpty) {
      // Show alert if the address field is empty
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Please enter a valid address.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    try {
      // Convert the address to latitude and longitude
      List<Location> locations = await locationFromAddress(address);

      // If a valid location is found, navigate to the ParkMap with the new coordinates
      if (locations.isNotEmpty) {
        double latitude = locations.first.latitude;
        double longitude = locations.first.longitude;

        // Navigate to the map page with the given coordinates
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ParkMap(initialLat: latitude, initialLng: longitude),
          ),
        );
      } else {
        // Show alert if no location found
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Error'),
                content: Text(
                  'Could not find any location for the provided address.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      print("Error searching address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset('Assets/ParkBackground.png', fit: BoxFit.cover),
        // Semi-transparent overlay with 50% opacity
        Container(
          color: Colors.black.withOpacity(0.5), // Adjust the transparency here
        ),
        // Foreground content
        Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Vertically center the content
            crossAxisAlignment:
                CrossAxisAlignment.center, // Optionally, center horizontally
            children: [
              // Welcome message
              const Text(
                "Welcome to ParkFinder+!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              // App logo
              Image.asset(
                'Assets/ParkFinderLogo.png',
                height: 250, // height
                width: 250, // width
              ),
              const SizedBox(height: 15),
              // TextField for address input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Enter Address',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Search button
              ElevatedButton(
                onPressed: () => _searchAddress(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Search Park',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
