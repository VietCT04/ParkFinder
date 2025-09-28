import 'dart:convert';
import 'package:http/http.dart' as https;

//fetching weather from the api based on coordinates

class Weather {
  //getting the current weather using lat & long

  Future<Map<String, dynamic>?> getWeather(double lat, double long) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current_weather=true',
    );

    try {
      //got response
      final response = await https.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data['current_weather'];
      } else {
        print("Failed to load");

        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}

/// WeatherModel represents the weather data structure.
class WeatherModel {
  final String id;
  final String condition;
  final double temperature;

  WeatherModel({
    required this.id,
    required this.condition,
    required this.temperature,
  });

  /// Factory method to create a WeatherModel from a Firestore document.
  factory WeatherModel.fromMap(Map<String, dynamic> data, String documentId) {
    return WeatherModel(
      id: documentId,
      condition: data['condition'] ?? 'Unknown',
      temperature: (data['temperature'] ?? 0).toDouble(),
    );
  }
}
