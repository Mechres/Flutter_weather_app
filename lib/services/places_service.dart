import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/const/api.dart';

class PlacesService {
  final String apiKey = placeApiKey;

  Future<String?> getCityPhotoUrl(String cityName) async {
    // Get Place ID
    final placeSearchUrl =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
        "?input=$cityName&inputtype=textquery&fields=place_id"
        "&key=$apiKey";

    final placeResponse = await http.get(Uri.parse(placeSearchUrl));
    if (placeResponse.statusCode == 200) {
      final placeData = jsonDecode(placeResponse.body);
      if (placeData["candidates"].isNotEmpty) {
        final placeId = placeData["candidates"][0]["place_id"];

        // Get photo ref
        final detailsUrl =
            "https://maps.googleapis.com/maps/api/place/details/json"
            "?place_id=$placeId&fields=photos&key=$apiKey";

        final detailsResponse = await http.get(Uri.parse(detailsUrl));
        if (detailsResponse.statusCode == 200) {
          final detailsData = jsonDecode(detailsResponse.body);
          if (detailsData["result"]["photos"] != null) {
            final photoReference =
                detailsData["result"]["photos"][0]["photo_reference"];

            // Get photo url
            final photoUrl =
                "https://maps.googleapis.com/maps/api/place/photo"
                "?maxwidth=800&photo_reference=$photoReference&key=$apiKey";

            return photoUrl;
          }
        }
      }
    }
    return null;
  }
}
