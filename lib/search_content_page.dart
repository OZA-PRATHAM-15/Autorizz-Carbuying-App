import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'car_detail_page.dart';

class SearchContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Market',
          style: TextStyle(
            color: Colors.white, // Set AppBar title to white
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.black, // Set the background color to black
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('cars').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('No cars found',
                          style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> carData =
                        doc.data() as Map<String, dynamic>;

                    return _buildCarCard(
                        carData, context, doc.id); // Passing document ID
                  },
                );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCarCard(
      Map<String, dynamic> carData, BuildContext context, String docId) {
    String imageUrl = carData['imageUrl'] ??
        'https://via.placeholder.com/150'; // Default image if not available
    String carName = carData['name'] ?? 'Unknown';
    String carPrice = carData['price'] ?? 'Price not available';
    String speed =
        carData['speed'] ?? 'N/A'; // Add speed or any other additional info

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color.fromARGB(
          255, 0, 0, 0), // Dark card color to match black theme
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            // Car Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    carName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for car name
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$speed km/h | $carPrice',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400], // Grey for secondary text
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.directions_car, size: 16, color: Colors.blue),
                      SizedBox(width: 5),
                      Text(
                        'Fuel Type: ${carData['fuelType'] ?? 'Unknown'}',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12), // White text
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Button to go to details
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to car detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailPage(carId: docId),
                    ),
                  );
                },
                child: Text('Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  foregroundColor: const Color.fromARGB(
                      255, 0, 0, 0), // White text for button
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
