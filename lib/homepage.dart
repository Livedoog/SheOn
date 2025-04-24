// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheon/callpage.dart';
import 'package:sheon/color.dart';
import 'package:sheon/help.dart';
import 'package:sheon/map.dart';
import 'package:sheon/profile.dart';
import 'package:sheon/safelocations.dart';
import 'package:sheon/sospage.dart';

class HomePage extends StatefulWidget {
  final bool isLeftHandMode;

  const HomePage({super.key, required this.isLeftHandMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestAllPermissions(context));
  }

  Future<void> _requestAllPermissions(BuildContext context) async {
    final statuses = await [
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.contacts,
    ].request();

    for (final entry in statuses.entries) {
      if (entry.value.isPermanentlyDenied) {
        _showPermissionDeniedSnackbar(context, entry.key);
      }
    }
  }

  void _showPermissionDeniedSnackbar(BuildContext context, Permission permission) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${permission.toString().split('.').last} permission is permanently denied. '
          'Please enable it in settings.',
        ),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: openAppSettings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loadLeftHandMode(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final isLeftHandMode = snapshot.data ?? false;

        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButton: _buildSOSButton(context, isLeftHandMode),
          backgroundColor: AppColors.primary,
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'Home',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.person, color: AppColors.secondary, size: 35),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 150),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 24.0,
              mainAxisSpacing: 24.0,
              children: [
                _buildCurvedButton(
                  title: 'Safe Map',
                  icon: Icons.map,
                  onPressed: () => _navigateTo(const MapScreen()),
                ),
                _buildCurvedButton(
                  title: 'Emergency Contacts',
                  icon: Icons.call,
                  onPressed: () => _navigateTo(const ContactPickerPage()),
                ),
                _buildCurvedButton(
                  title: 'Safe Place',
                  icon: Icons.home,
                  onPressed: () => _navigateTo(const SafeLocationsPage()),
                ),
                _buildCurvedButton(
                  title: 'Help',
                  icon: Icons.help,
                  onPressed: () => _navigateTo(const HelpPage()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurvedButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 120.0,
        width: 120.0,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.buttondark, AppColors.buttonlight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.buttondark.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context, bool isLeftHandMode) {
    return Align(
      alignment: isLeftHandMode 
          ? Alignment.bottomLeft 
          : Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SOSPage()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SOS alert has been sent!')),
            );
          },
          child: Container(
            height: 200.0,
            width: 200.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [AppColors.buttondark, AppColors.buttonlight],
                center: Alignment.center,
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.buttondark.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Press for 3 seconds',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _loadLeftHandMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLeftHandMode') ?? false;
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}