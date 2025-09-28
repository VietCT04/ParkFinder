import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Models and services (replace with your actual paths)
import '../models/weather.dart';
import '../services/ammenitieservice.dart';

/// A screen showing details about a specific park, including reviews.
/// If the currently logged-in user is an admin, they also see buttons
/// to remove individual reviews and ban a user.
class AboutScreen extends StatefulWidget {
  final String parkId;

  const AboutScreen({Key? key, required this.parkId}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController review = TextEditingController();

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AmenitiesService amenitiesService = AmenitiesService(); // For amenities

  // Weather
  Weather w = Weather();
  Map<String, dynamic>? weatherData;
  bool isLoadingWeather = true;

  // Park
  String? parkName;

  // Admin check
  bool isAdmin = false;

  bool isBanned = false;

  // Favorite
  bool isFavorite = false;
  static final Map<String, bool> favoriteState = {};

  // Rating for new review
  double rating = 3.0;

  @override
  void initState() {
    super.initState();
    checkIfAdmin(); // Check if current user is admin
    checkIfBanned(); // Check if current user is banned
    fetchParkName();
    fetchParkWeather();
    // Retrieve favorite state if previously set
    isFavorite = favoriteState[widget.parkId] ?? false;
  }

  // -----------------------------------------------------------------------------
  // 1. CHECK ADMIN STATUS
  // -----------------------------------------------------------------------------
  Future<void> checkIfAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => isAdmin = false);
      return;
    }

    final docRef = _firestore.collection('users').doc(currentUser.uid);
    final userDoc = await docRef.get();
    if (userDoc.exists) {
      setState(() {
        isAdmin = userDoc.data()?['isAdmin'] == true;
      });
    }
  }

  Future<void> checkIfBanned() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => isBanned = false);
      return;
    }

    final docRef = _firestore.collection('users').doc(currentUser.uid);
    final userDoc = await docRef.get();
    if (userDoc.exists) {
      setState(() {
        isBanned = userDoc.data()?['isBanned'] == true;
      });
    }
  }

  // -----------------------------------------------------------------------------
  // 2. FETCH PARK NAME & WEATHER
  // -----------------------------------------------------------------------------
  Future<void> fetchParkName() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> parkSnapshot =
          await _firestore.collection("Parks").doc(widget.parkId).get();

      if (parkSnapshot.exists) {
        setState(() {
          parkName = parkSnapshot.data()?['name'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching park name: $e");
    }
  }

  Future<void> fetchParkWeather() async {
    try {
      final parkSnap =
          await _firestore.collection("Parks").doc(widget.parkId).get();
      if (parkSnap.exists) {
        final parkData = parkSnap.data()!;
        // Coordinates stored as [lon, lat] or [x, y]? Adjust as needed.
        final lat = (parkData['coordinates'][1] as num).toDouble();
        final lon = (parkData['coordinates'][0] as num).toDouble();

        final weather = await w.getWeather(lat, lon);
        setState(() {
          weatherData = weather;
          isLoadingWeather = false;
        });
      } else {
        setState(() => isLoadingWeather = false);
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      setState(() => isLoadingWeather = false);
    }
  }

  Future<void> showWeather() async {
    if (weatherData == null) return;

    int weatherCode = (weatherData?['weathercode'] as num?)?.toInt() ?? 0;
    String animationPath = "";
    String weatherText = "";

    // Simplified logic for demonstration
    if (weatherCode < 5) {
      animationPath = "Assets/Animation - 1743093274661.json";
      weatherText = "Best time to visit the park!";
    } else if (weatherCode > 45 && weatherCode <= 67) {
      animationPath = "Assets/Animation - 1743093573590.json";
      weatherText = "You may want to bring an umbrella.";
    } else if (weatherCode > 71) {
      animationPath = "Assets/Animation - 1743093599336.json";
      weatherText = "Might be harsh weather. Stay safe!";
    } else {
      animationPath = "Assets/Animation - 1743095192625.json";
      weatherText = "General weather conditions.";
    }

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(animationPath),
                    const SizedBox(height: 20),
                    Text(
                      "Temperature: ${weatherData?['temperature']} °C",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(weatherText, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // -----------------------------------------------------------------------------
  // 3. AMENITIES
  // -----------------------------------------------------------------------------
  void showAmenities() {
    if (parkName == null) return;
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Amenities for \n${parkName!.toUpperCase()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // StreamBuilder for amenities
                    StreamBuilder<List<String>>(
                      stream: amenitiesService.getAmenities(parkName!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }
                        final amenities = snapshot.data ?? [];
                        if (amenities.isEmpty) {
                          return const Text(
                            "No amenities available for this park.",
                          );
                        }
                        return Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  amenities.map((amenity) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              amenity,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Got it"),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // -----------------------------------------------------------------------------
  // 4. FAVORITES
  // -----------------------------------------------------------------------------
  Future<void> addOrRemoveFavorite(
    String parkName,
    String parkImage,
    bool isCurrentlyFavorite,
    String parkId,
  ) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User not logged in");
      return;
    }
    final favCollection = _firestore.collection("FavouriteParks");

    // Check if this park is already in user favorites
    final existing =
        await favCollection
            .where('userId', isEqualTo: user.uid)
            .where('ParkName', isEqualTo: parkName)
            .get();

    if (!isCurrentlyFavorite && existing.docs.isEmpty) {
      // Add to favorites if not exist
      await favCollection.add({
        'userId': user.uid,
        'ParkName': parkName,
        'ParkImage': parkImage,
        'ParkId': parkId,
        'userName': user.displayName ?? "Anonymous",
      });
      debugPrint("Added to favorites");
    } else if (isCurrentlyFavorite && existing.docs.isNotEmpty) {
      // Remove from favorites if exist
      for (var doc in existing.docs) {
        await doc.reference.delete();
      }
      debugPrint("Removed from favorites");
    } else {
      debugPrint("No action needed");
    }
  }

  void toggleFavorite(String parkName, String parkImage) {
    setState(() {
      isFavorite = !isFavorite;
      favoriteState[widget.parkId] = isFavorite;
    });
    addOrRemoveFavorite(parkName, parkImage, !isFavorite, widget.parkId);
  }

  // -----------------------------------------------------------------------------
  // 5. REVIEWS: Streams, Add, Remove
  // -----------------------------------------------------------------------------

  // Instead of returning a list of Maps, return a list of QueryDocumentSnapshot
  // so we can easily get doc IDs for each review.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getReviewsByParkName(String parkName) {
    return _firestore
        .collection("Reviews")
        .where("ParkName", isEqualTo: parkName)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Show dialog to create a new review
  Future<void> showReviewDialog() async {
    // We need the park name
    if (parkName == null) return;

    // If the user is banned, show a banned message dialog and return early.
    if (isBanned) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('You have been banned from posting reviews.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009b50),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      );
      return;
    }

    // Otherwise, show the review dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Got something to say? Let us know"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Name"),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    hintText: "Please enter your name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Rating"),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  maxRating: 5,
                  allowHalfRating: true,
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (newRating) {
                    setState(() {
                      rating = newRating;
                    });
                  },
                ),
                const SizedBox(height: 10),
                const Text("Review"),
                TextFormField(
                  controller: review,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Please enter a review",
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009b50),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  // TC2: Not logged in
                  if (currentUser == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "You must be logged in to post a review.",
                        ),
                      ),
                    );
                    return;
                  }
                  // TC3: Name empty
                  if (name.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter your name.")),
                    );
                    return;
                  }
                  // TC4: Review empty
                  if (review.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter your review."),
                      ),
                    );
                    return;
                  }
                  // TC5/TC6: All good, post the review
                  await _firestore.collection("Reviews").add({
                    'Name': name.text.trim(),
                    'Rating': rating,
                    'reviews': review.text.trim(),
                    'ParkName': parkName,
                    'timestamp': FieldValue.serverTimestamp(),
                    'userId': currentUser.uid,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Review posted successfully")),
                  );

                  // Reset and close
                  name.clear();
                  review.clear();
                  setState(() {
                    rating = 3.0;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009b50),
                ),
                child: const Text(
                  "Post Review",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  // Remove a review by docId (admin only)
  Future<void> _removeReview(String docId) async {
    try {
      await _firestore.collection("Reviews").doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review removed successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error removing review: $e")));
    }
  }

  // -----------------------------------------------------------------------------
  // 6. BAN USER
  // -----------------------------------------------------------------------------
  void _banUserPrompt(String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Ban User"),
            content: const Text("Are you sure you want to ban this user?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cancel
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _banUser(userId);
                },
                child: const Text("Ban"),
              ),
            ],
          ),
    );
  }

  Future<void> _banUser(String userId) async {
    try {
      // Mark user as banned in Firestore
      await _firestore.collection('users').doc(userId).update({
        'isBanned': true,
      });

      // Create a batch to delete all reviews by the banned user
      WriteBatch batch = _firestore.batch();

      // Get all the reviews for that user
      QuerySnapshot reviewSnapshot =
          await _firestore
              .collection('Reviews')
              .where('userId', isEqualTo: userId)
              .get();

      // Loop through each document and add a delete operation to the batch
      for (QueryDocumentSnapshot doc in reviewSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch deletion
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User banned and reviews removed successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error banning user: $e')));
    }
  }

  // -----------------------------------------------------------------------------
  // 7. RATING STREAM (IF DESIRED)
  // -----------------------------------------------------------------------------
  Stream<double> getAverageRating(String parkName) {
    return _firestore
        .collection("Reviews")
        .where("ParkName", isEqualTo: parkName)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 3.0; // default
          double total = 0.0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            total += (data['Rating'] ?? 0).toDouble();
          }
          return total / snapshot.docs.length;
        });
  }

  // Get review count
  Stream<int> getReviewCount(String parkName) {
    return _firestore
        .collection("Reviews")
        .where("ParkName", isEqualTo: parkName)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // -----------------------------------------------------------------------------
  // 8. BUILD UI
  // -----------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final parkRef = _firestore.collection('Parks').doc(widget.parkId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: parkRef.snapshots(),
      builder: (context, parkSnapshot) {
        if (parkSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!parkSnapshot.hasData || !parkSnapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF009b50),
              title: const Text("Park Not Found"),
            ),
            body: const Center(child: Text("This park does not exist.")),
          );
        }

        final parkData = parkSnapshot.data!.data()!;
        final currentParkName = parkData['name'] ?? "No Name";
        final description = parkData['description'] ?? "No Description";
        final imageUrl =
            parkData['image_url'] ??
            "https://via.placeholder.com/400x300.png?text=No+Image";

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF009b50),
            title: Text(
              currentParkName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            actions: [
              // Favorite icon
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  toggleFavorite(currentParkName, imageUrl);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Park Image
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Average rating (stream-based)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            StreamBuilder<double>(
                              stream: getAverageRating(currentParkName),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                double avg = snapshot.data!;
                                return RatingBarIndicator(
                                  rating: avg,
                                  itemCount: 5,
                                  itemSize: 30.0,
                                  itemBuilder:
                                      (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Description
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      // Amenities & Weather row
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: showAmenities,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF009b50),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                                child: const Text(
                                  "View Amenities",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: showWeather,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF009b50),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                                child: const Text(
                                  "Weather Forecast",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Reviews heading
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Reviews",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      // Reviews List
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child:
                            (parkName == null)
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : StreamBuilder<
                                  List<
                                    QueryDocumentSnapshot<Map<String, dynamic>>
                                  >
                                >(
                                  stream: getReviewsByParkName(parkName!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    }
                                    final reviewDocs = snapshot.data ?? [];
                                    if (reviewDocs.isEmpty) {
                                      return const Text("No reviews yet.");
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: reviewDocs.length,
                                      itemBuilder: (context, index) {
                                        final doc = reviewDocs[index];
                                        final reviewData = doc.data();
                                        final docId =
                                            doc.id; // Firestore doc ID
                                        final reviewUserId =
                                            reviewData['userId'] ?? '';
                                        final reviewName =
                                            reviewData['Name'] ?? 'Anonymous';
                                        final reviewText =
                                            reviewData['reviews'] ?? '';
                                        final reviewRating =
                                            reviewData['Rating']?.toString() ??
                                            '0';

                                        return Card(
                                          elevation: 2,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: ListTile(
                                            title: Text(reviewName),
                                            subtitle: Text(reviewText),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("⭐ $reviewRating"),
                                                // Only show admin controls if isAdmin = true
                                                if (isAdmin) ...[
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed:
                                                        () => _removeReview(
                                                          docId,
                                                        ),
                                                    tooltip: 'Remove Review',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.block,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed:
                                                        () => _banUserPrompt(
                                                          reviewUserId,
                                                        ),
                                                    tooltip: 'Ban User',
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
                // Add Review Button
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    onPressed: showReviewDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add Review",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009b50),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
