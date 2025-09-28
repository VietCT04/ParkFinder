class Amenity {
  final String parkName;
  final List<String> amenities;

  Amenity({required this.parkName, required this.amenities});

  // Factory method to create Amenity object from Firestore data
  factory Amenity.fromFirestore(Map<String, dynamic> data) {
    return Amenity(
      parkName: data['parkName'] ?? '',
      amenities: List<String>.from(data['amenities'] ?? []),
    );
  }
}
