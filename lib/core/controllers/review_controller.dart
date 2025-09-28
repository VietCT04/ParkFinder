import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview({
    required String parkName,
    required String userId,
    required String userName,
    required String reviewText,
    required double rating,
  }) async {
    try {
      await _firestore.collection('Reviews').add({
        'ParkName': parkName,
        'userId': userId,
        'Name': userName,
        'reviews': reviewText,
        'Rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  Future<void> removeReview(String reviewId) async {
    try {
      await _firestore.collection('Reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to remove review: $e');
    }
  }

  Stream<List<Review>> getReviewsForPark(String parkName) {
    return _firestore
        .collection('Reviews')
        .where('ParkName', isEqualTo: parkName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromFirestore(doc))
            .toList());
  }

  Stream<double> getAverageRating(String parkName) {
    return _firestore
        .collection('Reviews')
        .where('ParkName', isEqualTo: parkName)
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
}