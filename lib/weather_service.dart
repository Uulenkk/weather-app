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

  Future<List<Map<String, dynamic>>> getDailyFrom3HourForecast(
    String city,
  ) async {
    final url = Uri.parse(
      "$baseUrl/forecast?q=$city&appid=$apiKey&units=metric",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];
      Map<String, List<dynamic>> grouped = {};
      for (var item in list) {
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        String day =
            "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

        if (!grouped.containsKey(day)) grouped[day] = [];
        grouped[day]!.add(item);
      }
      List<Map<String, dynamic>> daily = [];
      grouped.forEach((day, items) {
        double minTemp = double.infinity;
        double maxTemp = -double.infinity;
        Map<String, int> descCount = {};

        for (var it in items) {
          double t = it['main']['temp'];
          if (t < minTemp) minTemp = t;
          if (t > maxTemp) maxTemp = t;

          String desc = it['weather'][0]['main'];
          descCount[desc] = (descCount[desc] ?? 0) + 1;
        }
        String finalDesc = descCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        daily.add({
          "day": day,
          "min": minTemp.round(),
          "max": maxTemp.round(),
          "desc": finalDesc,
        });
      });
      daily.sort((a, b) => a['day'].compareTo(b['day']));

      return daily;
    } else {
      throw Exception("3-hour forecast data авч чадсангүй");
    }
  }
}
