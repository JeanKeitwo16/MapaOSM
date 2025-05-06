import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../viewmodels/location_viewmodel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  LatLng? _ultimaPosicao;
  final TextEditingController _searchController = TextEditingController();

  

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<LocationViewModel>();
    viewModel.addListener(_onLocationChanged);
  }

  void _onLocationChanged() {
    final viewModel = context.read<LocationViewModel>();
    final loc = viewModel.location;
    if (loc != null) {
      final novaPosicao = LatLng(loc.latitude, loc.longitude);
      // só move se for diferente da anterior
      if (_ultimaPosicao == null || _ultimaPosicao != novaPosicao) {
        _mapController.move(novaPosicao, _mapController.camera.zoom);
        _ultimaPosicao = novaPosicao;
      }
    }
  }

  @override
  void dispose() {
    context.read<LocationViewModel>().removeListener(_onLocationChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<LatLng?> _buscarEndereco(String query) async {
  final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
  final response = await http.get(url, headers: {
    'User-Agent': 'quebra-galho-app/1.0 (email@exemplo.com)' // Edite para seu app
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      final lat = double.parse(data[0]['lat']);
      final lon = double.parse(data[0]['lon']);
      return LatLng(lat, lon);
    }
  }
  return null;
}


  @override
  Widget build(BuildContext context) {
    return Consumer<LocationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading || viewModel.location == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final location = viewModel.location!;
        final posicao = LatLng(location.latitude, location.longitude);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar endereço...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (query) async {
                  final latLng = await _buscarEndereco(query);
                  if (latLng != null) {
                    _mapController.move(latLng, 16);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Endereço não encontrado.')),
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: posicao,
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'br.edu.ifsul.flutter_mapas_osm',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: posicao,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
