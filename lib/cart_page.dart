import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'car_detail_page.dart'; // Assuming you have a CarDetailPage

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
  }

  // Function to calculate the total price by stripping the dollar sign
  Future<void> _calculateTotalPrice() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cartItems')
          .get();

      double total = 0.0;
      cartSnapshot.docs.forEach((doc) {
        // Extract price as a string and remove any non-numeric characters, including dollar signs
        String priceString = doc['price'].replaceAll(RegExp(r'[^0-9.]'), '');

        // Convert the cleaned string to a double
        double? itemPrice = double.tryParse(priceString);

        if (itemPrice != null) {
          total += itemPrice;
        }

        // Add the total price of add-ons
        if (doc['addonPriceTotal'] != null) {
          total += doc['addonPriceTotal'];
        }
      });

      setState(() {
        totalPrice = total;
      });
    }
  }

  // Function to remove an item from the cart
  Future<void> _removeFromCart(String cartItemId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cartItems')
          .doc(cartItemId)
          .delete();
      _calculateTotalPrice(); // Recalculate total price after removal
    }
  }

  // Function to show a bottom sheet with car details
  void _showDetailsBottomSheet(
      BuildContext context, Map<String, dynamic> cartItem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black, // Background color for the bottom sheet
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    cartItem['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                // Car Name
                Text(
                  cartItem['name'] ?? 'No Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // Car Price
                Text(
                  cartItem['price'].contains('\$')
                      ? cartItem['price']
                      : '\$${cartItem['price']}',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // Selected Color
                Text(
                  'Color: ${cartItem['selectedColor']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                // Add-ons
                if (cartItem['selectedAddons'] != null &&
                    cartItem['selectedAddons'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add-ons:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...cartItem['selectedAddons'].map<Widget>((addon) {
                        return Text(
                          addon,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      Text(
                        'Add-on Price: \$${cartItem['addonPriceTotal']}',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 10),
            Text('Cart'),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: currentUser == null
          ? Center(child: Text('Please log in to view your cart'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .collection('cartItems')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = snapshot.data!.docs[index];
                          Map<String, dynamic> cartItem =
                              doc.data() as Map<String, dynamic>;

                          return _buildCartItem(cartItem, doc.id);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}', // Display single dollar sign
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity, // Make button full-width
                    child: ElevatedButton(
                      onPressed: () {
                        // Add checkout logic here
                      },
                      child: Text('Checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 20), // Larger button
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
      backgroundColor: Colors.black,
    );
  }

  // Widget for each cart item with delete and details button
  Widget _buildCartItem(Map<String, dynamic> cartItem, String cartItemId) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color.fromARGB(255, 27, 27, 27),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                cartItem['imageUrl'],
                height: 80,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            // Car Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem['name'] ?? 'No Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Ensure we don't show two dollar signs
                  Text(
                    cartItem['price'],
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  // Display Selected Add-ons if available
                  if (cartItem['selectedAddons'] != null &&
                      cartItem['selectedAddons'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          'Add-ons: ${cartItem['selectedAddons'].join(', ')}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Buttons: Delete and Details side by side
            Column(
              children: [
                Row(
                  children: [
                    // Delete Button
                    ElevatedButton(
                      onPressed: () => _removeFromCart(cartItemId),
                      child: Icon(Icons.delete, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    // Details Button
                    ElevatedButton(
                      onPressed: () {
                        _showDetailsBottomSheet(context, cartItem);
                      },
                      child: Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
