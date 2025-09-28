import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:park_finder/core/views/home_page.dart';
import 'package:park_finder/core/views/settings_page.dart';
import 'package:park_finder/core/views/search_page.dart';
import 'package:park_finder/core/views/about_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteParks;

  const FavoritesPage({super.key, required this.favoriteParks});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Retrieve the favourite parks using userId
  Stream<List<Map<String, dynamic>>> getFavParksbyUserid() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection("FavouriteParks")
        .where("userId", isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getFavParksbyUserid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favParks = snapshot.data ?? [];

          if (favParks.isEmpty) {
            return const Center(
              child: Text(
                "No favourite parks yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: favParks.length,
            itemBuilder: (context, index) {
              final park = favParks[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    park['ParkImage'] ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.park, size: 60),
                  ),
                ),
                title: Text(
                  park['ParkName'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutScreen(parkId: park['ParkId']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
