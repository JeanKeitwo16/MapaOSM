import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;
  LocationModel? _location;
  bool _isLoading = true;

  LocationModel? get location => _location;
  bool get isLoading => _isLoading;

  

void startLocationUpdates() {
  _positionSubscription = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // atualiza a cada 10 metros
    ),
  ).listen((Position position) {
    _location = LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    notifyListeners();
  });
}


@override
void dispose() {
  _positionSubscription?.cancel();
  super.dispose();
}


  Future<void> fetchLocation() async {
    _isLoading = true;
    notifyListeners();

    Position? position = await _locationService.getCurrentPosition();

    if (position != null) {
      _location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    _isLoading = false;
    notifyListeners();

  }
}
