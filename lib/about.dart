import 'package:flutter/material.dart';
import 'package:sheon/color.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us',),
        centerTitle: true,
      backgroundColor: AppColors.primary,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Our App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              color: AppColors.secondary),
            ),
            SizedBox(height: 16),
            Text(
              'The "SheOn" application assists women to travel securely by providing safe routes based on real-time crime data and user reviews. It takes into account time, lighting, and crowd density, alerting users to possible dangers around them to realign routes.'

'One can share their position with trusted people and family friends for safety and trip tracking. There is also an SOS feature that calls the local emergency or police and informs chosen contacts about the users location.'

'The app communicates with local safety networks and keeps users profiles, crime information, locations, and safety reports in a cloud database.'

'Developed with Flutter, the app is compatible with both Android and iOS from a single codebase. Its map, GPS, and emergency API compatibility is ideal for this app. "SheOn" is a safety buddy, and it makes women feel safe wherever they are. '
              ,
            ),
            SizedBox(height: 16),
            Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              color: AppColors.secondary),
            ),
            SizedBox(height: 8),
            Text(
              '"To empower women with safe and secure travel by leveraging real-time crime data, intelligent route recommendations, and emergency support—ensuring their safety through technology, community awareness, and instant assistance.".',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              color: AppColors.secondary),
            ),
            SizedBox(height: 8),
            Text(
              'If you have any questions, feedback, or suggestions, feel free to reach out to us at genlumine012@gmail.com. '
              ,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    backgroundColor: AppColors.primary,);
  }
}