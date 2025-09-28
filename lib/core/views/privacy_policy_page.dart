import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: const Color(0xFF009b50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Privacy Policy",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your privacy is important to us. This Privacy Policy outlines how Park Finder collects, uses, and protects your personal information.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("1. Information We Collect"),
              _buildSectionContent(
                "• Personal Information: When you use Park Finder, we may collect personal details such as name, email, and profile picture if you choose to create an account.\n"
                "• Location Data: To provide accurate facility recommendations, we may collect your location data with your consent.\n"
                "• Usage Data: We gather anonymous data on app usage, including visited locations and search history, to improve the app experience.",
              ),

              _buildSectionTitle("2. How We Use Your Information"),
              _buildSectionContent(
                "• To provide and improve our services.\n"
                "• To offer personalized recommendations based on location and preferences.\n"
                "• To enhance app functionality through analytics and feedback.\n"
                "• To communicate updates, features, or important notices.",
              ),

              _buildSectionTitle("3. Data Sharing & Security"),
              _buildSectionContent(
                "• We do not sell or share your personal data with third-party advertisers.\n"
                "• Data is shared only with necessary service providers to ensure app functionality.\n"
                "• We implement security measures to protect your data, but we cannot guarantee absolute security.",
              ),

              _buildSectionTitle("4. Third-Party Services"),
              _buildSectionContent(
                "Park Finder integrates data from third-party sources, such as government APIs for car park availability and weather updates. These services have their own privacy policies, and we are not responsible for their data practices.",
              ),

              _buildSectionTitle("5. Your Choices & Rights"),
              _buildSectionContent(
                "• You can update or delete your account information at any time.\n"
                "• You can disable location services in your device settings if you do not wish to share location data.\n"
                "• You have the right to request a copy of your collected personal data.",
              ),

              _buildSectionTitle("6. Changes to This Policy"),
              _buildSectionContent(
                "We may update this Privacy Policy from time to time. Any changes will be reflected in the app, and continued use of Park Finder indicates acceptance of these updates.",
              ),

              _buildSectionTitle("7. Contact Us"),
              _buildSectionContent(
                "If you have any questions or concerns about this Privacy Policy, feel free to reach out:\n"
                "📧 Email: parkfindersg@gmail.com\n",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(content, style: const TextStyle(fontSize: 16)),
    );
  }
}
