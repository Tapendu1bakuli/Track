import 'dart:async';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends GetxController {
  var currentLocation = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  ).obs;

  var totalDistance = 0.0.obs;
  Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;

  final double movementThreshold = 5.0; // Minimum distance change in meters
  final int stabilityDuration = 2000; // Time in milliseconds to consider location stable

  Position? previousLocation;
  DateTime? lastUpdateTime;

  @override
  void onInit() {
    super.onInit();
    _initLocation();
  }

  void _initLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationSubscription = location.onLocationChanged.listen((LocationData locData) {
      if (locData.latitude != null && locData.longitude != null) {
        final Position newLocation = Position(
          latitude: locData.latitude!,
          longitude: locData.longitude!,
          timestamp: DateTime.now(),
          accuracy: locData.accuracy!,
          altitude: locData.altitude!,
          heading: locData.heading!,
          speed: locData.speed!,
          speedAccuracy: locData.speedAccuracy!,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        if (previousLocation != null) {
          final double distance = Geolocator.distanceBetween(
            previousLocation!.latitude,
            previousLocation!.longitude,
            newLocation.latitude,
            newLocation.longitude,
          );

          if (distance > movementThreshold) {
            final DateTime now = DateTime.now();
            if (lastUpdateTime == null || now.difference(lastUpdateTime!) >= Duration(milliseconds: stabilityDuration)) {
              totalDistance.value += distance;
              lastUpdateTime = now;
            }
          }
        }

        // Update the previous location
        previousLocation = newLocation;
        currentLocation.value = newLocation;
      }
    });
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    super.onClose();
  }
}
