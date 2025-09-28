import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResetAdminPage extends StatefulWidget {
  const ResetAdminPage({Key? key}) : super(key: key);

  @override
  State<ResetAdminPage> createState() => _ResetAdminPageState();
}

class _ResetAdminPageState extends State<ResetAdminPage> {
  bool _isProcessing = false;

  Future<void> _resetAdminField() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      // Get all documents from the "users" collection.
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // For each user document, update the 'isAdmin' field to false.
      for (var doc in snapshot.docs) {
        await doc.reference.update({'isBanned': false});
        debugPrint('Updated user ${doc.id}');
      }

      // Show a success message once all updates are complete.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin field reset for all users successfully.'),
        ),
      );
    } catch (error) {
      // Handle any errors during the update.
      debugPrint('Error resetting admin field: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Admin for All Users'),
        backgroundColor: const Color(0xFF009b50),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:
              _isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _resetAdminField,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009b50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reset Admin Field',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
        ),
      ),
    );
  }
}
