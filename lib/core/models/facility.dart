import 'package:cloud_firestore/cloud_firestore.dart';

class Facility {
  final String id;            // Firestore document ID
  final String name;          // Name of the park/facility
  final String description;   // Description of the park
  final String imageUrl;      // URL to an image (fallback to placeholder if missing)

  Facility({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Facility.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Facility(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Facility',
      description: data['description'] ?? 'No description provided.',
      imageUrl: data['image_url'] ??
          'https://via.placeholder.com/150.png?text=No+Image',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
