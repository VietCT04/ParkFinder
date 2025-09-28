import 'package:flutter/foundation.dart';

class User {
  /// Unique identifier (Firebase UID)
  final String id;

  /// Full name of the user
  final String name;

  /// Email address of the user
  final String email;

  /// Phone number of the user
  final String phoneNumber;

  /// Flag indicating if this user is an admin
  final bool isAdmin;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isAdmin,
  });

  /// Factory constructor to create a User instance from Firestore data.
  /// [data] is a Map of the document fields and [docId] is the document ID.
  factory User.fromMap(Map<String, dynamic> data, String docId) {
    return User(
      id: docId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      // It looks for a field 'admin' (or 'isAdmin')—defaulting to false if not present.
      isAdmin: data['admin'] ?? false,
    );
  }

  /// Convert the User instance into a Map for storage in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'admin': isAdmin,
    };
  }
}
