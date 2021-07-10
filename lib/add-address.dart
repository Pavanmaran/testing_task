/*

import 'package:ahya_app/pages/reviewandbook.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahya_app/providers/navigationProvider.dart';

class AddAddress extends StatefulWidget {
  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  @override
  // ignore: override_on_non_overriding_member
  Location location = new Location();
  LocationData _locationData;
  LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);
  GoogleMapController mapController;
  bool mapToggle = false;
  String houseNummber;
  String street;
  String addressType;

  String addr = '';

  String landmark;
  bool _loading = false;
  bool _loading1 = false;
  Color color1;
  Color color2;
  Color sColor = Color(0xff323B77);

  Color unsColor = Color(0xffA3A3A3);

  int _selectedValue1 = -1;
  int _selectedValue2 = -1;
  final _houseformKey = GlobalKey<FormState>();
  final _streetformKey = GlobalKey<FormState>();
  final _landmarkformKey = GlobalKey<FormState>();
  final _houseController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();

  List<Marker> myMarker = [];

  void getlocation() async {
    setState(() {
      _loading1 = true;
    });
    _locationData = await location.getLocation();
    setState(() {
      mapToggle = true;
      _initialPosition =
          LatLng(_locationData.latitude, _locationData.longitude);
      print(_initialPosition);
      getAddress(_initialPosition);
    });
  }

  @override
  void initState() {
    super.initState();
    getlocation();
  }

  String validateAddress(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Address';
    else
      return null;
  }

  void onTap1(int value) {
    setState(() {
      _selectedValue1 = value;
      _selectedValue2 = -1;
      color1 = sColor;
      color2 = unsColor;
      addressType = 'Home';
    });
  }

  void onTap2(int value) {
    setState(() {
      _selectedValue2 = value;
      _selectedValue1 = -1;
      color2 = sColor;
      color1 = unsColor;
      addressType = 'Others';
    });
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
      myMarker
          .add(Marker(markerId: MarkerId('id-1'), position: _initialPosition));
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
    getAddress(_initialPosition);
  }

  Future<void> getAddress(LatLng _position) async {
    final coordinates = Coordinates(_position.latitude, _position.longitude);
    try {
      final addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      addr = addresses.first.addressLine;
      street = addresses.first.locality;
      houseNummber = addresses.first.featureName;
      setState(() {
        _loading1 = false;
      });

      print(addresses.first.addressLine);
      print(addresses.first.subAdminArea);
      print(addresses.first.adminArea);
      print(addresses.first.featureName);
      print(addresses.first.postalCode);
      print(addresses.first.subLocality);
      print(addr);
    } catch (e) {
      print(e);
      setState(() {
        _loading1 = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).accentColor,
        content: Text(
          message,
          style: TextStyle(
            color: const Color(0xFFFCD095),
          ),
        ),
        duration: const Duration(milliseconds: 2000),
        margin: EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Future<void> _addAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    print(id);
    final token = prefs.getString('token');
    print(token);
    var myHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(
        'http://ahya-env.eba-4mc428r9.us-east-2.elasticbeanstalk.com/api/user/$id/add/address');
    try {
      final request = await http.post(
        url,
        headers: myHeaders,
        body: json.encode({
          "latitude": _initialPosition.latitude.toString(),
          "longitude": _initialPosition.latitude.toString(),
          "apartmentNumber": houseNummber,
          "street": street,
          'landmark': landmark == null ? '' : landmark,
          'addressType': addressType,
        }),
      );
      print(request.reasonPhrase);
      print(request.statusCode);
      final responseData = json.decode(request.body);
      print('responseData: $responseData');

      if (responseData['error'] == true) {
        print(
            'An error occured while fetching address: ${responseData['message']}');

        _showSnackBar(responseData['message']);

        setState(() {
          _loading = false;
        });

        return;
      }

      _showSnackBar(responseData['message']);

      setState(() {
        _loading = false;
      });

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Review()));
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
      _showSnackBar('An error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: Icon(
      //       Icons.keyboard_arrow_left,
      //       color: Theme.of(context).accentColor,
      //       size: 40,
      //     ),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   toolbarHeight: 80,
      //   title: Text(
      //     'Add Address',
      //     style: TextStyle(
      //       color: Theme.of(context).accentColor,
      //       fontSize: 24,
      //       fontWeight: FontWeight.w500,
      //     ),
      //   ),
      // ),
      backgroundColor: Color(0xffFFF7EA),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild.unfocus();
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 380,
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
                                child: GestureDetector(
                                  onTap: getlocation,
                                  child: Image.asset(
                                      'assets/images/logos/navigation.png'),
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            address(),
                            SizedBox(height: 25),
                            housetextFields(),
                            SizedBox(height: 15),
                            streettextFields(),
                            SizedBox(height: 15),
                            landmarktextFields(),
                            SizedBox(height: 15),
                            Text(
                              'Address Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff323B77),
                              ),
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: 1,
                                  groupValue: _selectedValue1,
                                  onChanged: onTap1,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                SvgPicture.asset(
                                  'assets/images/logos/Home.svg',
                                  color: color1,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Home',
                                  style: TextStyle(
                                      color: color1,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Radio(
                                  value: 0,
                                  groupValue: _selectedValue2,
                                  onChanged: onTap2,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                SvgPicture.asset(
                                  'assets/images/logos/building.svg',
                                  color: color2,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Other',
                                  style: TextStyle(
                                      color: color2,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _addAddress,
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Color(0xFF323B77),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                        primary: Color(0xFFFDD191),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35, left: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: 200,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_left,
                        color: Theme.of(context).accentColor,
                        size: 40,
                      ),
                      Text(
                        'Add Address',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/logos/Address.png'),
            SizedBox(
              width: 10,
            ),
            Text(
              'Selected Location',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xff323B77),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget housetextFields() {
    return _loading1
        ? CircularProgressIndicator()
        : Form(
            key: _houseformKey,
            child: TextFormField(
              enabled: !_loading,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              obscureText: false,
              keyboardType: TextInputType.name,
              onChanged: (value) {
                this.houseNummber = value;
              },
              validator: (value) => value.isEmpty
                  ? 'Address is required'
                  : validateAddress(value),
              controller: _houseController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.only(top: 18, bottom: 18, left: 15, right: 15),
                hintText: "House/Apartment No.",
                hintStyle: TextStyle(
                  color: Color(0xFFA5ACD9),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 16.0,
                    color: Color(0xFFE5E5E5),
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          );
  }

  Widget streettextFields() {
    return _loading1
        ? CircularProgressIndicator()
        : Form(
            key: _streetformKey,
            child: TextFormField(
              initialValue: addr,
              style: TextStyle(
                  color: Color(0xff323B77),
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
              enabled: !_loading,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              obscureText: false,
              keyboardType: TextInputType.name,
              onChanged: (value) {
                this.street = value;
              },
              onSaved: (value) {
                setState(() {
                  addr = value;
                });
              },
              validator: (value) =>
                  value.isEmpty ? 'Street is required' : validateAddress(value),
              // controller: _streetController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.only(top: 18, bottom: 18, left: 15, right: 15),
                hintText: 'Street',
                hintStyle: TextStyle(
                  color: Color(0xFFA5ACD9),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 16.0,
                    color: Color(0xFFE5E5E5),
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          );
  }

  Widget landmarktextFields() {
    return _loading1
        ? CircularProgressIndicator()
        : Form(
            key: _landmarkformKey,
            child: TextFormField(
              enabled: !_loading,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              obscureText: false,
              keyboardType: TextInputType.name,
              onChanged: (value) {
                setState(() {
                  this.landmark = value;
                });
              },
              controller: _landmarkController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.only(top: 18, bottom: 18, left: 15, right: 15),
                hintText: "Landmark (optional)",
                hintStyle: TextStyle(
                  color: Color(0xFFA5ACD9),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 16.0,
                    color: Color(0xFFE5E5E5),
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          );
  }

  // Widget nextButton() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 20.0),
  //     child: Container(
  //       alignment: Alignment.center,
  //       // height: 150,
  //       // width: 300,
  //       child: FlatButton(
  //         onPressed: () {
  //           _addAddress();
  //         },
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
  //         padding: EdgeInsets.all(0.0),
  //         child: Ink(
  //           decoration: BoxDecoration(
  //             color: Color(0xffFDD191),
  //             borderRadius: BorderRadius.circular(25.0),
  //           ),
  //           child: Container(
  //             constraints: BoxConstraints(maxWidth: 327.0, maxHeight: 50.0),
  //             alignment: Alignment.center,
  //             child: Text(
  //               "Next",
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                   color: Color(0xFF323B77),
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w600),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

 */

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'dart:convert' as convert;
import 'package:testing/dbms.dart';
class authors extends StatefulWidget {
  @override
  _authorsState createState() => _authorsState();
}

