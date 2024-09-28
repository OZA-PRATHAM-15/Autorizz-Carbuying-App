import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'toast_utils.dart'; // Import the toast utils file here

class CarDetailPage extends StatefulWidget {
  final String carId;

  CarDetailPage({required this.carId});

  @override
  _CarDetailPageState createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  String selectedColor = 'red'; // Default color selection
  List<String> selectedAddons = []; // Store selected add-ons
  double addonPriceTotal = 0.0; // Track total add-ons price
  String? selectedImageUrl; // Track the selected image URL (add-on or color)

  @override
  Widget build(BuildContext context) {
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Car Details',
          style: TextStyle(
            color: Colors.white, // White color for the title text
            fontSize: 22, // Larger font size for more emphasis
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black, // Black background for the AppBar
        iconTheme: IconThemeData(
          color: Colors.white, // White color for the back arrow
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: cars.doc(widget.carId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading car details."));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Car not found."));
          }

          Map<String, dynamic> carData =
              snapshot.data!.data() as Map<String, dynamic>;

          // Assuming `carData['colors']` holds the color options, add-ons, and URLs for images
          Map<String, dynamic> colorOptions =
              Map<String, dynamic>.from(carData['colors']);
          Map<String, dynamic>? addons = colorOptions[selectedColor]['addons'];

          // If no add-on is selected, show the default color image
          selectedImageUrl ??= colorOptions[selectedColor]['imageUrl'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Image based on the selected color or add-on
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      selectedImageUrl!, // Display the selected image (color or add-on)
                      fit: BoxFit.cover,
                      height: 250,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Car Name
                  Text(
                    carData['name'] ?? 'Unknown Car',
                    style: TextStyle(
                      fontSize: 28, // Larger font size for the car name
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Make text white
                    ),
                  ),
                  SizedBox(height: 8),

                  // Car Price
                  Text(
                    carData['price'].contains('\$')
                        ? carData['price']
                        : '\$${carData['price']}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Divider
                  Divider(height: 1, color: Colors.grey[400]),

                  // Additional Car Info (Mileage, Fuel, Transmission, Seats, Speed)
                  SizedBox(height: 16),
                  _buildCarInfo(Icons.speed, 'Mileage', carData['mileage']),
                  SizedBox(height: 8),
                  _buildCarInfo(Icons.local_gas_station, 'Fuel Type',
                      carData['fuelType']),
                  SizedBox(height: 8),
                  _buildCarInfo(
                      Icons.settings, 'Transmission', carData['transmission']),
                  SizedBox(height: 8),
                  _buildCarInfo(Icons.airline_seat_recline_normal, 'Seats',
                      carData['seats']),
                  SizedBox(height: 8),
                  _buildCarInfo(Icons.speed, 'Speed', carData['speed']),
                  SizedBox(height: 16),

                  // Divider
                  Divider(height: 1, color: Colors.grey[400]),

                  // Car Details
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      carData['details'] ?? 'No details available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5, // Increase line height for readability
                      ),
                    ),
                  ),

                  // Color selection section
                  const Text(
                    'Select Color:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),

                  // Displaying available colors as selectable options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: colorOptions.keys.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                            selectedAddons.clear(); // Reset selected add-ons
                            addonPriceTotal = 0.0; // Reset add-on price
                            selectedImageUrl = colorOptions[selectedColor][
                                'imageUrl']; // Reset the image to the selected color
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? Colors.white // Highlight selected color
                                      : Colors.grey,
                                  width: selectedColor == color ? 3 : 1,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: _getColorFromName(color),
                                radius: 18,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              color.capitalize(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 16),

                  // Add-ons section with enhanced styling
                  if (addons != null && addons.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Add-ons:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: addons.keys.map((addonKey) {
                            var addon = addons[addonKey];
                            bool isSelected = selectedAddons.contains(addonKey);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedAddons.remove(addonKey);
                                    addonPriceTotal -= addon['price'];
                                    selectedImageUrl = colorOptions[
                                            selectedColor][
                                        'imageUrl']; // Reset to the selected color image
                                  } else {
                                    selectedAddons.add(addonKey);
                                    addonPriceTotal += addon['price'];
                                    selectedImageUrl = addon[
                                        'image']; // Change the image to add-on image
                                  }
                                });
                              },
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.white,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey[800],
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      addon['image'],
                                      height: 80,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      addon['name'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      '\$${addon['price']}',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  // Action Buttons (Buy Now, Add to Cart)
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(
                        text: 'Buy Now',
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        textColor: const Color.fromARGB(255, 0, 0, 0),
                        onPressed: () {
                          // Add Buy Now logic here
                        },
                      ),
                      _buildActionButton(
                        text: 'Add to Cart',
                        backgroundColor: const Color.fromARGB(255, 55, 55, 55),
                        textColor: Colors.white,
                        onPressed: () {
                          if (currentUser != null) {
                            _addToCart(
                                carData, currentUser.uid, context, addons!);
                          } else {
                            showCustomToast(context,
                                'Please log in to add items to cart', true);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.black, // Make background black
    );
  }

  // Function to convert color name to actual color for display
  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.transparent; // Default color if no match
    }
  }

  // Helper widget to display car information
  Widget _buildCarInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white), // Make icon white
        SizedBox(width: 10),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  // Helper widget for action buttons
  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners for buttons
        ),
        elevation: 5, // Added shadow for better appearance
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold, // Bold text for the button
        ),
      ),
    );
  }

  // Function to add a car to the user's cart in Firestore
  Future<void> _addToCart(Map<String, dynamic> carData, String userId,
      BuildContext context, Map<String, dynamic> addons) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cartItems')
          .add({
        'name': carData['name'],
        'price': carData['price'],
        'imageUrl': carData['colors'][selectedColor]['imageUrl'],
        'selectedColor': selectedColor,
        'selectedAddons': selectedAddons,
        'addonPriceTotal': addonPriceTotal, // Store total price of add-ons
      });

      showCustomToast(
        context,
        '${carData['name']} in $selectedColor with add-ons has been added to your cart.',
        false,
      );
    } catch (e) {
      showCustomToast(context, 'Error adding to cart: $e', true);
    }
  }
}

// Extension to capitalize the first letter of color names
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
