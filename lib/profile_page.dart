import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final userData = userDoc.data();

        // Debugging: Print user data to console
        print('User Data: $userData');

        setState(() {
          _userData = userData;
        });
      } catch (e) {
        print('Failed to load user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: user != null && _userData != null
          ? ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    _userData!['name'] ?? 'Not provided',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    user.email!,
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                ),
                Divider(color: Colors.grey[800], thickness: 1, height: 40),
                _buildProfileItem(Icons.phone, 'Phone', _userData!['phone']),
                _buildProfileItem(
                    Icons.location_on, 'Address', _userData!['address']),
                _buildProfileItem(
                    Icons.calendar_today, 'Birthdate', _userData!['birthdate']),
                _buildProfileItem(
                    Icons.person_outline, 'Gender', _userData!['gender']),
                Divider(color: Colors.grey[800], thickness: 1, height: 40),
                _buildActionItem(Icons.edit, 'Edit Profile', () {
                  Navigator.pushNamed(context, '/edit-profile');
                }),
                _buildActionItem(Icons.history, 'Order History', () {
                  // Navigate to order history pages
                }),
                _buildActionItem(Icons.credit_card, 'Payment Methods', () {
                  // Navigate to payment methods page
                }),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 42, 42, 42),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  // Helper method to build profile items with icons
  Widget _buildProfileItem(IconData icon, String title, String? value) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      subtitle: Text(
        value ?? 'Not provided',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  // Helper method to build action items with icons and navigation
  Widget _buildActionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: onTap,
    );
  }
}
