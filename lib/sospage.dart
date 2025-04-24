// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sheon/callpage.dart';
import 'package:sheon/color.dart';
import 'package:sheon/map.dart';
import 'package:sheon/safelocations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sheon/contact_manager.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:vibration/vibration.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  Position? _currentPosition;
  String _nearestPoliceStation = "Searching...";
  bool _sosActivated = false;
  LatLng? _policeStationLocation;
  List<String> emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _triggerVibration();
    _getCurrentLocation();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    setState(() {
      _nearestPoliceStation = "Loading emergency contacts...";
    });

    List<Contact> contacts = await ContactManager.loadContacts();
    setState(() {
      emergencyContacts = contacts
          .map((contact) => contact.phoneNumbers?.first ?? "")
          .where((phone) => phone.isNotEmpty)
          .toList();
    });

    if (_currentPosition == null) {
      await _getCurrentLocation();
    }
    _sendSOS();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
      _policeStationLocation = LatLng(
          position.latitude + 0.01, position.longitude + 0.01);
      _nearestPoliceStation = "Nearest Police Station location available";
    });
  }

  void _triggerVibration() {
    try {
      Vibration.vibrate(duration: 500);
    } catch (e) {
      _showSnackBar("Vibration not supported on this device.");
    }
  }

  Future<void> _openGoogleMapsRoute() async {
    if (_policeStationLocation == null) {
      _showSnackBar("Location data not available yet.");
      return;
    }

    String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&destination=${_policeStationLocation!.latitude},${_policeStationLocation!.longitude}&travelmode=driving";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar("Could not open Google Maps.");
    }
  }

  Future<void> _sendSOS() async {
    if (_currentPosition == null) return;

    setState(() {
      _sosActivated = true;
    });

    String message =
        "Sheon: SOS! I need help. My location: https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}";

    try {
      for (String contact in emergencyContacts) {
        if (contact.isNotEmpty) {
          String smsUrl = "sms:$contact?body=${Uri.encodeComponent(message)}";
          if (await canLaunchUrl(Uri.parse(smsUrl))) {
            await launchUrl(Uri.parse(smsUrl));
          }
        }
      }
    } catch (e) {
      _showSnackBar("Failed to send some SOS messages.");
    }
  }

  void _backoff() {
    setState(() {
      _sosActivated = false;
    });
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Page'),backgroundColor: AppColors.primary,),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Help is arriving!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Steps to avoid danger:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "- Stay calm and move to a safe location.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SafeLocationsPage()),
                      ),
                      child: Text(
                        "Find Safe Places",
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "- Avoid unsafe areas.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapScreen()),
                      ),
                      child: Text(
                        "View Danger Zones",
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "- Keep your phone accessible.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "- Stay on the line with emergency contacts.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactPickerPage()),
                      ),
                      child: Text(
                        "My Contacts",
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      _nearestPoliceStation,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_policeStationLocation != null)
                      TextButton(
                        onPressed: _openGoogleMapsRoute,
                        child: Text(
                          "Navigate to Police Station",
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _sosActivated ? _backoff : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Return'),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.textPrimary,
    );
  }
}