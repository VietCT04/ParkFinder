import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_finder/core/views/home_page.dart';
import 'package:park_finder/core/views/settings_page.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String userId; // Add userId to identify the document

  const EditProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.userId, // Receive the userId
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    try {
      // Get the updated information from the controllers
      String updatedName = _nameController.text;
      String updatedEmail = _emailController.text;
      String updatedPhone = _phoneController.text;

      // Validate phone number: Check if it's a valid digit-only string
      if (updatedPhone.isEmpty || !RegExp(r'^\d+$').hasMatch(updatedPhone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid phone number (digits only)"),
          ),
        );
        return;
      }

      // Check if the email has changed
      if (updatedEmail != widget.email) {
        // Trigger email verification
        User? user = FirebaseAuth.instance.currentUser;

        // Send verification email if user is logged in
        await user?.verifyBeforeUpdateEmail(updatedEmail);
        // Reference to the user's document in Firestore using their userId
        DocumentReference userDoc = FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId);

        // Update the user's data in Firestore
        await userDoc.update({
          'name': updatedName,
          'email': updatedEmail,
          'phoneNumber': updatedPhone,
        });

        // Show a confirmation dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Verification Email Sent"),
              content: const Text(
                "A verification email has been sent to your new email address. Please verify your email to continue.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    // Go back to SettingsPage after showing the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        // Return from the function to avoid further execution until dialog is closed
        return;
      }

      DocumentReference userDoc = FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId);

      // Update the user's data in Firestore
      await userDoc.update({
        'name': updatedName,
        'email': updatedEmail,
        'phoneNumber': updatedPhone,
      });

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      // Show a dialog to inform the user of the successful update
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Profile Updated"),
            content: const Text("Your profile has been updated successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  // Manually navigate back to SettingsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParkHomeScreen(initialIndex: 4),
                    ),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle any errors that occur during the update
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error updating profile")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: const Color(0xFF009b50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Full Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 12),
            const Text(
              "Email",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 12),
            const Text(
              "Phone Number",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            // Smaller "Save Changes" button
            Center(
              child: SizedBox(
                width: 150, // Smaller width
                height: 40, // Smaller height
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009b50), // Green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
