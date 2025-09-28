import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/facility.dart';

class SearchFilterController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Facility>> filterParks({
    String? query,
    double? minRating,
    List<String>? amenities,
  }) {
    return _firestore.collection('Parks').snapshots().asyncMap((snapshot) async {
      List<Facility> filtered = [];

      for (var doc in snapshot.docs) {
        final facility = Facility.fromFirestore(doc);
        bool matches = true;

        // Filter by search query
        if (query != null && query.isNotEmpty) {
          matches = facility.name.toLowerCase().contains(query.toLowerCase()) ||
              facility.description.toLowerCase().contains(query.toLowerCase());
        }

        // Filter by rating if needed
        if (matches && minRating != null) {
          final avgRating = await _getAverageRating(facility.name);
          matches = avgRating >= minRating;
        }

        // Filter by amenities if needed
        if (matches && amenities != null && amenities.isNotEmpty) {
          final parkAmenities = await _getAmenities(facility.name);
          matches = amenities.every((a) => parkAmenities.contains(a));
        }

        if (matches) {
          filtered.add(facility);
        }
      }

      return filtered;
    });
  }

  Future<double> _getAverageRating(String parkName) async {
    final snapshot = await _firestore
        .collection('Reviews')
        .where('ParkName', isEqualTo: parkName)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;
    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['Rating'] ?? 0).toDouble();
    }
    return total / snapshot.docs.length;
  }

  Future<List<String>> _getAmenities(String parkName) async {
    final snapshot = await _firestore
        .collection('amenities')
        .where('parkName', isEqualTo: parkName)
        .get();

    if (snapshot.docs.isEmpty) return [];
    return List<String>.from(snapshot.docs.first.data()['amenities'] ?? []);
  }
}