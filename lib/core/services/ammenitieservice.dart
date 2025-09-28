import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park_finder/core/models/Amenity.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../models/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Assuming your stream for getting amenities is from a service like this:
class AmenitiesService {
  // Stream method to get a list of amenities from Firebase Firestore
  Stream<List<String>> getAmenities(String parkName) {
    return FirebaseFirestore.instance
        .collection('amenities')
        .where('parkName', isEqualTo: parkName)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => List<String>.from(doc['amenities'] ?? []))
              .first; // Assumes one document per park, change if necessary
        });
  }
}
