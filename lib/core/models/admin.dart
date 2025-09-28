// admin.dart
import 'user.dart';

/// Specialized admin user, always isAdmin = true.
class Admin extends User {
  Admin({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
  }) : super(
         id: id,
         name: name,
         email: email,
         phoneNumber: phoneNumber,
         isAdmin: true, // Force admin to be true
       );

  /// Create an Admin from a Firestore map, always setting isAdmin = true
  factory Admin.fromMap(Map<String, dynamic> data, String docId) {
    return Admin(
      id: docId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  /// Convert this Admin to a Firestore-compatible map.
  @override
  Map<String, dynamic> toMap() {
    // Convert super to map
    final baseMap = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'admin': true, // Always admin
    };
    return baseMap;
  }
}
