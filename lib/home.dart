import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/add-address.dart';
import 'package:testing/home.dart';
import 'package:testing/login.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as pth;
import 'dart:convert';
import 'package:testing/dbms.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';


class homePage extends StatefulWidget {
  final String path ;
  homePage({required this.path});
  @override
  _homePageState createState() => _homePageState(this.path);
}

class _homePageState extends State<homePage> {
  late LatLng _currentpos = LatLng(28.3015331, 77.4036721);
  final dbhelper = Databasehelper.instance;
  String userName = '';
  String useremail = '';
  String pass = '';
  late Map dataMap;
  final String path;
  _homePageState(this.path);

  Location location = new Location();
  late LocationData _locationData;
  LatLng _initialPosition = LatLng(28.3015331, 77.4036721);
  late GoogleMapController mapController;
  bool mapToggle = false;
  late String houseNummber;
  late String street;
  late String addressType;
  bool _loading = false;
  bool _loading1 = false;
  late LatLng currentposition;

  void initState() {
    super.initState();
    getlocation();
    show();
  }
  List<Marker> myMarker = [];

  void getlocation() async {

    setState(() {
      _loading1 = true;
    });
    _locationData = await location.getLocation();
    Geolocator.getCurrentPosition(forceAndroidLocationManager: true)
        .then((Position position) {
          setState(() {
            _initialPosition  = position as LatLng;
          });
    });
    setState(() {
      mapToggle = true;
      _initialPosition =
          LatLng(_locationData.latitude!.toDouble(), _locationData.longitude!.toDouble());
      //    LatLng(_locationData.latitude, _locationData.longitude);
      print(_initialPosition);
      print("locationdata: $_locationData");
      //getAddress(_initialPosition);
    });

  }
  _handleTap(LatLng tappedPoint) {
    print(tappedPoint);
    setState(() {
      myMarker = [];
      myMarker.add(Marker(
          markerId: MarkerId(
            tappedPoint.toString(),
          ),
          position: tappedPoint,
          draggable: true,
          onDragEnd: (dragEndPosition) {
            print(dragEndPosition);
            _initialPosition = dragEndPosition;
          }));
    });
   // getAddress(_initialPosition);
  }
  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
      myMarker
          .add(Marker(markerId: MarkerId('id-1'), position: _initialPosition));
    });
  }
  @override
  Widget build(BuildContext context) {
    print(_initialPosition.latitude.toString()+ " " + _initialPosition.longitude.toString());
print(path);
    return MaterialApp(
      title: "Home Page",
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Center(
                child: Container(
                  width: 65,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: FileImage(File(path)) ,
                       // image: Utility.imageFromBase64String(imgString).image ,
                        fit: BoxFit.fill
                    ),
                  ),),
              ),
              SizedBox(width: 9,),
              Text(userName),
              SizedBox(width: 59,),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () =>
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => todoui()))

            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 5,),
            Center(
                child: Text("Welcome $userName",
                  style: TextStyle(
                  color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),)
            ),
            // RaisedButton(
            //   child: Text("delete"),
            //   onPressed: delete,
            // ),
            // RaisedButton(
            //   child: Text("Show"),
            //   onPressed: show,
            // ),
            SizedBox(height: 5,),
            Center(
                child: Container(
                  width: double.infinity,
                  height: 500,
                  child: mapToggle
                      ? Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GoogleMap(
                        onMapCreated: onMapCreated,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(
                            target: _initialPosition, zoom: 15),
                        markers: Set.from(myMarker),
                        onTap: _handleTap,
                      ),
                      Positioned(
                        child: IconButton(
                            icon: Icon(Icons.exit_to_app),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: getlocation
                        ),
                      ),
                    ],
                  )
                      : Center(
                    child: Text(
                      'Loading... Please Wait',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

            ),
            SizedBox(height: 5,),
            RaisedButton(
              child: Text("Author List"),
              onPressed:  () =>
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => authors())),
            ),
          ],
        )
      ),
    );
  }


  Future<void> delete() async {
      await dbhelper.deletedata();
  }
  Future<void> show() async {
    var all = await dbhelper.queryall();
    all.forEach((row){
      setState(() {
        pass= row['pass'];
        userName = row['name'];
        useremail = row['email'];
      });
    });
    print(all);
  }
}
