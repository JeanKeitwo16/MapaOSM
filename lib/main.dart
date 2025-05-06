import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/location_viewmodel.dart';
import 'views/map_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocationViewModel()..fetchLocation()..startLocationUpdates(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa OSM',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: Scaffold(
        appBar: AppBar(title: Text('Localização no Mapa')),
        body: const MapView(),
      ),
    );
  }
}
