import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherForecastScreen extends StatefulWidget {
  final String city;

  WeatherForecastScreen({required this.city});

  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final WeatherService weatherService = WeatherService();
  late Future<List<Map<String, dynamic>>> forecastData;

  @override
  void initState() {
    super.initState();
    forecastData = weatherService.getForecast(widget.city);
  }

  String _getDayName(DateTime date) {
    List<String> days = [
      'Pazar',
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
    ];
    return days[date.weekday % 7];
  }

  Color _getTemperatureColor(double temp) {
    if (temp <= 0) return Colors.blue[900]!;
    if (temp <= 10) return Colors.blue[500]!;
    if (temp <= 20) return Colors.green;
    if (temp <= 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${widget.city} - 5 Günlük Tahmin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: forecastData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Text('Tahmin verisi bulunamadı'),
                    ),
                  );
                }

                final List<Map<String, dynamic>> forecastList = snapshot.data!;
                String currentDay = '';

                return Column(
                  children: [
                    for (var forecast in forecastList) ...[
                      Builder(
                        builder: (context) {
                          final dateTime = DateTime.parse(forecast["dt_txt"]);
                          final temp = double.parse(
                            forecast["main"]["temp"].toString(),
                          );
                          final weatherDesc =
                              forecast["weather"][0]["description"];
                          final iconCode = forecast["weather"][0]["icon"];
                          final day = _getDayName(dateTime);

                          // Add day header if it's a new day
                          Widget? dayHeader;
                          if (currentDay != day) {
                            currentDay = day;
                            dayHeader = Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.color,
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (dayHeader != null) dayHeader,
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).cardColor,
                                        Theme.of(
                                          context,
                                        ).cardColor.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Image.network(
                                            "https://openweathermap.org/img/wn/$iconCode@2x.png",
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${dateTime.hour}:00",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                weatherDesc,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "${temp.toStringAsFixed(1)}°C",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: _getTemperatureColor(temp),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
