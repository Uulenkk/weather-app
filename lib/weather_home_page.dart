import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService _weatherService = WeatherService();

  String city = "Ulaanbaatar";
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? forecastData;
  List<Map<String, dynamic>>? dailyForecast;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() => isLoading = true);
    try {
      final current = await _weatherService.getCurrentWeather(city);
      final forecast = await _weatherService.getForecast(city);

      final daily = await _weatherService.getDailyFrom3HourForecast(city);
      setState(() {
        weatherData = current;
        forecastData = forecast;
        dailyForecast = daily;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFFBC6FF1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : weatherData == null
              ? const Center(
                  child: Text(
                    "Алдаа гарлаа",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${weatherData!['name']}, ${weatherData!['sys']['country']}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${weatherData!['main']['temp'].round()}°C",
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "${weatherData!['weather'][0]['description']}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeatherDetail(
                            label: "Чийгшил",
                            value: "${weatherData!['main']['humidity']}%",
                          ),
                          WeatherDetail(
                            label: "Салхи",
                            value: "${weatherData!['wind']['speed']} m/s",
                          ),
                          WeatherDetail(
                            label: "Даралт",
                            value: "${weatherData!['main']['pressure']} hPa",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Цагаар харах",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 24,
                                itemBuilder: (context, index) {
                                  final item = forecastData!['list'][index];
                                  final time =
                                      DateTime.fromMillisecondsSinceEpoch(
                                        item['dt'] * 1000,
                                      );
                                  final temp = item['main']['temp'].round();
                                  final desc = item['weather'][0]['main'];

                                  return HourlyForecast(
                                    time: "${time.hour}:00",
                                    temp: "$temp°C",
                                    icon: desc.contains("Cloud")
                                        ? Icons.cloud
                                        : Icons.wb_sunny,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "7 Day Forecast",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: dailyForecast!.length,
                                    itemBuilder: (context, index) {
                                      final item = dailyForecast![index];

                                      final dt = DateTime.parse(item['day']);

                                      final dayName = [
                                        "Даваа",
                                        "Мягмар",
                                        "Лхагва",
                                        "Пүрэв",
                                        "Баасан",
                                        "Бямба",
                                        "Ням",
                                      ][dt.weekday - 1];

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              dayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  item['desc'].contains("Cloud")
                                                      ? Icons.cloud
                                                      : Icons.wb_sunny,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "${item['min']}° / ${item['max']}°",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final String label;
  final String value;

  const WeatherDetail({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class HourlyForecast extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;

  const HourlyForecast({
    super.key,
    required this.time,
    required this.temp,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(temp, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(
            time,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
