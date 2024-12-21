import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:airbnb/model/place_model.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each form field
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _vendorProfessionController =
      TextEditingController();
  final TextEditingController _vendorProfileController =
      TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _bedAndBathroomController =
      TextEditingController();
  final TextEditingController _yearOfHostingController =
      TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  bool _isActive = true;
  String? _selectedCategory; // Selected category
  List<String> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories from Firestore
  }

  // Fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('AppCategory').get();

      setState(() {
        _categories = querySnapshot.docs
            .map((doc) => doc['title'] as String)
            .toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  // Form submit function
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category.')),
        );
        return;
      }

      _formKey.currentState!.save();

      // Process image URLs
      final imageUrls =
          _imageController.text.split(',').map((url) => url.trim()).toList();

      final place = Place(
        title: _titleController.text,
        isActive: _isActive,
        image: imageUrls.isNotEmpty ? imageUrls.first : "",
        rating: double.parse(_ratingController.text),
        date: _dateController.text,
        price: int.parse(_priceController.text),
        address: _addressController.text,
        category: _selectedCategory!,
        vendor: _vendorController.text,
        vendorProfession: _vendorProfessionController.text,
        vendorProfile: _vendorProfileController.text,
        review: int.parse(_reviewController.text),
        bedAndBathroom: _bedAndBathroomController.text,
        yearOfHostin: int.parse(_yearOfHostingController.text),
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        imageUrls: imageUrls,
      );

      // Save place to Firestore
      savePlaceToFirebase(place);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Place'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_titleController, "Title", theme),
                _buildSwitchField("Is Active", _isActive, (value) {
                  setState(() {
                    _isActive = value;
                  });
                }, theme),
                _buildTextField(
                    _imageController, "Image URLs (comma-separated)", theme),
                _buildTextField(_ratingController, "Rating", theme,
                    isNumeric: true),
                _buildTextField(_dateController, "Date", theme),
                _buildTextField(_priceController, "Price", theme,
                    isNumeric: true),
                _buildTextField(_addressController, "Address", theme),
                _buildCategoryDropdown(theme),
                _buildTextField(_vendorController, "Vendor", theme),
                _buildTextField(
                    _vendorProfessionController, "Vendor Profession", theme),
                _buildTextField(
                    _vendorProfileController, "Vendor Profile URL", theme),
                _buildTextField(_reviewController, "Review", theme,
                    isNumeric: true),
                _buildTextField(_bedAndBathroomController,
                    "Bed and Bathroom Details", theme),
                _buildTextField(
                    _yearOfHostingController, "Year of Hosting", theme,
                    isNumeric: true),
                _buildTextField(_latitudeController, "Latitude", theme,
                    isNumeric: true),
                _buildTextField(_longitudeController, "Longitude", theme,
                    isNumeric: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.primaryTextTheme.labelLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown for selecting category
  Widget _buildCategoryDropdown(ThemeData theme) {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No categories available.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: "Category",
          labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Category is required";
          }
          return null;
        },
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField(
      TextEditingController controller, String label, ThemeData theme,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  // Reusable switch widget
  Widget _buildSwitchField(String label, bool value,
      void Function(bool) onChanged, ThemeData theme) {
    return SwitchListTile(
      title: Text(
        label,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: theme.primaryColor,
    );
  }

  // Save place to Firestore
  Future<void> savePlaceToFirebase(Place place) async {
    final docRef = FirebaseFirestore.instance.collection('places').doc();
    await docRef.set(place.toMap());
  }
}
