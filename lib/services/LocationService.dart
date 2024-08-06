import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  Position? _cachedPosition;
  DateTime? _lastLocationUpdate;

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

   Future<Position?> getCachedOrCurrentLocation() async {
    if (_cachedPosition != null && _lastLocationUpdate != null) {
      // Check if the cached location is less than 5 minutes old
      if (DateTime.now().difference(_lastLocationUpdate!) < const Duration(minutes: 5)) {
        return _cachedPosition;
      }
    }

    // If there's no cached position or it's too old, get a new one
    Position? newPosition = await getCurrentLocation();
    if (newPosition != null) {
      _cachedPosition = newPosition;
      _lastLocationUpdate = DateTime.now();
    }
    return _cachedPosition;
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