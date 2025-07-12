import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GPSUsage{


Future<String> getCurrentPlace() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location service is enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return 'Location services are disabled.';
  }

  // Request permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return 'Location permissions are denied';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return 'Location permissions are permanently denied';
  }

  // Get current position
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // Reverse geocoding to get place name
  List<Placemark> placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );

  if (placemarks.isNotEmpty) {
    final Placemark place = placemarks.first;
    return place.locality ?? place.subLocality ?? 'Unknown location';
  } else {
    return 'Place not found';
  }
}

}