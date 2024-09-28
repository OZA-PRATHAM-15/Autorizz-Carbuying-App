import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;
  int _selectedTabIndex = 0;

  int totalUsers = 0;
  int totalCars = 0;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      QuerySnapshot carsSnapshot =
          await FirebaseFirestore.instance.collection('cars').get();

      setState(() {
        totalUsers = usersSnapshot.docs.length;
        totalCars = carsSnapshot.docs.length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching analytics data: $e')),
      );
    }
  }

  Future<void> _addCar() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _mileageController.text.isEmpty ||
        _fuelTypeController.text.isEmpty ||
        _transmissionController.text.isEmpty ||
        _seatsController.text.isEmpty ||
        _speedController.text.isEmpty ||
        _colorsController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('cars').add({
        'name': _nameController.text,
        'price': _priceController.text,
        'mileage': _mileageController.text,
        'fuelType': _fuelTypeController.text,
        'transmission': _transmissionController.text,
        'seats': _seatsController.text,
        'speed': _speedController.text,
        'colors': _colorsController.text,
        'imageUrl': _imageUrlController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car added successfully')),
      );

      _nameController.clear();
      _priceController.clear();
      _mileageController.clear();
      _fuelTypeController.clear();
      _transmissionController.clear();
      _seatsController.clear();
      _speedController.clear();
      _colorsController.clear();
      _imageUrlController.clear();

      _fetchAnalyticsData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add car: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching users'));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(user['name'] ?? 'No Name'),
                subtitle: Text(user['email'] ?? 'No Email'),
                trailing: Text(user['role'] ?? 'user'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddCarForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Car Name'),
          ),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Price'),
          ),
          TextField(
            controller: _mileageController,
            decoration: InputDecoration(labelText: 'Mileage'),
          ),
          TextField(
            controller: _fuelTypeController,
            decoration: InputDecoration(labelText: 'Fuel Type'),
          ),
          TextField(
            controller: _transmissionController,
            decoration: InputDecoration(labelText: 'Transmission'),
          ),
          TextField(
            controller: _seatsController,
            decoration: InputDecoration(labelText: 'Seats'),
          ),
          TextField(
            controller: _speedController,
            decoration: InputDecoration(labelText: 'Speed'),
          ),
          TextField(
            controller: _colorsController,
            decoration: InputDecoration(labelText: 'Colors (JSON format)'),
          ),
          TextField(
            controller: _imageUrlController,
            decoration: InputDecoration(labelText: 'Image URL'),
          ),
          SizedBox(height: 20),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _addCar,
                  child: Text('Add Car'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCarList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching cars'));
        }

        final cars = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index].data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: Image.network(car['imageUrl'], width: 50, height: 50),
                title: Text(car['name'] ?? 'No Name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: ${car['price'] ?? 'No Price'}'),
                    Text('Mileage: ${car['mileage'] ?? 'Unknown Mileage'}'),
                    Text('Fuel Type: ${car['fuelType'] ?? 'Unknown Fuel'}'),
                    Text(
                        'Transmission: ${car['transmission'] ?? 'Unknown Transmission'}'),
                    Text('Seats: ${car['seats'] ?? 'Unknown Seats'}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Analytics Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Total Users',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            totalUsers.toString(),
            style: TextStyle(
              color: Colors.blue,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Total Cars',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            totalCars.toString(),
            style: TextStyle(
              color: Colors.green,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildUserList();
      case 1:
        return _buildAddCarForm();
      case 2:
        return _buildCarList();
      case 3:
        return _buildAnalytics();
      default:
        return Center(child: Text('Unknown Tab'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _getSelectedTabContent(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomBarItem(
              icon: Icons.people,
              label: 'View Users',
              index: 0,
            ),
            _buildBottomBarItem(
              icon: Icons.add_circle,
              label: 'Add Car',
              index: 1,
            ),
            _buildBottomBarItem(
              icon: Icons.directions_car,
              label: 'View Cars',
              index: 2,
            ),
            _buildBottomBarItem(
              icon: Icons.bar_chart,
              label: 'Analytics',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  // Custom widget for the navigation bar items with icon and text
  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedTabIndex == index ? Colors.white : Colors.grey,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _selectedTabIndex == index ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
