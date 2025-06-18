import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({super.key});

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  late GooglePlace _googlePlace;
  final TextEditingController _controller = TextEditingController();
  List<AutocompletePrediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    _googlePlace = GooglePlace(AppConstants.googleMapsApiKey);
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
    final result = await _googlePlace.autocomplete.get(value);
    setState(() {
      _predictions = result?.predictions ?? [];
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
                    final detail = await _googlePlace.details.get(p.placeId!);
                    if (detail != null && detail.result != null) {
                      Navigator.pop(context, detail.result);
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
