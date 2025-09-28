import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:park_finder/core/models/user.dart'; // Using our User model
import 'package:park_finder/core/models/weather.dart';

class DataRepository {
  static final DataRepository _instance = DataRepository._internal();

  factory DataRepository() {
    return _instance;
  }

  DataRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch a single user by their UID.
  Future<User?> fetchUser(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  /// Returns a stream of all users.
  ///
  /// This demonstrates the Observer Pattern: the stream updates in real time.
  Stream<List<User>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return User.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Fetch weather data by a given weather document ID.
  Future<WeatherModel?> fetchWeather(String weatherId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('weather').doc(weatherId).get();
      if (doc.exists && doc.data() != null) {
        return WeatherModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching weather: $e");
      return null;
    }
  }

  /// Returns a stream for weather updates.
  ///
  /// This stream demonstrates the Observer Pattern.
  Stream<WeatherModel> getWeatherStream(String weatherId) {
    return _firestore.collection('weather').doc(weatherId).snapshots().map((
      docSnapshot,
    ) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return WeatherModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      } else {
        throw Exception("Weather data not found");
      }
    });
  }
}
