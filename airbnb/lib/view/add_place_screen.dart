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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Place'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_titleController, "Title"),
                _buildSwitchField("Is Active", _isActive, (value) {
                  setState(() {
                    _isActive = value;
                  });
                }),
                _buildTextField(
                    _imageController, "Image URLs (comma-separated)"),
                _buildTextField(_ratingController, "Rating", isNumeric: true),
                _buildTextField(_dateController, "Date"),
                _buildTextField(_priceController, "Price", isNumeric: true),
                _buildTextField(_addressController, "Address"),
                _buildTextField(_vendorController, "Vendor"),
                _buildTextField(
                    _vendorProfessionController, "Vendor Profession"),
                _buildTextField(_vendorProfileController, "Vendor Profile URL"),
                _buildTextField(_reviewController, "Review", isNumeric: true),
                _buildTextField(
                    _bedAndBathroomController, "Bed and Bathroom Details"),
                _buildTextField(_yearOfHostingController, "Year of Hosting",
                    isNumeric: true),
                _buildTextField(_latitudeController, "Latitude",
                    isNumeric: true),
                _buildTextField(_longitudeController, "Longitude",
                    isNumeric: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
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
  Widget _buildSwitchField(
      String label, bool value, void Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.black,
    );
  }
}
