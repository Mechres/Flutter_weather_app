import 'package:flutter/material.dart';
import 'forecast.dart';
import '../services/places_service.dart';
import '../utils/weather_animations.dart';
import '../theme/theme_provider.dart';
import '../services/weather_service.dart';
import '../services/current_location.dart';
import '../services/lat_weather.dart';
import '../services/reverse_geocode.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../services/storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _controller = TextEditingController();
  String? city;
  Map<String, dynamic>? weatherData;
  String? cityPhotoUrl;
  PlacesService placesService = PlacesService();
  bool isLoading = false;
  bool isCelsius = true;
  late final StorageService _storage;

  @override
  void initState() {
    super.initState();
    _storage = Provider.of<StorageService>(context, listen: false);

    // Initialize image cache
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.clear();

    _loadLastCity();
  }

  @override
  void dispose() {
    _controller.dispose();
    PaintingBinding.instance.imageCache.clear();
    super.dispose();
  }

  Future<void> _loadLastCity() async {
    if (!mounted) return;

    final lastCity = _storage.getLastCity();
    if (lastCity != null) {
      setState(() {
        city = lastCity;
        _controller.text = lastCity;
      });
      await fetchWeather();
      await fetchCityPhoto(lastCity);
    }
  }

  Future<void> fetchCityPhoto(String city) async {
    try {
      String? photoUrl = await placesService.getCityPhotoUrl(city);
      if (!mounted) return;

      setState(() {
        cityPhotoUrl = photoUrl;
      });

      // Pre-cache the image
      if (photoUrl != null) {
        await precacheImage(CachedNetworkImageProvider(photoUrl), context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load city image')));
    }
  }

  Future<void> fetchWeather() async {
    if (city != null && city!.isNotEmpty) {
      WeatherService weatherService = WeatherService();
      var data = await weatherService.getWeather(city!);
      if (!mounted) return;

      setState(() {
        weatherData = data;
      });
      await _storage.saveLastCity(city!);
    }
  }

  Future<void> getLocationWeather() async {
    setState(() {
      isLoading = true;
    });

    try {
      final position = await getCurrentLocation();
      final weatherData = await getWeatherByLocation(position);
      final cityName = await getCityFromCoordinates(position);

      setState(() {
        this.weatherData = weatherData;
        city = cityName;
        _controller.text = cityName;
      });

      await fetchCityPhoto(cityName);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshWeather() async {
    if (city != null) {
      await fetchWeather();
    }
  }

  Color _getTemperatureColor(double temp) {
    if (temp <= 0) return Colors.blue[900]!;
    if (temp <= 10) return Colors.blue[500]!;
    if (temp <= 20) return Colors.green;
    if (temp <= 30) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(int timestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String getTemperature() {
    if (weatherData == null) return '';
    double tempC = double.parse(weatherData!['main']['temp'].toString());
    if (isCelsius) {
      return '${tempC.toStringAsFixed(1)}°C';
    } else {
      double tempF = (tempC * 9 / 5) + 32;
      return '${tempF.toStringAsFixed(1)}°F';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _appBar(themeProvider),
      body: RefreshIndicator(
        onRefresh: _refreshWeather,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 25),
                // Search TextField
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Şehir Adı giriniz",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: isLoading ? null : getLocationWeather,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (value) {
                      fetchCityPhoto(value);
                      setState(() {
                        city = _controller.text;
                      });
                      fetchWeather();
                    },
                  ),
                ),

                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),

                if (weatherData != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      // City Photo
                      if (cityPhotoUrl != null)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CachedNetworkImage(
                              imageUrl: cityPhotoUrl!,
                              fit: BoxFit.cover,
                              width: size.width * 0.85,
                              height: 200,
                              memCacheWidth: (size.width * 0.85).round(),
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error, color: Colors.red),
                                        SizedBox(height: 4),
                                        Text(
                                          'Image not available',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                      // City Name
                      Text(
                        "${weatherData!['name']}",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),

                      // Weather Animation
                      Transform.scale(
                        scale: 1.0,
                        child: Lottie.asset(
                          getWeatherAnimation(
                            weatherData!['weather'][0]['main'],
                          ),
                          width: 180,
                          height: 180,
                          frameRate: FrameRate(
                            30,
                          ), // Reducde frame rate for optimization
                          repeat: true,
                        ),
                      ),

                      // Temperature
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isCelsius = !isCelsius;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: _getTemperatureColor(
                              double.parse(
                                weatherData!['main']['temp'].toString(),
                              ),
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            getTemperature(),
                            style: TextStyle(
                              fontSize: 48,
                              color: _getTemperatureColor(
                                double.parse(
                                  weatherData!['main']['temp'].toString(),
                                ),
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      // Weather Description
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${weatherData!['weather'][0]['description']}'
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      // Weather Info Cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          _buildInfoCard(
                            "Nem",
                            "${weatherData!['main']['humidity']}%",
                            Icons.water_drop,
                          ),
                          _buildInfoCard(
                            "Hissedilen",
                            "${weatherData!['main']['feels_like']}°C",
                            Icons.thermostat,
                          ),
                          _buildInfoCard(
                            "Basınç",
                            "${weatherData!['main']['pressure']} hPa",
                            Icons.speed,
                          ),
                          _buildInfoCard(
                            "Gün Doğumu/Batımı",
                            "${_formatTime(weatherData!['sys']['sunrise'])}\n${_formatTime(weatherData!['sys']['sunset'])}",
                            Icons.wb_sunny,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      // Forecast Button
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => WeatherForecastScreen(
                                      city: weatherData!['name'],
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            '5 Günlük Tahmin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _appBar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text("Hava Durumu"),
      actions: [
        IconButton(
          onPressed: () => themeProvider.toggleTheme(),
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
