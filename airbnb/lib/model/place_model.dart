// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> savePlaceToFirebase(Place place) async {
  try {
    final CollectionReference ref =
        FirebaseFirestore.instance.collection("myAppCollection");

    final String id =
        DateTime.now().toIso8601String() + Random().nextInt(1000).toString();

    // Save the individual place object to Firebase
    await ref.doc(id).set(place.toMap());

    print("Place successfully added to Firebase with ID: $id");
  } catch (e) {
    print("Error saving place to Firebase: $e");
    throw Exception('Failed to save place: $e');
  }
}

class Place {
  final String userid;
  final String title;
  bool isActive;
  final String image;

  final String date;
  final int price;
  final String address;
  final String category;
  final String vendor;

  final String bedAndBathroom;
  final int yearOfHostin;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;

  Place({
    required this.userid,
    required this.title,
    required this.isActive,
    required this.image,
    required this.date,
    required this.price,
    required this.address,
    required this.category,
    required this.vendor,
    required this.bedAndBathroom,
    required this.yearOfHostin,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userid': userid,
      'title': title,
      'isActive': isActive,
      'image': image,
      'date': date,
      'price': price,
      'address': address,
      'category': category,
      'vendor': vendor,
      'bedAndBathroom': bedAndBathroom,
      'yearOfHostin': yearOfHostin,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
    };
  }
}

final List<Place> listOfPlace = [
  Place(
    userid: "1",
    isActive: true,
    title: "Nice small bedroom in a nice small house",
    image:
        "https://www.momondo.in/himg/b1/a8/e3/revato-1172876-6930557-765128.jpg",
    bedAndBathroom: "1 bed . Shared bathroom",
    date: "Nov 11-16",
    price: 38,
    address: "Kathmandu, Nepal",
    category: "",
    vendor: "Marianne",
    yearOfHostin: 10,
    latitude: 27.7293,
    longitude: 85.3343,
    imageUrls: [
      "https://www.momondo.in/himg/b1/a8/e3/revato-1172876-6930557-765128.jpg",
      "https://media.timeout.com/images/105162711/image.jpg",
      "https://www.telegraph.co.uk/content/dam/Travel/hotels/2023/september/one-and-only-cape-town-product-image.jpg",
      "https://www.theindiahotel.com/extra-images/banner-01.jpg",
    ],
  ),
  Place(
    userid: "1",
    isActive: false,
    title: "Cosy room in fabulous condo!",
    image:
        "https://www.telegraph.co.uk/content/dam/Travel/hotels/2023/september/one-and-only-cape-town-product-image.jpg",
    date: "Oct 01-06",
    yearOfHostin: 6,
    bedAndBathroom: "1 double bed . Shared bathroom",
    price: 88,
    address: "Cape Town, South Africa",
    category: "",
    vendor: "Tracey",
    latitude: -33.922,
    longitude: 18.4231,
    imageUrls: [
      "https://www.telegraph.co.uk/content/dam/Travel/hotels/2023/september/one-and-only-cape-town-product-image.jpg",
      "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0e/de/f7/c3/standard-room.jpg?w=1200&h=-1&s=1",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTuMkI1MoQDzLBF-prjIp6kyXpccVol16bsew&s"
    ],
  ),
  Place(
    userid: "1",
    isActive: true,
    title: "Bright room in nice apartment bas faron",
    image: "https://www.theindiahotel.com/extra-images/banner-01.jpg",
    date: "Oct 10-16",
    price: 34,
    address: "Mumbai, India",
    category: "",
    yearOfHostin: 4,
    bedAndBathroom: "1 bed . Shared bathroom",
    vendor: "Ole",
    latitude: 19.0760,
    longitude: 72.8777,
    imageUrls: [
      "https://www.theindiahotel.com/extra-images/banner-01.jpg",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgCXf3HATaGRx4_GtvzW8FVnYfXKRQMuRzOg&s",
      "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0e/de/f7/c3/standard-room.jpg?w=1200&h=-1&s=1",
      "https://radissonhotels.iceportal.com/image/radisson-hotel-kathmandu/exterior/16256-114182-f75152296_3xl.jpg",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1P0AxSntzNAgs2_Qnl1IJCb2EebN82-KbPg&s",
    ],
  ),
  Place(
    userid: "1",
    isActive: true,
    title: "Connect with your heart to this magical place",
    image:
        "https://lyon.intercontinental.com/wp-content/uploads/sites/6/2019/11/Superior-Room-cEric-Cuvillier-2.jpg",
    date: "Dec 17-22",
    price: 76,
    address: "Lyon, France",
    category: "",
    yearOfHostin: 8,
    bedAndBathroom: "2 queen beds . Shared bathroom",
    vendor: "Benedicte",
    latitude: 45.7640,
    longitude: 4.8357,
    imageUrls: [
      "https://lyon.intercontinental.com/wp-content/uploads/sites/6/2019/11/Superior-Room-cEric-Cuvillier-2.jpg",
      "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0e/de/f7/c3/standard-room.jpg?w=1200&h=-1&s=1",
      "https://www.grandhotelnepal.com/images/slideshow/3arzB-grand4.jpg",
    ],
  ),
  Place(
    userid: "1",
    isActive: false,
    title: "En-Suite @ Sunrise Beach",
    image: "https://media.timeout.com/images/105162711/image.jpg",
    date: "Jan 26-29",
    price: 160,
    yearOfHostin: 10,
    bedAndBathroom: "1 double bed . Dedicated bathroom",
    address: "Rome, Italy",
    category: "",
    vendor: "Leva",
    latitude: 41.8967,
    longitude: 12.4822,
    imageUrls: [
      "https://media.timeout.com/images/105162711/image.jpg",
      "https://www.momondo.in/himg/b1/a8/e3/revato-1172876-6930557-765128.jpg",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_Kz2H05mZVaPIZWVbXRADEASKvBCLJv4oeg&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRctRmBUpKa5HWwWKaL9TeVTZNHfabImL8cLQ&s",
    ],
  ),
];
