import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
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
                "Terms & Conditions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Welcome to Park Finder, a mobile application designed to help residents and visitors locate public facilities and check real-time car park availability across Singapore. By using our app, you agree to the following terms and conditions. Please read them carefully.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("1. Acceptance of Terms"),
              _buildSectionContent(
                "By accessing or using Park Finder, you agree to be bound by these Terms & Conditions and our Privacy Policy. If you do not agree with any part of these terms, you must discontinue use of the application.",
              ),

              _buildSectionTitle("2. Use of the Application"),
              _buildSectionContent(
                "Park Finder is intended for personal and non-commercial use only.\n\n"
                "Users must not engage in unauthorized access, modification, or disruption of the application’s services.\n\n"
                "Any misuse of the app, including providing false reviews or misleading information, may result in account suspension.",
              ),

              _buildSectionTitle("3. Core Features & Limitations"),
              _buildSectionContent(
                "Park Finder provides an interactive map, real-time car park availability, user-generated reviews, and accessibility information. While we strive for accuracy, we do not guarantee that all information, including parking availability, will be up to date or error-free.",
              ),

              _buildSectionTitle("4. User-Generated Content"),
              _buildSectionContent(
                "Users may submit reviews, ratings, and images of public facilities.\n\n"
                "By submitting content, you grant Park Finder a non-exclusive, royalty-free license to use, modify, and display such content.\n\n"
                "Inappropriate, offensive, or misleading content may be removed without notice.",
              ),

              _buildSectionTitle("5. Data Accuracy & Third-Party Sources"),
              _buildSectionContent(
                "Real-time car park availability is sourced from government APIs and external data providers. We do not own or control this data and cannot guarantee its accuracy.\n\n"
                "Weather updates are retrieved from third-party sources and may not always reflect real-time conditions.",
              ),

              _buildSectionTitle("6. Accessibility Information"),
              _buildSectionContent(
                "We strive to provide accurate accessibility details (e.g., wheelchair-friendly, pet-friendly, child-friendly locations). However, users should verify these details independently before visiting a location.",
              ),

              _buildSectionTitle("7. Privacy & Data Collection"),
              _buildSectionContent(
                "Park Finder collects and processes personal data as outlined in our Privacy Policy.\n\n"
                "We do not sell or share personal information with third parties beyond necessary service providers.",
              ),

              _buildSectionTitle("8. Limitation of Liability"),
              _buildSectionContent(
                "Park Finder is provided 'as is' without any warranties, express or implied.\n\n"
                "We are not liable for any inaccuracies, errors, or unavailability of data.\n\n"
                "Users assume all responsibility when relying on the app for navigation, facility details, and car park availability.",
              ),

              _buildSectionTitle("9. Modifications to Terms"),
              _buildSectionContent(
                "We reserve the right to update or modify these Terms & Conditions at any time. Continued use of the application after changes indicates acceptance of the revised terms.",
              ),

              _buildSectionTitle("10. Contact Information"),
              _buildSectionContent(
                "For questions or concerns regarding these terms, please contact us at parkfindersg@gmail.com.",
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
