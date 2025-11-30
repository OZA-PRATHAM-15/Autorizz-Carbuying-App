import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'toast_utils.dart';

class CarDetailPage extends StatefulWidget {
  final String carId;

  const CarDetailPage({super.key, required this.carId});

  @override
  _CarDetailPageState createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  String selectedColor = 'red';
  List<String> selectedAddons = [];
  double addonPriceTotal = 0.0;
  String? selectedImageUrl;

  @override
  Widget build(BuildContext context) {
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Car Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: cars.doc(widget.carId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading car details."));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Car not found."));
          }

          Map<String, dynamic> carData =
              snapshot.data!.data() as Map<String, dynamic>;

          Map<String, dynamic> colorOptions =
              Map<String, dynamic>.from(carData['colors']);
          Map<String, dynamic>? addons = colorOptions[selectedColor]['addons'];

          selectedImageUrl ??= colorOptions[selectedColor]['imageUrl'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      selectedImageUrl!,
                      fit: BoxFit.cover,
                      height: 250,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    carData['name'] ?? 'Unknown Car',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    carData['price'].contains('\$')
                        ? carData['price']
                        : '\$${carData['price']}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 10, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  _buildCarInfo(Icons.speed, 'Mileage', carData['mileage']),
                  const SizedBox(height: 8),
                  _buildCarInfo(Icons.local_gas_station, 'Fuel Type',
                      carData['fuelType']),
                  const SizedBox(height: 8),
                  _buildCarInfo(
                      Icons.settings, 'Transmission', carData['transmission']),
                  const SizedBox(height: 8),
                  _buildCarInfo(Icons.airline_seat_recline_normal, 'Seats',
                      carData['seats']),
                  const SizedBox(height: 8),
                  _buildCarInfo(Icons.speed, 'Speed', carData['speed']),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey[400]),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      carData['details'] ?? 'No details available',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Text(
                    'Select Color:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: colorOptions.keys.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                            selectedAddons.clear();
                            addonPriceTotal = 0.0;
                            selectedImageUrl =
                                colorOptions[selectedColor]['imageUrl'];
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
                                      ? Colors.white
                                      : Colors.grey,
                                  width: selectedColor == color ? 3 : 1,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: _getColorFromName(color),
                                radius: 18,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              color.capitalize(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (addons != null && addons.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Add-ons:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 15,
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
                                    selectedImageUrl =
                                        colorOptions[selectedColor]['imageUrl'];
                                  } else {
                                    selectedAddons.add(addonKey);
                                    addonPriceTotal += addon['price'];
                                    selectedImageUrl = addon['image'];
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
                                      ? Colors.green
                                          .withAlpha((0.1 * 255).toInt())
                                      : Colors.grey[800],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      addon['image'],
                                      height: 80,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      addon['name'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      '\$${addon['price']}',
                                      style: const TextStyle(
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(
                        text: 'Buy Now',
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        textColor: const Color.fromARGB(255, 0, 0, 0),
                        onPressed: () {},
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
      backgroundColor: Colors.black,
    );
  }

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
        return Colors.transparent;
    }
  }

  Widget _buildCarInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
        'addonPriceTotal': addonPriceTotal,
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
