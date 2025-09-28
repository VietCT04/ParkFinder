import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Post {
  final File? image;
  final String parkName;
  final String title;
  final String description;
  final String location;

  Post({
    this.image,
    required this.parkName,
    required this.title,
    required this.description,
    required this.location,
  });
}

class Hiddengem extends StatefulWidget {
  const Hiddengem({super.key});

  @override
  _StateHiddenGem createState() => _StateHiddenGem();
}

class _StateHiddenGem extends State<Hiddengem> {
  List<Post> localPosts = [];

  void showPostsDialog(BuildContext context) {
    TextEditingController parkNameController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    File? imageFile;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Wow! Let everyone know what you found!"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (picked != null) {
                      setState(() {
                        imageFile = File(picked.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Picture"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: parkNameController,
                  decoration: const InputDecoration(labelText: 'Park Name'),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Add a caption'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (parkNameController.text.isNotEmpty &&
                    titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    locationController.text.isNotEmpty) {
                  setState(() {
                    localPosts.add(
                      Post(
                        image: imageFile,
                        parkName: parkNameController.text,
                        title: titleController.text,
                        description: descriptionController.text,
                        location: locationController.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Post"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009b50),
        centerTitle: true,
        automaticallyImplyLeading: false, // removes the back arrow
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 8),
            Text(
              "Parkfinder+",
              style: TextStyle(fontFamily: 'Roboto', fontSize: 22),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          localPosts.isEmpty
              ? const Center(child: Text("No hidden gems yet."))
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: localPosts.length,
                itemBuilder: (context, index) {
                  final post = localPosts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            post.image != null
                                ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.file(
                                    post.image!,
                                    width: double.infinity,
                                    height: 240,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Container(
                                  width: double.infinity,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.diamond,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  post.parkName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                post.description,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      post.location,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => showPostsDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009b50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
              child: const Text(
                "Post a Hidden Gem",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
