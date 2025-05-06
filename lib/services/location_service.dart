import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Obtém o nível da bateria
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;

    // Ajusta a precisão com base no nível da bateria
    LocationAccuracy accuracy;
    switch (batteryLevel) {
      case > 50:
        accuracy = LocationAccuracy.best; // Alta precisão para bateria acima de 50%
        break;
      case > 30:
        accuracy = LocationAccuracy.high; // Alta precisão para bateria entre 30% e 50%
        break;
      case > 20:
        accuracy = LocationAccuracy.medium; // Precisão média para bateria entre 20% e 30%
        break;
      default:
        accuracy = LocationAccuracy.low; // Baixa precisão para economizar bateria
    }

    // Retorna a posição atual com as configurações ajustadas
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: 10,
        timeLimit: const Duration(seconds: 10),
      ),
    );
  }
}
