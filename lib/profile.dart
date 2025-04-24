import 'package:flutter/material.dart';
import 'package:sheon/EditPage';
import 'package:sheon/about.dart';
import 'package:sheon/color.dart';
import 'package:sheon/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'User';
  String _email = 'example@example.com';
  File? _avatarImage;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load saved profile data when the page initializes
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'User';
      _email = prefs.getString('email') ?? 'example@example.com';
      final avatarPath = prefs.getString('avatarImage');
      if (avatarPath != null && File(avatarPath).existsSync()) {
        _avatarImage = File(avatarPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.secondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(),
                ),
              ).then((_) {
                // Reload profile data after returning from EditPage
                _loadProfileData();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: _avatarImage != null
                  ? FileImage(_avatarImage!)
                  : null,
              child: _avatarImage == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 20),
            // User Name
            Text(
              _name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // User Email
            Text(
              _email,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 40),
            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Settings Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.settings, color: AppColors.secondary),
                        SizedBox(width: 15),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // About Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info, color: AppColors.secondary),
                        SizedBox(width: 15),
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.chevron_right, color: AppColors.secondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Additional Info
          ],
        ),
      ),
      backgroundColor: AppColors.primary,
    );
  }
}

// Settings Page
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLeftHandMode = false; // Define the state variable

  @override
  void initState() {
    super.initState();
    _loadLeftHandMode(); // Load the saved value on initialization
  }

  Future<void> _loadLeftHandMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLeftHandMode = prefs.getBool('isLeftHandMode') ?? false; // Default to false
    });
  }

  Future<void> _saveLeftHandMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLeftHandMode', value); // Save the value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        color: AppColors.primary,
        child: ListView(
          children: [
            const ListTile(
              leading: Icon(Icons.notifications, color: AppColors.secondary),
              title: Text('Notifications'),
              trailing: Icon(Icons.chevron_right, color: AppColors.secondary),
            ),
            const ListTile(
              leading: Icon(Icons.privacy_tip, color: AppColors.secondary),
              title: Text('Privacy'),
              trailing: Icon(Icons.chevron_right, color: AppColors.secondary),
            ),
            const ListTile(
              leading: Icon(Icons.security, color: AppColors.secondary),
              title: Text('Security'),
              trailing: Icon(Icons.chevron_right, color: AppColors.secondary),
            ),
            const ListTile(
              leading: Icon(Icons.language, color: AppColors.secondary),
              title: Text('Language'),
              trailing: Icon(Icons.chevron_right, color: AppColors.secondary),
            ),
            SwitchListTile(
                title: const Text('Left Hand Mode'),
                activeColor: AppColors.secondary,
              secondary: const Icon(Icons.swap_horiz, color: AppColors.secondary),
              value: isLeftHandMode, // Use the state variable
              onChanged: (bool value) {
                setState(() {
                  isLeftHandMode = value; // Update the state variable
                });
                _saveLeftHandMode(value); // Save the value to SharedPreferences
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(isLeftHandMode: isLeftHandMode),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// About Page
