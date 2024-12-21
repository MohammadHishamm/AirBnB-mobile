import 'package:flutter/material.dart';
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

  // Form submit function
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
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

      // Call savePlaceToFirebase to save the place
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
}