class _authorsState extends State<authors> {
  late List datamap;
  late Future<List<dynamic>> datamap1;
  late List<dynamic> futureAuthor;
  void initState() {
    super.initState();
    datamap = [{
      'Author':'Ragini Sharma',
     ' url' : 'http://:iotinns.com'
    },
    {
    'Author':'Annu Sharma',
    'url' : 'http://:iotinns.com'
    }];
    datamap1= authordata();
   // print(futureAuthor);
  }

  Future<List<dynamic>>authordata() async {
    var url = Uri.http('picsum.photos','/v2/list');
    try {
      final response = await http.get(url);
      print(response.statusCode);
      print(response.body);
      List dmap=  convert.jsonDecode(response.body) as List<dynamic>;
       setState(() {
         futureAuthor = dmap as List<dynamic> ;
       });
       return dmap;

    } on SocketException catch (e) {
      throw Exception('Failed to load');
    }
  }



  @override
  Widget build(BuildContext context) {
    print(datamap1);
    return Scaffold(
        appBar: AppBar(
          title: Text("Authors List"),
        ),
        body: Center(
          child: FutureBuilder<dynamic>(future:datamap1,
              builder: (context,snapshot){
            if(snapshot.hasData){
              return ListView.builder(itemCount :5,itemBuilder: (BuildContext context,int index){
                //Map newMap = snapshot.data[index].toString() as Map;
                var listy = snapshot.data[index];
               print(listy);
                return ListTile(leading: Image.network(snapshot.data[index]['download_url'],scale: 5,width: 100,) ,

                trailing: Text(" "),
                  title: Text(snapshot.data[index]['author'].toString()),
                );
              });
               // Text(snapshot.data.toString);
            } else if(snapshot.hasError){
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          }),


        ));
  }
}

