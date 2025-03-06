import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/const/api.dart';

class WeatherService {
  final String apiKey = weatherApiKey;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse(
      '$baseUrl?q=$city&appid=$apiKey&units=metric&lang=tr',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to weather service: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getForecast(String city) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=tr',
    );
    // Implement 5-day forecast
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data["list"]);
      } else {
        throw Exception('Failed to get forecast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }
}
