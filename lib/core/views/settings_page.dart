import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:park_finder/core/views/change_password_page.dart';
import 'package:park_finder/core/views/contact_us_page.dart';
import 'package:park_finder/core/views/edit_profile_page.dart';
import 'package:park_finder/core/views/home_page.dart';
import 'package:park_finder/core/views/login_page.dart';
import 'package:park_finder/core/views/privacy_policy_page.dart';
import 'package:park_finder/core/views/search_page.dart';
import 'package:park_finder/core/views/terms_and_conditions_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String name = "";
  String email = "";
  String phone = "";
  bool isLoading = true; // To handle loading state
  int _selectedIndex = 3; // Default: Settings Page

  // Fetch user data from Firestore
  void _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    print(user);
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc["name"];
          email = userDoc["email"];
          phone = userDoc["phoneNumber"];
          isLoading = false; // Finished loading
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Fetch user data when the page is loaded
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfilePage(
              name: name,
              email: email,
              phone: phone,
              userId: FirebaseAuth.instance.currentUser!.uid,
            ),
      ),
    );

    if (result != null) {
      setState(() {
        name = result['name'];
        email = result['email'];
        phone = result['phone'];
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ), // Replace with Login Page if needed
                );
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator until data is fetched
              : Column(
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("Assets/profile.png"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(phone, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  // Settings List
                  Expanded(
                    child: ListView(
                      children: [
                        const SectionTitle(title: "General Settings"),
                        SettingsTile(
                          icon: Icons.edit,
                          title: "Edit Profile",
                          onTap: _navigateToEditProfile,
                        ),
                        SettingsTile(
                          icon: Icons.lock,
                          title: "Change Password",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ChangePasswordPage(),
                              ),
                            );
                          },
                        ),

                        const SectionTitle(title: "Information"),
                        SettingsTile(
                          icon: Icons.email,
                          title: "Contact Us",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactUsPage(),
                              ),
                            );
                          },
                        ),
                        SettingsTile(
                          icon: Icons.description,
                          title: "Terms & Conditions",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const TermsAndConditionsPage(),
                              ),
                            );
                          },
                        ),
                        SettingsTile(
                          icon: Icons.privacy_tip,
                          title: "Privacy Policy",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacyPolicyPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        // Log Out Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: _showLogoutDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Log Out"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const HomeScreen();
        break;
      case 1:
        nextPage = Scaffold(
          body: Center(child: Text("Explore Page")),
        ); // Placeholder
        break;
      case 2:
        nextPage = const SearchPage(); // <-- Use the new SearchPage here
        break;
      case 3:
      default:
        nextPage = const SettingsPage();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }
}

// Section Title Widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Settings Tile Widget
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF009b50)),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
