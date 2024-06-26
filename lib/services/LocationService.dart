import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  Future<bool> initializeLocationServices() async 
  {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }

    await _savePermissionStatus(true);
    return true;
  }

  Future<void> _savePermissionStatus(bool status) async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_permission_granted', status);
  }

  Future<Position?> getCurrentLocation() async 
  {
    try {
      bool permissionGranted = await checkLocationPermissionStatus();
      if (!permissionGranted) {
        bool initialized = await initializeLocationServices();
        if (!initialized) {
          print('Failed to initialize location services');
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<bool> checkLocationPermissionStatus() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('location_permission_granted') ?? false;
  }

  Future<Position?> getLastKnownPosition() async 
  {
    return await Geolocator.getLastKnownPosition();
  }
}