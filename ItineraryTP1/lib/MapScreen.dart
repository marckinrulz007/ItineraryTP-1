import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'DirectionsProvider.dart';
import 'main.dart';

class MapScreen extends StatefulWidget {
  final LatLng fromPoint = LatLng(-12.0845573, -77.0957274);
  final LatLng toPoint1 = LatLng(-12.15306, -77.0277911);
  final LatLng toPoint2 = LatLng(-12.1627063, -77.0302096);
  final LatLng toPoint3 = LatLng(-12.1496222, -77.0274343);
  final LatLng toPoint4 = LatLng(-12.0699213, -77.1651174);
  final LatLng toPoint5 = LatLng(-12.0695005, -77.1643283);
  final LatLng toPoint6 = LatLng(-12.0746734,-77.1616186);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinerary'),
      ),
      body: Consumer<DirectionProvider>(
        builder: (BuildContext context, DirectionProvider api, Widget child) {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.fromPoint,
              zoom: 12,
            ),
            markers: _createMarkers(api),
            polylines: api.currentRoute,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.zoom_out_map),
        onPressed: _centerView,
      ),
    );

  }

  Set<Marker> _createMarkers(DirectionProvider api) {
    var tmp = Set<Marker>();

    // Agregar marcadores para fromPoint y toPoint
    tmp.add(
      Marker(
        markerId: MarkerId("fromPoint"),
        position: widget.fromPoint,
        infoWindow: InfoWindow(title: "casa"),
      ),
    );
    tmp.add(
      Marker(
        markerId: MarkerId("toPoint1"),
        position: widget.toPoint1,
        infoWindow: InfoWindow(title: "Playa los Yuyos"),
      ),
    );
    tmp.add(
      Marker(
        markerId: MarkerId("toPoint2"),
        position: widget.toPoint2,
        infoWindow: InfoWindow(title: "Agua dulce"),
      ),
    );

    tmp.add(
      Marker(
        markerId: MarkerId("toPoint3"),
        position: widget.toPoint3,
        infoWindow: InfoWindow(title: "Playa Barranco"),
      ),
    );
    tmp.add(
      Marker(
        markerId: MarkerId("toPoint4"),
        position: widget.toPoint4,
        infoWindow: InfoWindow(title: "Playa Cantolao"),
      ),
    );
    tmp.add(
      Marker(
        markerId: MarkerId("toPoint5"),
        position: widget.toPoint5,
        infoWindow: InfoWindow(title: "Playa Malecon Pardo"),
      ),
    );
    tmp.add(
      Marker(
        markerId: MarkerId("toPoint6"),
        position: widget.toPoint6,
        infoWindow: InfoWindow(title: "Playa La Arenilla"),
      ),
    );

    // Agregar marcadores desde DirectionProvider
      tmp.addAll(api.currentMarkers);

    return tmp;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    _centerView();
  }

  _centerView() async {
    var api = Provider.of<DirectionProvider>(context);

    await _mapController.getVisibleRegion();

    print("buscando direcciones");
    await api.findDirections(widget.fromPoint, widget.toPoint1);

    var left = min(widget.fromPoint.latitude, widget.toPoint1.latitude);
    var right = max(widget.fromPoint.latitude, widget.toPoint1.latitude);
    var top = max(widget.fromPoint.longitude, widget.toPoint1.longitude);
    var bottom = min(widget.fromPoint.longitude, widget.toPoint1.longitude);



    api.currentRoute.first.points.forEach((point) {
      left = min(left, point.latitude);
      right = max(right, point.latitude);
      top = max(top, point.longitude);
      bottom = min(bottom, point.longitude);
    });

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.animateCamera(cameraUpdate);
  }
}