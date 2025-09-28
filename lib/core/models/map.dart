import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:park_finder/core/views/about_screen.dart';
import 'package:park_finder/core/views/search_page.dart';
import 'dart:math';
class ParkMap extends StatefulWidget {
  
   final double initialLat;
  final double initialLng;

  const ParkMap({super.key, required this.initialLat, required this.initialLng});

  @override
  State<ParkMap> createState() => ParkMapState();
}

class ParkMapState extends State<ParkMap> {
  List<Marker> _markers = [];

  // Initialize Firebase and fetch the data before screen starts
  @override
  void initState() {
    super.initState();
    fetchPark();
  }

  //Future converting coordinates to address

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Fetch address details using the geocoding package
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      // If we have any placemarks, return the first one as the address
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.name}, ${place.locality}, ${place.country}';
      }
      return 'Address not found';
    } catch (e) {
      print('Error fetching address: $e');
      return 'Error fetching address';
    }
  }

  //Fetch park details

  //context is needed to display dialogs
  Future<void> fetchparkdetails(
    BuildContext context,
    Map<String, dynamic> park,
    String id,
  ) async {
    var coordinates = park['coordinates'];
    var lng = (coordinates[0] as num).toDouble();
    var lat = (coordinates[1] as num).toDouble();

    String address = await getAddressFromCoordinates(lat, lng);
    showDialog(
      context: context,

      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),

            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutScreen(parkId: id),
                  ),
                );
              },
              child: Container(
                height: 400,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    //Title
                       //Title 
              Text(park['name'] ?? "Park Name", style : TextStyle(fontSize: 20 , fontWeight: FontWeight.bold)),
              SizedBox(height: 10), 
                    //image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage("${park['image_url']}"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    //address
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.pin_drop_sharp, color: Colors.red, size: 50),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Address:  $address",
                            style: TextStyle(fontSize: 19),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // Fetch park locations from Firebase
  Future<void> fetchPark() async {
    try {
      // Fetch data from Firebase Firestore
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("Parks").get();

      // Create a list of markers
      List<Marker> markers = [];

      // Go through each document in the collection
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Check if 'coordinates' exists and is a List
        if (data.containsKey('coordinates') && data['coordinates'] is List) {
          var coordinates = data['coordinates'];

          // Ensure coordinates are in the right order (Longitude, Latitude)
          var lng = (coordinates[0] as num).toDouble(); // Longitude
          var lat = (coordinates[1] as num).toDouble(); // Latitude

          // Print the fetched coordinates for debugging
          print("Fetched coordinates: Latitude: $lat, Longitude: $lng");
          
          

         
         
          // Add marker to the list
           if(_isNearby(lat, lng))
           {
         markers.add(
            Marker(
              point: LatLng(
                lat,
                lng,
              ), // Notice the order here: LatLng(latitude, longitude)
              height: 50,
              width: 50,
              child: GestureDetector(
                onTap: () {
                  fetchparkdetails(context, data, doc.id);
                },
                child: Icon(Icons.location_on, color: Colors.green, size: 40),
              ),
            ),
          );

           }
        }
      }

      // Update markers in the state
      setState(() {
        _markers = markers;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }
   bool _isNearby(double lat, double lng) {
    
    //comparring the address of the user's address to park address 
    double distance = _calculateDistance(widget.initialLat, widget.initialLng, lat, lng);
    return distance <= 5.0; // Returns true if within 5km
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double rad = 6371.0; // Radius of the Earth in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);
    double a = (sin(dLat / 2) * sin(dLat / 2)) + (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLng / 2) * sin(dLng / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return rad * c;
  }
 double _toRadians(double degree) {
    return degree * (pi / 180);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF009b50),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print("Search Page Tapped");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.search, color: Colors.grey),
                      ),
                      // Hint text inside the Row
                      Expanded(
                        child: Text(
                          "Search Here!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
         initialCenter: LatLng(widget.initialLat,widget.initialLng), // Coordinates of Singapore
    
          initialZoom: 12, // Adjust zoom level if necessary
        ),
        children: [
          // OpenStreetMap Tile Layer
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          // Marker Layer to display the fetched markers
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
