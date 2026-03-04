import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SplitPlan was built out of a simple necessity: making it easier to share costs with friends and family without the hassle of mental math and awkward conversations.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Our mission is to take the stress out of splitting bills so you can focus on enjoying the experiences that matter most. Whether you\'re traveling, living with roommates, or just going out for dinner, SplitPlan ensures everyone pays their fair share effortlessly.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Get in Touch',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'We are constantly looking to improve. If you have any feedback or suggestions, please don\'t hesitate to reach out to our team.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'advi0009@gmail.com',
                    queryParameters: {
                      'subject': 'SplitPlan Support / Feedback',
                    },
                  );
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  }
                },
                icon: const Icon(Icons.email),
                label: const Text('Contact Us'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
