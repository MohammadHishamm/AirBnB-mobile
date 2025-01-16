import 'dart:async';

import 'package:airbnb/Components/my_icon_button.dart';
import 'package:airbnb/components/adaptive_image.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWithCustomInfoWindows extends StatefulWidget {
  const MapWithCustomInfoWindows({super.key});

  @override
  State<MapWithCustomInfoWindows> createState() =>
      _MapWithCustomInfoWindowsState();
}

class _MapWithCustomInfoWindowsState extends State<MapWithCustomInfoWindows> {
  LatLng myCurrentLocation = const LatLng(27.7172, 85.3240);
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  GoogleMapController? googleMapController;

  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  final CollectionReference placeCollection =
      FirebaseFirestore.instance.collection("myAppCollection");

  List<Marker> markers = [];
  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  StreamSubscription? _markerSubscription;
  // for custom maker
  Future<void> _loadMarkers() async {
    try {
      customIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(),
        "assets/images/marker.png",
        height: 40,
        width: 30,
      );

      Size size = MediaQuery.of(context).size;

      // Store the subscription
      _markerSubscription =
          placeCollection.snapshots().listen((QuerySnapshot streamSnapshot) {
        if (!mounted) return; // Exit if widget is disposed

        final List<Marker> myMarker = [];

        for (final marker in streamSnapshot.docs) {
          final dat = marker.data();
          if (dat is Map) {
            final String address = dat['address'] ?? 'Unknown Address';
            final double latitude =
                (dat['latitude'] as num?)?.toDouble() ?? 0.0;
            final double longitude =
                (dat['longitude'] as num?)?.toDouble() ?? 0.0;
            final List imageUrls = dat['imageUrls'] ?? [];
            final String date = dat['date'] ?? 'Unknown Date';
            final double price = (dat['price'] as num?)?.toDouble() ?? 0.0;

            if (latitude == 0.0 && longitude == 0.0) continue;

            myMarker.add(
              Marker(
                markerId: MarkerId(address),
                position: LatLng(latitude, longitude),
                onTap: () {
                  _customInfoWindowController.addInfoWindow!(
                    Container(
                      height: size.height * 0.32,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: size.height * 0.203,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                  child: imageUrls.isNotEmpty
                                      ? AnotherCarousel(
                                          images: List<Widget>.from(
                                            imageUrls
                                                .map((url) => AdaptiveImage(
                                                      imageSource: url,
                                                      fit: BoxFit.cover,
                                                    )),
                                          ),
                                          dotSize: 6,
                                          indicatorBgPadding: 5,
                                          dotBgColor: Colors.transparent,
                                        )
                                      : const Center(
                                          child: Text('No Images Available'),
                                        ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 14,
                                right: 14,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    const SizedBox(width: 13),
                                    InkWell(
                                      onTap: () {
                                        _customInfoWindowController
                                            .hideInfoWindow!();
                                      },
                                      child: const MyIconButton(
                                        icon: Icons.close,
                                        radius: 15,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      address,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                                const Text(
                                  "3066 m elevation",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '\$$price',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: " / night",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    LatLng(latitude, longitude),
                  );
                },
                icon: customIcon,
              ),
            );
          }
        }

        if (mounted) {
          setState(() {
            markers = myMarker;
          });
        }
      });
    } catch (e) {
      debugPrint('Error loading markers: $e');
    }
  }

  @override
  @override
  void dispose() {
    _markerSubscription?.cancel();
    _customInfoWindowController.dispose();

    // Only dispose if googleMapController is not null
    googleMapController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {
        // now, what we need is=> if we clik on map icon open the bottomsheet and show the goofle map,
        // i have already setup the project for google map, api key, and developer account,
        // if you don't have knwledge about that then visit my goome map playlist, i have cover it from zero level
        showModalBottomSheet(
            clipBehavior: Clip.none,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) {
              return Container(
                color: Colors.white,
                height: size.height * 0.77,
                width: size.width,
                child: Stack(
                  children: [
                    SizedBox(
                      height: size.height * 0.77,
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: myCurrentLocation),
                        onMapCreated: (GoogleMapController controller) {
                          googleMapController = controller;
                          _customInfoWindowController.googleMapController =
                              controller;
                        },
                        onTap: (argument) {
                          _customInfoWindowController.hideInfoWindow!();
                        },
                        onCameraMove: (position) {
                          _customInfoWindowController.onCameraMove!();
                        },
                        markers: markers.toSet(),
                      ),
                    ),
                    CustomInfoWindow(
                      controller: _customInfoWindowController,
                      height: size.height * 0.34,
                      width: size.width * 0.85,
                      offset: 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 170,
                          vertical: 5,
                        ),
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
      label: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          children: [
            SizedBox(width: 5),
            Text(
              "Map",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.map_outlined,
              color: Colors.white,
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
