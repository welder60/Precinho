import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({super.key});

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  late FlutterGooglePlacesSdk _places;
  final TextEditingController _controller = TextEditingController();
  List<AutocompletePrediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    _places = FlutterGooglePlacesSdk(AppConstants.googleMapsApiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) async {
    if (value.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }
    final response = await _places.findAutocompletePredictions(value);
    setState(() {
      _predictions = response.predictions;
    });
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
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final p = _predictions[index];
                return ListTile(
                  title: Text(p.description ?? ''),
                  onTap: () async {
                    final detail = await _places.fetchPlace(
                      p.placeId!,
                      fields: [
                        PlaceField.ID,
                        PlaceField.ADDRESS,
                        PlaceField.LAT_LNG,
                        PlaceField.NAME,
                      ],
                    );
                    if (detail.place != null) {
                      Navigator.pop(context, detail.place);
                    }
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
