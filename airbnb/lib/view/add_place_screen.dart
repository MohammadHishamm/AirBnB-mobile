import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:airbnb/model/place_model.dart';
import 'package:geolocator/geolocator.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  // Controllers for each form field
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();

  final TextEditingController _bedAndBathroomController =
      TextEditingController();
  final TextEditingController _yearOfHostingController =
      TextEditingController();

  bool _isActive = true;
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoadingCategories = true;
  LatLng? _currentLocation;

  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(30.0444, 31.2357); // Default location
          });
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(30.0444, 31.2357); // Default location
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(30.0444, 31.2357); // Default location
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      // In case of any error, fallback to default location
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(30.0444, 31.2357); // Default location
        });
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('AppCategory').get();

      setState(() {
        _categories =
            querySnapshot.docs.map((doc) => doc['title'] as String).toList();
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

  void _submitForm() async {
    try {
      // Validate the form.
      if (_formKey.currentState!.validate()) {
        if (_selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a category.')),
          );
          return;
        }

        if (_selectedLocation == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please select a location on the map.')),
          );
          return;
        }

        // Save the form state.
        _formKey.currentState!.save();

        // Extract and clean the image URLs.
        final imageUrls = _imageController.text
            .split(',')
            .map((url) => url.trim())
            .where((url) => url.isNotEmpty)
            .toList();

        // Create the place object.
        final place = Place(
          userid: user!.uid,
          title: _titleController.text,
          isActive: _isActive,
          image: imageUrls.isNotEmpty ? imageUrls.first : "",
          date: _dateController.text,
          price: int.parse(_priceController.text),
          address: _addressController.text,
          category: _selectedCategory!,
          vendor: _vendorController.text,
          bedAndBathroom: _bedAndBathroomController.text,
          yearOfHostin: int.parse(_yearOfHostingController.text),
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          imageUrls: imageUrls,
        );

        // Show a loading indicator.
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Save the place to Firebase.
        try {
          // Perform Firebase operation
          await savePlaceToFirebase(place);
        } finally {
          // Ensure the dialog is dismissed regardless of success/failure
          if (mounted) Navigator.of(context).pop();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Place added successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // Error Handling
      print("Error submitting form: $e");
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss dialog if an error occurs
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
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
                _buildTextField(_dateController, "Date", theme),
                _buildTextField(_priceController, "Price", theme,
                    isNumeric: true),
                _buildTextField(_addressController, "Address", theme),
                _buildCategoryDropdown(theme),
                _buildTextField(_vendorController, "Vendor", theme),
                _buildTextField(_bedAndBathroomController,
                    "Bed and Bathroom Details", theme),
                _buildTextField(
                    _yearOfHostingController, "Year of Hosting", theme,
                    isNumeric: true),
                const SizedBox(height: 16),
                const Text("Select Location on Map:"),
                SizedBox(
                  height: 300,
                  child: _currentLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target:
                                _currentLocation!, // Either user's location or default
                            zoom: 14,
                          ),
                          onTap: (LatLng location) {
                            setState(() {
                              _selectedLocation = location;
                            });
                          },
                          markers: _selectedLocation != null
                              ? {
                                  Marker(
                                    markerId:
                                        const MarkerId('selected-location'),
                                    position: _selectedLocation!,
                                  ),
                                }
                              : {},
                        ),
                ),
                if (_selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Selected Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}",
                    ),
                  ),
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
}
