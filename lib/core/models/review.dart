import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;              // Firestore document ID
  final String userId;          // ID of the user who posted the review
  final String parkName;        // Name of the park being reviewed
  final String name;            // User's display name (optional)
  final String reviewText;      // The actual review text
  final double rating;          // Rating (1.0 to 5.0)
  final Timestamp timestamp;    // Time the review was posted

  Review({
    required this.id,
    required this.userId,
    required this.parkName,
    required this.name,
    required this.reviewText,
    required this.rating,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      parkName: data['ParkName'] ?? '',
      name: data['Name'] ?? 'Anonymous',
      reviewText: data['reviews'] ?? '',
      rating: (data['Rating'] as num?)?.toDouble() ?? 0.0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'ParkName': parkName,
      'Name': name,
      'reviews': reviewText,
      'Rating': rating,
      'timestamp': timestamp,
    };
  }
}
