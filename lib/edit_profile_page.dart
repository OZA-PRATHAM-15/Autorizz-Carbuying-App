import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdateController = TextEditingController();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  String? _selectedGender;

  bool _isNameValid = false;
  bool _isPhoneValid = false;
  bool _isAddressValid = false;
  bool _isBirthdateValid = false;
  bool _isGenderValid = false;
  bool _isSubmitting = false;

  bool get _isFormValid =>
      _isNameValid &&
      _isPhoneValid &&
      _isAddressValid &&
      _isBirthdateValid &&
      _isGenderValid;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _birthdateController.addListener(_validateForm);

    _loadUserData();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  bool isValidBirthdate(String value) {
    if (value.isEmpty) return false;
    final dt = DateTime.tryParse(value);
    if (dt == null) return false;
    final now = DateTime.now();
    if (!dt.isBefore(now)) return false;
    final age = now.year -
        dt.year -
        ((now.month < dt.month || (now.month == dt.month && now.day < dt.day))
            ? 1
            : 0);
    return age >= 13;
  }

  void _validateForm() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final birthdate = _birthdateController.text.trim();
    final gender = _selectedGender ?? '';

    setState(() {
      _isNameValid = name.isNotEmpty;
      _isPhoneValid = isValidPhone(phone);
      _isAddressValid = address.isNotEmpty;
      _isBirthdateValid = isValidBirthdate(birthdate);
      _isGenderValid = gender.isNotEmpty;
    });
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final userData = userDoc.data();

        if (!mounted) return;

        setState(() {
          _nameController.text = userData?['name'] ?? '';
          _phoneController.text = userData?['phone'] ?? '';
          _addressController.text = userData?['address'] ?? '';
          _birthdateController.text = userData?['birthdate'] ?? '';
          final genderValue = userData?['gender'] ?? '';
          if (_genderOptions.contains(genderValue)) {
            _selectedGender = genderValue;
          } else {
            _selectedGender = null;
          }
        });

        _validateForm();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _pickBirthdate() async {
    final initialDate = _birthdateController.text.isNotEmpty
        ? (DateTime.tryParse(_birthdateController.text) ?? DateTime(2000, 1, 1))
        : DateTime(2000, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _birthdateController.text = formatted;
      });
      _validateForm();
    }
  }

  Future<void> _updateProfile() async {
    _validateForm();

    if (!_isFormValid) {
      _triggerShake();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the highlighted fields')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'birthdate': _birthdateController.text.trim(),
          'gender': _selectedGender ?? '',
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameHasText = _nameController.text.isNotEmpty;
    final nameShowError = !_isNameValid && nameHasText;
    final nameShowSuccess = _isNameValid && nameHasText;

    final phoneHasText = _phoneController.text.isNotEmpty;
    final phoneShowError = !_isPhoneValid && phoneHasText;
    final phoneShowSuccess = _isPhoneValid && phoneHasText;

    final addressHasText = _addressController.text.isNotEmpty;
    final addressShowError = !_isAddressValid && addressHasText;
    final addressShowSuccess = _isAddressValid && addressHasText;

    final birthHasText = _birthdateController.text.isNotEmpty;
    final birthShowError = !_isBirthdateValid && birthHasText;
    final birthShowSuccess = _isBirthdateValid && birthHasText;

    final genderHasValue =
        _selectedGender != null && _selectedGender!.isNotEmpty;
    final genderShowError = !_isGenderValid && genderHasValue == false;
    final genderShowSuccess = _isGenderValid && genderHasValue;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[700],
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: nameShowError ? Colors.red : Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: nameShowError ? Colors.red : Colors.white,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.white),
                    suffixIcon: nameShowSuccess
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : nameShowError
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[700],
                    labelText: 'Phone (10 digits)',
                    labelStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: phoneShowError ? Colors.red : Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: phoneShowError ? Colors.red : Colors.white,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Colors.white),
                    suffixIcon: phoneShowSuccess
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : phoneShowError
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[700],
                    labelText: 'Address',
                    labelStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color:
                            addressShowError ? Colors.red : Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: addressShowError ? Colors.red : Colors.white,
                      ),
                    ),
                    prefixIcon:
                        const Icon(Icons.location_on, color: Colors.white),
                    suffixIcon: addressShowSuccess
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : addressShowError
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _birthdateController,
                  readOnly: true,
                  onTap: _pickBirthdate,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[700],
                    labelText: 'Birthdate (YYYY-MM-DD)',
                    labelStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: birthShowError ? Colors.red : Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: birthShowError ? Colors.red : Colors.white,
                      ),
                    ),
                    prefixIcon:
                        const Icon(Icons.calendar_today, color: Colors.white),
                    suffixIcon: birthShowSuccess
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : birthShowError
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  items: _genderOptions
                      .map(
                        (g) => DropdownMenuItem<String>(
                          value: g,
                          child: Text(g),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                    _validateForm();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[700],
                    labelText: 'Gender',
                    labelStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color:
                            genderShowError ? Colors.red : Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: genderShowError ? Colors.red : Colors.white,
                      ),
                    ),
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.white),
                    suffixIcon: genderShowSuccess
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : genderShowError
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _isFormValid && !_isSubmitting ? _updateProfile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
