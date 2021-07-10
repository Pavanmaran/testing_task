import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testing/home.dart';
import 'package:testing/login.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as pth;
import 'dart:convert';
import 'package:testing/dbms.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late String email;
  late String password;
  late TextEditingController fname,  num, user_email,pass;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String filename ='';
  File? file;

  String imgString='';
  String path='';
  final dbhelper = Databasehelper.instance;
  late final File localImage;
  late File _image;
  String filePath = '';
  late Image image ;
  final ImagePicker _picker = ImagePicker();
  void initState() {

    super.initState();
    image = Image.network("url", errorBuilder: (context, error, stackTrace) {
      return Text(" "); //do something
    },);

         //email1 = email.toString().replaceAll('@', '');
    //  email2 = email1.toString().replaceAll('.', '');
    fname = TextEditingController();
    num= TextEditingController();
    user_email = TextEditingController();
    pass = TextEditingController();

  }

  Future<void> handleSignup() async {
    delete();
    Map<String, dynamic> row = {
      Databasehelper.columnName: fname.text,
      Databasehelper.columnNum: num.text,
      Databasehelper.columnEmail: user_email.text,
      Databasehelper.columnPass: pass.text,
      Databasehelper.columnPic: imgString
    };
    final id = await dbhelper.insert(row);

    print(id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return homePage(path: filePath);}),);
  }
  pickimg2() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);

// getting a directory path for saving
    final Directory extDir = await getApplicationDocumentsDirectory();
    String dirPath = extDir.path;
    filePath = '$dirPath/image.png';
    imgString = filePath;

// copy the file to a new path
    final File newImage = await _image.copy(filePath);
    setState(() {
      if (pickedFile != null) {
        _image = newImage;

          List<int> imageBase64 = _image.readAsBytesSync();
          String imageAsString = base64Encode(imageBase64);
          Uint8List uint8list = base64.decode(imageAsString);
          image = Image.memory(uint8list);

      } else {
        print('No image selected.');
      }
    });


  }
  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? pth.basename(file!.path) : 'No File Selected';
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FlutterLogo(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Signup Here",
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Form(
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        obscureText: false,
                        maxLines: 1,
                        autofocus: false,
                        //initialValue: 'yu',
                        controller: fname,
                        validator: MultiValidator([

                          MaxLengthValidator(6,errorText: "Maximum 20 character only")
                        ]),
                        decoration: InputDecoration(
                          fillColor: Colors.black38,
                          filled: true,
                          contentPadding: EdgeInsets.all(15),
                          hintText: "Full Name",

                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        obscureText: false,
                        maxLines: 1,
                        autofocus: false,
                        //initialValue: 'yu',
                        controller: num,
                        validator: MultiValidator([

                          MinLengthValidator(10, errorText: "Minimum 10 character only"),
                          MaxLengthValidator(12, errorText: "Maximum 20 character only")
                        ]),
                        decoration: InputDecoration(
                          fillColor: Colors.black38,
                          filled: true,
                          contentPadding: EdgeInsets.all(15),
                          hintText: "Mobile Number",
                        ),

                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        obscureText: false,
                        maxLines: 1,
                        autofocus: false,
                        //initialValue: 'yu',
                        controller: user_email,
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: "Email Is Required"),
                          MaxLengthValidator(30,errorText: "Maximum 30 character only")
                        ]),
                        decoration: InputDecoration(
                          fillColor: Colors.black38,
                          filled: true,
                          contentPadding: EdgeInsets.all(15),
                          hintText: "Email",

                        ),

                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        obscureText: true,
                        maxLines: 1,
                        autofocus: false,
                        //initialValue: 'yu',
                        controller: pass,
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: "Password Is Required"),
                          MinLengthValidator(6,errorText: "Maximum 6 character only")
                        ]),
                        decoration: InputDecoration(
                          fillColor: Colors.black38,
                          filled: true,
                          contentPadding: EdgeInsets.all(15),
                          hintText: "Password",

                        ),

                      ),
                      SizedBox(height: 8),
                      RaisedButton(
                        onPressed: pickimg2,
                        color: Colors.black38,
                        textColor: Colors.white,
                        child: Text(
                          "Add profile photo",
                        ),
                      ),
                      SizedBox(height: 1 ),
                      Text(
                        fileName,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),

                      RaisedButton(
                        onPressed: handleSignup,
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text(
                          "Sign Up",
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  // send to login screen
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>todoui()));
                },
                child: Text(
                  "Login Here",
                ),
              ),
              Center(
                child: Container(
                  width: 65,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: image.image
                        // image: Utility.imageFromBase64String(imgString).image ,
                        //fit: BoxFit.fill
                    ),
                  ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> delete() async {
    await dbhelper.deletedata();
  }
}