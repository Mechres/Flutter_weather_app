import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

Future<String> getCityFromCoordinates(Position position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      return placemarks[0].locality ?? "Unknown"; // City name
    } else {
      throw Exception("No city found.");
    }
  } catch (e) {
    throw Exception("Error fetching city: $e");
  }
}
