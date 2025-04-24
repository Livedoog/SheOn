// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sheon/color.dart';
import 'package:url_launcher/url_launcher.dart';

class SafeLocationsPage extends StatefulWidget {
  const SafeLocationsPage({super.key});

  @override
  _SafeLocationsPageState createState() => _SafeLocationsPageState();
}

class _SafeLocationsPageState extends State<SafeLocationsPage> {
  final List<String> _safeLocations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocations = prefs.getStringList('safeLocations') ?? [];
    setState(() {
      _safeLocations.addAll(savedLocations);
    });
  }

  Future<void> _saveLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('safeLocations', _safeLocations);
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _showAddLocationDialog() async {
    final TextEditingController labelController = TextEditingController();
    final TextEditingController latitudeController = TextEditingController();
    final TextEditingController longitudeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: const Center(
            child: Text(
              'Add Safe Location',
              style: TextStyle(color: Colors.white),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (await _checkLocationPermission()) {
                      final position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      );
                      latitudeController.text = position.latitude.toString();
                      longitudeController.text = position.longitude.toString();
                    }
                  },
                  child: const Text(
                    'Use Current Location',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.trim().isEmpty ||
                    latitudeController.text.trim().isEmpty ||
                    longitudeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields', style: TextStyle(color: Colors.red))),
                  );
                  return;
                }

                setState(() {
                  _safeLocations.add(
                    '${labelController.text.trim()}: Lat: ${latitudeController.text.trim()}, Long: ${longitudeController.text.trim()}',
                  );
                });
                _saveLocations();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Add',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Locations'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: SizedBox(
        width: 70, // Increase the width of the button
        height: 70, // Increase the height of the button
        child: FloatingActionButton(
          onPressed: _showAddLocationDialog,
          backgroundColor: AppColors.secondary, // Optional: Adjust the background color
          child: const Icon(
            Icons.add,color: AppColors.textPrimary,
            size: 40, // Increase the size of the icon
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _safeLocations.isEmpty
            ? const Center(
                child: Text(
                  'No safe locations added yet.\nClick the + button to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: AppColors.secondary),
                ),
              )
            : ListView.builder(
                itemCount: _safeLocations.length,
                itemBuilder: (context, index) {
                  final location = _safeLocations[index];
                  // Updated regex to match the format "Label: Lat: ..., Long: ..."
                  final regex = RegExp(r'^(.*?): Lat: ([\d.-]+), Long: ([\d.-]+)$');
                  final match = regex.firstMatch(location);

                  String label = 'Home';
                  String latitude = '';
                  String longitude = '';

                  if (match != null) {
                    label = match.group(1)!.trim();
                    latitude = match.group(2)!;
                    longitude = match.group(3)!;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: TextButton(
                        onPressed: () async {
                          if (latitude.isNotEmpty && longitude.isNotEmpty) {
                            final googleMapsUrl =
                                'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
                            if (await canLaunch(googleMapsUrl)) {
                              await launch(googleMapsUrl);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open Google Maps.')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid location format.')),
                            );
                          }
                        },
                        child: Text(
                          label,
                          style: TextStyle(color: AppColors.secondary, fontSize: 18),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () async {
                              final newLabel = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  final TextEditingController labelController =
                                      TextEditingController(text: label);
                                  return AlertDialog(
                                    title: const Text('Edit Label'),
                                    content: TextField(
                                      controller: labelController,
                                      decoration: const InputDecoration(
                                        labelText: 'New Label',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(labelController.text.trim());
                                        },
                                        child: Text(
                                          'Save',
                                          style: TextStyle(color: AppColors.secondary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: AppColors.secondary),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (newLabel != null && newLabel.isNotEmpty) {
                                setState(() {
                                  // Update the location with the new label while preserving coordinates
                                  _safeLocations[index] = '$newLabel: Lat: $latitude, Long: $longitude';
                                });
                                _saveLocations();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Label updated to "$newLabel"')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _safeLocations.removeAt(index);
                              });
                              _saveLocations();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      backgroundColor: AppColors.primary,
    );
  }
}