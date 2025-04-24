import 'package:flutter/material.dart';
import 'package:sheon/color.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Future<void> _callNumber(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildEmergencyNumber(String title, String number) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _callNumber(number),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emergency, color: AppColors.secondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.call, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'About the App',
              'SheOn is a personal safety app designed to help you navigate safely, '
              'contact emergency services quickly, and access important safety information '
              'when you need it most.',
            ),
            
            _buildSection(
              'How to Use',
              '1. Use the SafeMap feature to find safe routes\n'
              '2. Long-press the SOS button in emergencies\n'
              '3. Access emergency contacts from the Help section\n'
              '4. Customize your profile and settings',
            ),
            
            Text(
              'FAQs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildFaqItem(
                    'Q: How do I use the SOS feature?',
                    'A: Long-press the SOS button for 3 seconds to send an emergency alert.',
                  ),
                  _buildFaqItem(
                    'Q: How do I use the SafeMap feature?',
                    'A: Tap the SafeMap button to view safe routes and locations near you.',
                  ),
                  _buildFaqItem(
                    'Q: How do I contact support?',
                    'A: Email us at genlumine012@gmail.com or use the in-app feedback option.',
                  ),
                  _buildFaqItem(
                    'Q: Is my data secure?',
                    'A: Yes, we prioritize your privacy and all data is encrypted.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildEmergencyNumber('Women\'s Helpline (All India)', '1091'),
            _buildEmergencyNumber('Women\'s Helpline (Domestic Abuse)', '181'),
            _buildEmergencyNumber('Police Helpline (All India)', '100'),
            _buildEmergencyNumber('Child Helpline', '1098'),
            _buildEmergencyNumber('Ambulance', '108'),
            
            const SizedBox(height: 20),
            _buildSection(
              'Contact Us',
              'For any questions, feedback, or support needs, please contact us at:\n'
              'Email: genlumine012@gmail.com\n'
              'We typically respond within 24 hours.',
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.primary,
    );
  }
}