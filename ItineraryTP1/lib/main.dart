import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

import 'MapScreen.dart';
import 'DirectionsProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (_) => DirectionProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => MyHomePage(),
          '/Map': (context) => MapScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  final LatLng initialLocation = LatLng(-12.0845573, -77.0957274);
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<bool> _selectedCheckboxes = List.generate(10, (index) => false);
  List<String> _checkboxNames = [
    'Playa',
    'Arqueología',
    'Deporte Aventura',
    'Trekking',
    'Hiking',
    'Gastronomía',
    'Naturaleza',
    'Cultural',
    'Café',
    'Full Day',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinerary App - Preferences'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            child: Text('generate'),
            onPressed: () {
              //a la 2da pagina
              Navigator.pushNamed(context, '/Map');
            },
          ),
          SizedBox(height: 20),
          Text(
            'Select options:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          // Crear y mostrar 10 checkboxes con nombres
          for (int i = 0; i < 10; i++)
            CheckboxListTile(
              title: Text(_checkboxNames[i]),
              value: _selectedCheckboxes[i],
              onChanged: (value) {
                setState(() {
                  _selectedCheckboxes[i] = value ?? false;
                });

                // Llamar a la función de búsqueda de lugares cuando se selecciona una opción
                if (value) {
                  _performSearch(_checkboxNames[i]);
                }
              },
            ),
          // Mostrar la lista de lugares

        ],
      ),
    );
  }


  void _performSearch(String keyword) async {
    var api = Provider.of<DirectionProvider>(context, listen: false);
    List<PlacesSearchResult> places = await api.searchPlacesNearby(widget.initialLocation, keyword.toLowerCase());

    print('Places: $places');
    // Llamar a la función _createMarkers y establecer los marcadores directamente
    api.currentMarkers = _createMarkers(places);
  }

  Set<Marker> _createMarkers(List<PlacesSearchResult> places) {
    var tmp = Set<Marker>();

    // Agregar marcadores para las playas
    for (var place in places) {
      tmp.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(
            place.geometry.location.lat,
            place.geometry.location.lng,
          ),
          infoWindow: InfoWindow(title: place.name),
        ),
      );
    }
    return tmp;
  }
}