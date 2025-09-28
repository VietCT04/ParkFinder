import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'about_screen.dart'; // Adjust if needed

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // Stores all parks
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allParks = [];
  // Filtered list
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredParks = [];

  @override
  void initState() {
    super.initState();
    _fetchParksFromFirestore();
  }

  Future<void> _fetchParksFromFirestore() async {
    try {
      // Ensure your Firestore has a "Parks" collection
      final snapshot =
          await FirebaseFirestore.instance.collection('Parks').get();

      setState(() {
        _allParks = snapshot.docs;
        _filteredParks = snapshot.docs;
      });
      debugPrint('Fetched ${_allParks.length} parks from Firestore.');
    } catch (e) {
      debugPrint('Error fetching parks: $e');
    }
  }

  void _filterParks(String query) {
    if (query.isEmpty) {
      setState(() => _filteredParks = _allParks);
    } else {
      setState(() {
        _filteredParks =
            _allParks.where((doc) {
              final data = doc.data();
              final name = (data['name'] ?? '').toString().toLowerCase();
              final description =
                  (data['description'] ?? '').toString().toLowerCase();
              return name.contains(query.toLowerCase()) ||
                  description.contains(query.toLowerCase());
            }).toList();
      });
    }
  }

  // Helper method to get average rating
  Stream<double> _getAverageRating(String parkName) {
    return FirebaseFirestore.instance
        .collection("Reviews")
        .where("ParkName", isEqualTo: parkName)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0.0;
          double total = 0.0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['Rating'] ?? 0).toDouble();
          }
          return total / snapshot.docs.length;
        });
  }

  // Helper method to get review count
  Stream<int> _getReviewCount(String parkName) {
    return FirebaseFirestore.instance
        .collection("Reviews")
        .where("ParkName", isEqualTo: parkName)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Basic AppBar
      appBar: AppBar(
        title: const Text("Search", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF009b50),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterParks,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  hintText: "Search by name or description...",
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child:
                _filteredParks.isEmpty
                    ? const Center(
                      child: Text("No parks found or data still loading."),
                    )
                    : ListView.builder(
                      itemCount: _filteredParks.length,
                      itemBuilder: (context, index) {
                        final doc = _filteredParks[index];
                        final data = doc.data();

                        // Firestore fields: name, description, image_url
                        final parkName = data['name'] ?? 'No Name';
                        final parkDesc =
                            data['description'] ?? '';
                        final imageUrl =
                            data['image_url'] ??
                            'https://via.placeholder.com/150.png?text=No+Image';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: NetworkImage(imageUrl),
                            ),
                            title: Text(parkName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<double>(
                                  stream: _getAverageRating(parkName),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return const SizedBox();
                                    return Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(' ${snapshot.data!.toStringAsFixed(1)}'),
                                        const SizedBox(width: 8),
                                        StreamBuilder<int>(
                                          stream: _getReviewCount(parkName),
                                          builder: (context, countSnapshot) {
                                            if (!countSnapshot.hasData) return const SizedBox();
                                            return Text(
                                              '(${countSnapshot.data} reviews)',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navigate to AboutScreen, pass the doc ID
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AboutScreen(parkId: doc.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}