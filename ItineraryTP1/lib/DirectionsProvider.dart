import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';

class DirectionProvider extends ChangeNotifier {
  GoogleMapsDirections directionsApi =
  GoogleMapsDirections(apiKey: "AIzaSyCbzGJelyLTs4pnVsZSkeh8bWHUBml0HLY");

  GoogleMapsPlaces placesApi =
  GoogleMapsPlaces(apiKey: "AIzaSyCbzGJelyLTs4pnVsZSkeh8bWHUBml0HLY");

  Set<maps.Polyline> _route = Set();
  Set<maps.Marker> _markers = Set();

  Set<maps.Polyline> get currentRoute => _route;
  Set<maps.Marker> get currentMarkers => _markers;

  set currentMarkers(Set<maps.Marker> markers) {
    _markers = markers;
    notifyListeners();
  }

  Future<void> findDirections(maps.LatLng from, maps.LatLng to) async {
    var origin = Location(from.latitude, from.longitude);
    var destination = Location(to.latitude, to.longitude);

    var result = await directionsApi.directionsWithLocation(
      origin,
      destination,
      travelMode: TravelMode.driving,
    );

    Set<maps.Polyline> newRoute = Set();

    if (result.isOkay) {
      var route = result.routes[0];
      var leg = route.legs[0];

      List<maps.LatLng> points = [];

      leg.steps.forEach((step) {
        points.add(maps.LatLng(step.startLocation.lat, step.startLocation.lng));
        points.add(maps.LatLng(step.endLocation.lat, step.endLocation.lng));
      });

      var line = maps.Polyline(
        points: points,
        polylineId: maps.PolylineId("mejor ruta"),
        color: Colors.red,
        width: 4,
      );
      newRoute.add(line);

      _route = newRoute;
      notifyListeners();
    } else {
      print("ERRROR !!! ${result.status}");
    }
  }


  Future<List<PlacesSearchResult>> searchPlacesNearby(
      maps.LatLng location, String playa) async {
    var result = await placesApi.searchNearbyWithRadius(
      Location(location.latitude, location.longitude),
      225000, // Radio de búsqueda en metros (ajusta según tus necesidades)
      keyword: playa,
    );

    if (result.status == 'OK') {
      return result.results;
    } else {
      print("Error en la búsqueda de lugares cercanos: ${result.errorMessage}");
      return [];
    }
  }
}