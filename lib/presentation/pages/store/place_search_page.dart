import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/datasources/places_service.dart';
import '../../../data/models/place_result.dart';

import '../../../core/themes/app_theme.dart';

class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({super.key});

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final _placesService = PlacesService();
  final TextEditingController _controller = TextEditingController();
  List<PlaceResult> _results = [];
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final position = await Geolocator.getCurrentPosition();
        _latitude = position.latitude;
        _longitude = position.longitude;
      }
    } catch (_) {}
  }

  Future<void> _search(String value) async {
    if (value.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final res = await _placesService.searchPlacesByName(
        name: value,
        latitude: _latitude,
        longitude: _longitude,
      );
      if (!mounted) return;
      setState(() {
        _results = res;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Local'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Digite o nome do local...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _search('');
                  },
                ),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final p = _results[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}',
                  ),
                  onTap: () {
                    Navigator.pop(context, p);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
