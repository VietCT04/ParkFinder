import 'package:park_finder/core/models/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherController {
  Future<Map<String, dynamic>?> getCurrentWeather(double lat, double lng) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['current_weather'];
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch weather: $e');
    }
  }

  String getWeatherAnimationPath(int weatherCode) {
    if (weatherCode < 5) {
      return "Assets/Animation - 1743093274661.json";
    } else if (weatherCode > 45 && weatherCode <= 67) {
      return "Assets/Animation - 1743093573590.json";
    } else if (weatherCode > 71) {
      return "Assets/Animation - 1743093599336.json";
    } else {
      return "Assets/Animation - 1743095192625.json";
    }
  }

  String getWeatherMessage(int weatherCode) {
    if (weatherCode < 5) {
      return "Best time to visit the park!";
    } else if (weatherCode > 45 && weatherCode <= 67) {
      return "You may want to bring an umbrella.";
    } else if (weatherCode > 71) {
      return "Might be harsh weather. Stay safe!";
    } else {
      return "General weather conditions.";
    }
  }
}