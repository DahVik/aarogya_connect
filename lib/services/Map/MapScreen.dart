import 'dart:async';
import 'dart:convert';
import 'package:aarogya_connect/globals/colors.dart';
import 'package:aarogya_connect/globals/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<Position> userPosition;
  Completer<GoogleMapController> _controller = Completer();

  List<Marker> _marker = [];
  List<Marker> _list = [
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(26.144518, 91.736237),
        infoWindow: InfoWindow(title: "My Position"))
  ];

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error" + error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    userPosition = getUserCurrentLocation();
  }

  List<dynamic> hospital = [];

  Future<void> fetchNearbyHospitals() async {
    final apiKey = 'AIzaSyCQwySKvMSJPfdTtzISoS2qCRLEEvA5lUM';
    final userLocation = await getUserCurrentLocation();
    final latitude = userLocation.latitude;
    final longitude = userLocation.longitude;
    final radius = 10000;

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=hospital&key=$apiKey'));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      // Check if the response has the expected structure
      if (data['status'] == 'OK') {
        // Access the list of results (places)
        final List<dynamic> results = data['results'];
        hospital = results;
        print("Hospital lenght is :${hospital.length}");
        // var index = 0;
        // Now you can iterate through the list and access properties of each place
        for (final result in results) {
          final String name = result['name'];
          final double placeLatitude = result['geometry']['location']['lat'];
          final double placeLongitude = result['geometry']['location']['lng'];
          // hospital.insert(index, name);
          // index++;
          // You can use this data to create markers on the map, for example
          // or display information about each place.
        }
      } else {
        print("Hospital lenght is :${hospital.length}");
        // Handle API error or no results found
      }
    } else {
      // Handle errors and network issues here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 45,
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              AssetConstants.location,
              fit: BoxFit.contain,
              height: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Nearby Hospitals",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: MyColors.greenColor,
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [MyColors.greenColor, MyColors.whiteColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Column(
          children: [
            Container(
              height: 400,
              margin: EdgeInsets.only(top: 20, right: 20, left: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.all(Radius.circular(20)),
                // boxShadow: [
                //   BoxShadow(
                //    color: MyColors.orangeColor,
                //     spreadRadius: 1.5,
                //     // blurRadius: 1.0,
                //   )
                // ]
              ),
              child: FutureBuilder<Position>(
                  future: userPosition,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data == null) {
                      return Text('User position is not available');
                    } else {
                      final position = snapshot.data;
                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target:
                                LatLng(position!.latitude, position.longitude),
                            zoom: 12),
                        markers: Set<Marker>.of(_marker),
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        compassEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      );
                    }
                  }),
            ),
            // Container(
            //   child: Text("${hospital.length}"),
            // ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: MyColors.homeTileColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                            color: MyColors.orangeColor,
                          ),
                        ),
                        margin: EdgeInsets.only(top: 20),
                        child: ListTile(
                          tileColor: Colors.blue[100],
                          title: Text("Hospital : ${index + 1}"),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
