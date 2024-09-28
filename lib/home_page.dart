import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:car_buying_app/cart_page.dart';
import 'package:car_buying_app/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_content_page.dart';
import 'car_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // For BottomNavigationBar index

  final String _heroImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/carbuyingapp-4883c.appspot.com/o/car.png?alt=media&token=ff96b43e-fb84-4ec9-b2f7-508b541c04cc'; // Replace with your actual URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/car_logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              'Autorizz',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(), // Your main content page
          SearchContentPage(), // Placeholder for the Market page
          CartPage(), // Placeholder for the Cart page
          ProfilePage() // Placeholder for the Profile page
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Home page content
  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section with Gradient Overlay and Animated Text
          Container(
            height: 250,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    _heroImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right:
                      20, // Ensure the text doesn't overflow the screen width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width:
                            double.infinity, // Make sure text fits the screen
                        child: AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText(
                              'Find Your Perfect Car',
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          repeatForever: true, // Loop animation indefinitely
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Browse our extensive collection and find the best deals.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        maxLines: 2, // Restrict text to 2 lines
                        overflow: TextOverflow.ellipsis, // Ellipsis if overflow
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex =
                                1; // Switch to SearchContentPage (Market)
                          });
                        },
                        child: Text('Browse Cars'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Categories Section with Icons and Labels
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryCard(Icons.directions_car, 'Sedans'),
                    _buildCategoryCard(Icons.sports_motorsports, 'Sports'),
                    _buildCategoryCard(
                        Icons.directions_car_filled_sharp, 'SUVs'),
                    _buildCategoryCard(Icons.build, 'Add Ons'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Featured Car Section (Vertical Scroll)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Cars',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('cars').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No featured cars available.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];
                        Map<String, dynamic> carData =
                            doc.data() as Map<String, dynamic>;

                        return _buildFeaturedCarCard(
                          carData['imageUrl'],
                          carData['name'],
                          '${carData['speed']} km/h\n${carData['price']}',
                          'Fuel: ${carData['fuelType']}',
                          doc.id, // Car ID for navigation
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Footer Section
          _buildFooter(),
        ],
      ),
    );
  }

  // Placeholder for other pages (Market, Cart, Profile)
  Widget _buildPlaceholder(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  // Category Card Widget
  Widget _buildCategoryCard(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Market page (SearchContentPage)
        setState(() {
          _selectedIndex = 1; // Switch to SearchContentPage (Market)
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        color: const Color.fromARGB(255, 27, 27, 27),
        child: Container(
          width: 80,
          height: 110,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Redesigned Featured Car Card Widget based on your reference image
  Widget _buildFeaturedCarCard(String? imageUrl, String? model, String? specs,
      String? fuelType, String carId) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: const Color.fromARGB(255, 27, 27, 27),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // Round image corners
              child: Image.network(
                imageUrl ?? 'https://via.placeholder.com/150',
                height: 100,
                width: 135,
                fit: BoxFit.cover, // Adjusted to cover the entire box
              ),
            ),
            SizedBox(width: 10),
            // Car Details with button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model ?? 'Unknown Model',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    specs ?? 'Specifications not available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    fuelType ?? 'Fuel Type not available',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // "Details" Button
            SizedBox(
              width: 80, // Adjust the width of the button
              child: ElevatedButton(
                onPressed: () {
                  _showCarDetailsModal(context, carId);
                },
                child: Text('Details'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show car details popup modal
  // Function to show car details popup modal without scrolling
  void _showCarDetailsModal(BuildContext context, String carId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black, // Set the background color to black
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Car Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Adjust text color to white
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Colors.white), // Adjust icon color
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              // Car details fetched from Firebase
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('cars')
                    .doc(carId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error loading details.',
                            style: TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                        child: Text('Car not found.',
                            style: TextStyle(color: Colors.white)));
                  }
                  Map<String, dynamic> carData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        carData['imageUrl'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 16),
                      Text(
                        carData['name'] ?? 'Unknown Car',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        carData['price'] ?? 'Price not available',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        carData['details'] ?? 'No details available.',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  );
                },
              ),
              // "Buy Now" Button
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailPage(carId: carId),
                      ),
                    );
                  },
                  child: Text('Buy Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    textStyle: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Footer Section Widget
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16),
      color: const Color.fromARGB(255, 27, 27, 27),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Autorizz - Your Ultimate Car Buying Experience',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '© 2024 Autorizz. All rights reserved.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
