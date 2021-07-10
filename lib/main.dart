import 'package:path_provider/path_provider.dart';
import 'package:testing/signup.dart';
import 'package:testing/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:testing/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as pth;
import 'dart:convert';
import 'package:testing/dbms.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.purple,
        primarySwatch: Colors.purple,
        accentColor: Colors.purple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  String filePath = '';
  String userName = '';
  String useremail = '';
  String pass = '';
  final dbhelper = Databasehelper.instance;
  void initState() {
    super.initState();
    fetpath();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body:Container(
        child:RaisedButton(
          onPressed: fetpath,
          color: Colors.green,
          textColor: Colors.white,
          child: Text(
            "Sign In",
          ),
        ),
      ) ,
    );
  }
  Future<void> fetpath() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    String dirPath = extDir.path;
    String filePath = '$dirPath/image.png';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return homePage(path: filePath,);
      }),);
  }
}