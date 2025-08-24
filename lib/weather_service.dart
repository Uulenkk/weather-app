import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "9e6cf6880871c052d65cfde785917c0b";
  final String baseUrl = "https://api.openweathermap.org/data/2.5";

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final url = Uri.parse(
      "$baseUrl/weather?q=$city&appid=$apiKey&units=metric",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Weather data авч чадсангүй!");
    }
  }

  Future<Map<String, dynamic>> getForecast(String city) async {
    final url = Uri.parse(
      "$baseUrl/forecast?q=$city&appid=$apiKey&units=metric",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Forecast data авч чадсангүй!");
    }
  }
}
