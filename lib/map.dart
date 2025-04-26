// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sheon/color.dart';
import 'package:geodesy/geodesy.dart' as geodesy;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  LatLng _initialPosition = const LatLng(13.034006240677833, 80.17994635236231);
  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoordinates = [];
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  String _routeInfo = '';
  bool _avoidDangerZones = true;
  final geodesy.Geodesy _geodesy = geodesy.Geodesy();

  final List<Map<String, dynamic>> _dangerSpots = [
    {
      'position': const LatLng(13.008975231384602, 80.21303044039027

),
      'label': 'Knife threatening',
      'radius': 200.0,
    },
    {
      'position': const LatLng(12.997344828708407, 80.21202538456659),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(12.987037352125832, 80.22302259038999),
      'label': 'Gang Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(13.015379670868407, 80.21559885757873),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(13.000559355212186, 80.11620133357845),
      'label': 'Brutal attack',
      'radius': 150.0,
    },
    {
      'position': const LatLng(13.031927822883274, 80.14175406155508),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(13.038130881891545, 80.15423507356368),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(13.142999599910052, 80.12957290838338),
      'label': 'Gang robbery',
      'radius': 150.0,
    },
    {
      'position': const LatLng(13.0033024423548, 80.25585215829038),
      'label': 'Chain snatching',
      'radius': 250.0,
    },
    {
      'position': const LatLng(12.993838882625708, 80.25597876922545),
      'label': 'Break-in bid',
      'radius': 150.0,
    },
    {
      'position': const LatLng(13.034555156185768, 80.19633006426476),
      'label': 'Robbery & Murder',
      'radius': 100.0,
    },
    {
      'position': const LatLng(12.982369806362858, 80.25433483854287),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(12.988131899903797, 80.22342820117292),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(12.978417720216756, 80.04286220406476),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(12.887725601700106, 80.13764674251831),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(9.72170459048116, 77.85485031098828),
      'label': 'Murder',
      'radius': 150.0,
    },
   
    
    {
      'position': const LatLng(12.96314178530961, 80.21419087301189),
      'label': 'Chain snatching',
      'radius': 250.0,
    },
    {
      'position': const LatLng(10.435602147630382, 78.8152306855933),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(9.147442884309315, 77.99333188744399),
      'label': 'Setting ablaze',
      'radius': 100.0,
    },
    {
      'position': const LatLng(10.06892113435461, 78.0690126133834),
      'label': 'Murder',
      'radius': 150.0,
    },
    {
      'position': const LatLng(8.675667983316226, 77.86243909249518),
      'label': 'Case based murder',
      'radius': 50.0,
    },

  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _addDangerSpots();
  }

  void _addDangerSpots() {
    for (var spot in _dangerSpots) {
      final position = spot['position'] as LatLng;
      final label = spot['label'] as String;
      final radius = spot['radius'] as double;

      _markers.add(
        Marker(
          markerId: MarkerId('danger_${position.latitude}_${position.longitude}'),
          position: position,
          infoWindow: InfoWindow(title: label),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      _circles.add(
        Circle(
          circleId: CircleId('danger_zone_${position.latitude}_${position.longitude}'),
          center: position,
          radius: radius,
          strokeWidth: 2,
          strokeColor: Colors.red[800]!,
          fillColor: Colors.red.withOpacity(0.2),
        ),
      );
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _initialPosition = _currentPosition!;
        _markers.add(
          Marker(
            markerId: const MarkerId('userLocation'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });
      mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    } catch (e) {
      _showSnackBar('Error fetching location: $e');
    }
  }

  Future<void> _getRoute() async {
    String fromAddress = fromController.text.trim();
    String toAddress = toController.text.trim();

    if (fromAddress.isEmpty || toAddress.isEmpty) {
      _showSnackBar('Please enter both locations');
      return;
    }

    LatLng? fromLatLng = await _getLatLngFromAddress(fromAddress);
    LatLng? toLatLng = await _getLatLngFromAddress(toAddress);

    if (fromLatLng == null || toLatLng == null) {
      _showSnackBar('Invalid address');
      return;
    }

    await _fetchRoute(fromLatLng, toLatLng);
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    const String apiKey = "";
    String url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${from.latitude},${from.longitude}"
        "&destination=${to.latitude},${to.longitude}"
        "&key=$apiKey";

    List<String> waypoints = [];
    if (_avoidDangerZones) {
      waypoints = _calculateAvoidanceWaypoints(
        geodesy.LatLng(from.latitude, from.longitude),
        geodesy.LatLng(to.latitude, to.longitude),
      );

      if (waypoints.isNotEmpty) {
        url += "&waypoints=optimize:true|${waypoints.join('|')}";
      }
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'OK') {
          final route = jsonData['routes'][0];
          List<LatLng> routeCoords = _decodePolyline(route['overview_polyline']['points']);

          final avoidsDanger = _avoidDangerZones
              ? _doesRouteAvoidDangerZones(routeCoords)
              : true;

          final distance = route['legs'][0]['distance']['text'];
          final duration = route['legs'][0]['duration']['text'];

          setState(() {
            _routeCoordinates = routeCoords;
            _polylines.clear();
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              points: _routeCoordinates,
              color: avoidsDanger ? Colors.green : Colors.orange,
              width: 7,
            ));

            _routeInfo = 'Distance: $distance • Time: $duration';
            if (_avoidDangerZones) {
              _routeInfo += avoidsDanger
                  ? ' (Danger zones avoided)'
                  : ' (Warning: Route may pass near danger zones)';
            }

            final bounds = _calculateBounds(routeCoords);
            mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
          });

          if (_avoidDangerZones && !avoidsDanger) {
            _showSnackBar('Warning: Could not find a completely safe route');
          }
        } else {
          _showSnackBar('Directions API failed: ${jsonData['status']}');
        }
      } else {
        _showSnackBar('Failed to fetch route');
      }
    } catch (e) {
      _showSnackBar('Error fetching route: $e');
    }
  }

  double _distanceBetween(LatLng p1, LatLng p2) {
    return Geolocator.distanceBetween(
      p1.latitude,
      p1.longitude,
      p2.latitude,
      p2.longitude,
    );
  }

  double _bearingBetween(LatLng from, LatLng to) {
    final lat1 = from.latitude * pi / 180;
    final lon1 = from.longitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final lon2 = to.longitude * pi / 180;

    final y = sin(lon2 - lon1) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    final bearing = atan2(y, x);

    return (bearing * 180 / pi + 360) % 360;
  }

  double _distancePointToLineSegment(LatLng point, LatLng start, LatLng end) {
    final distA = _distanceBetween(point, start);
    final distB = _distanceBetween(point, end);
    final distAB = _distanceBetween(start, end);

    if (distAB < 1.0) return distA;

    final bearingAB = _bearingBetween(start, end);

    final projection = _geodesy.destinationPointByDistanceAndBearing(
      geodesy.LatLng(start.latitude, start.longitude),
      distA,
      bearingAB,
    );

    final distAProjection = _distanceBetween(
      start,
      LatLng(projection.latitude, projection.longitude),
    );
    final distBProjection = _distanceBetween(
      end,
      LatLng(projection.latitude, projection.longitude),
    );

    if ((distAProjection + distBProjection - distAB).abs() < 1.0) {
      return _distanceBetween(
        point,
        LatLng(projection.latitude, projection.longitude),
      );
    } else {
      return min(distA, distB);
    }
  }

  bool _doesRouteAvoidDangerZones(List<LatLng> route) {
    for (var i = 0; i < route.length - 1; i++) {
      final segmentStart = route[i];
      final segmentEnd = route[i + 1];

      for (var spot in _dangerSpots) {
        final dangerPos = spot['position'] as LatLng;
        final radius = spot['radius'] as double;

        final distance = _distancePointToLineSegment(
          dangerPos,
          segmentStart,
          segmentEnd,
        );

        if (distance <= radius) {
          return false;
        }
      }
    }
    return true;
  }

  bool _lineIntersectsCircle(LatLng start, LatLng end, LatLng center, double radius) {
    final startToCenter = _distanceBetween(start, center);
    final endToCenter = _distanceBetween(end, center);

    if (startToCenter <= radius || endToCenter <= radius) {
      return true;
    }

    final lineLength = _distanceBetween(start, end);

    final dotProduct = ((center.latitude - start.latitude) * (end.latitude - start.latitude) +
            (center.longitude - start.longitude) * (end.longitude - start.longitude)) /
        pow(lineLength, 2);

    final closestLat = start.latitude + dotProduct * (end.latitude - start.latitude);
    final closestLng = start.longitude + dotProduct * (end.longitude - start.longitude);

    final onSegment = _distanceBetween(start, LatLng(closestLat, closestLng)) +
            _distanceBetween(LatLng(closestLat, closestLng), end) <=
        lineLength * 1.0001;

    if (onSegment) {
      final distanceToCenter = _distanceBetween(
        LatLng(closestLat, closestLng),
        center,
      );
      return distanceToCenter <= radius;
    }

    return false;
  }

  List<String> _calculateAvoidanceWaypoints(geodesy.LatLng from, geodesy.LatLng to) {
    List<String> waypoints = [];

    final fromLatLng = LatLng(from.latitude, from.longitude);
    final toLatLng = LatLng(to.latitude, to.longitude);

    for (var spot in _dangerSpots) {
      final dangerPos = spot['position'] as LatLng;
      final radius = spot['radius'] as double;

      if (_lineIntersectsCircle(fromLatLng, toLatLng, dangerPos, radius)) {
        final bearing = _bearingBetween(fromLatLng, toLatLng);

        final leftPoint = _geodesy.destinationPointByDistanceAndBearing(
          geodesy.LatLng(dangerPos.latitude, dangerPos.longitude),
          radius * 1.5,
          bearing - 45,
        );

        final rightPoint = _geodesy.destinationPointByDistanceAndBearing(
          geodesy.LatLng(dangerPos.latitude, dangerPos.longitude),
          radius * 1.5,
          bearing + 45,
        );

        waypoints.add('${leftPoint.latitude},${leftPoint.longitude}');
        waypoints.add('${rightPoint.latitude},${rightPoint.longitude}');
      }
    }

    return waypoints;
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (var point in points) {
      minLat = minLat == null ? point.latitude : min(minLat, point.latitude);
      maxLat = maxLat == null ? point.latitude : max(maxLat, point.latitude);
      minLng = minLng == null ? point.longitude : min(minLng, point.longitude);
      maxLng = maxLng == null ? point.longitude : max(maxLng, point.longitude);
    }

    return LatLngBounds(
      northeast: LatLng(maxLat ?? _initialPosition.latitude, maxLng ?? _initialPosition.longitude),
      southwest: LatLng(minLat ?? _initialPosition.latitude, minLng ?? _initialPosition.longitude),
    );
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    const String apiKey = "AIzaSyBLRyC2CoTaD7wFZZIMpSo1E6QDztHwmNQ";
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'OK') {
          final location = jsonData['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      _showSnackBar('Error fetching location: $e');
    }
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _switchLocations() {
    setState(() {
      final temp = fromController.text;
      fromController.text = toController.text;
      toController.text = temp;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(
              _avoidDangerZones ? Icons.warning_amber : Icons.warning,
              color: _avoidDangerZones ? Colors.green : Colors.red,
            ),
            onPressed: () {
              setState(() {
                _avoidDangerZones = !_avoidDangerZones;
              });
              if (fromController.text.isNotEmpty && toController.text.isNotEmpty) {
                _getRoute();
              }
            },
            tooltip: _avoidDangerZones ? 'Avoiding danger zones' : 'Not avoiding danger zones',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15.0),
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            left: 10,
            right: 10,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fromController,
                        decoration: InputDecoration(
                          hintText: 'From',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () async {
                        if (_currentPosition != null) {
                          setState(() {
                            fromController.text =
                                '${_currentPosition!.latitude}, ${_currentPosition!.longitude}';
                          });
                        } else {
                          _showSnackBar('Current location not available');
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_vert),
                      onPressed: _switchLocations,
                    ),
                    Expanded(
                      child: TextField(
                        controller: toController,
                        decoration: InputDecoration(
                          hintText: 'To',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_routeInfo.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _routeInfo,
                      style: TextStyle(
                        color: _avoidDangerZones ? Colors.green : AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: _getRoute,
                      child: const Icon(Icons.arrow_forward, size: 20, color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 4),
                      const Text('Danger Spots'),
                      const SizedBox(width: 8),
                      Switch(
                        value: _avoidDangerZones,
                        onChanged: (value) {
                          setState(() {
                            _avoidDangerZones = value;
                          });
                          if (fromController.text.isNotEmpty && toController.text.isNotEmpty) {
                            _getRoute();
                          }
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                  Text(
                    _avoidDangerZones
                        ? 'Avoiding danger zones (green route)'
                        : 'Not avoiding danger zones',
                    style: TextStyle(
                      color: _avoidDangerZones ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
