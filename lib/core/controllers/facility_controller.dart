import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/facility.dart';

class FacilityController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Facility>> getAllParks() {
    return _firestore.collection('Parks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Facility.fromFirestore(doc)).toList();
    });
  }

  Future<Facility?> getParkById(String parkId) async {
    try {
      final doc = await _firestore.collection('Parks').doc(parkId).get();
      if (doc.exists) {
        return Facility.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch park: $e');
    }
  }

  Stream<List<Facility>> searchParks(String query) {
    return _firestore.collection('Parks').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final name = (data['name'] ?? '').toString().toLowerCase();
            final desc = (data['description'] ?? '').toString().toLowerCase();
            return name.contains(query.toLowerCase()) || 
                   desc.contains(query.toLowerCase());
          })
          .map((doc) => Facility.fromFirestore(doc))
          .toList();
    });
  }
}