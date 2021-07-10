import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
// the database helper class
class Databasehelper {
  // database name
  static final _databasename = "users.db";
  static final _databaseversion = 1;

  // the table name
  static final table = "my_table";
  // column names
  // Databasehelper.columnPic: imgString,
  // Databasehelper.columnName: fname.text,
  // Databasehelper.columnNum: num.text,
  // Databasehelper.columnEmail: user_email.text,
  // Databasehelper.columnPass: pass.text,
  static final columnID = 'id';
  static final columnName = "name";
  static final columnNum = "num";
  static final columnEmail = 'email';
  static final columnPass = "pass";
  static final columnPic = "imgstr";
  // a database
  static Database? _database;

  // privateconstructor
  Databasehelper._privateConstructor();
  static final Databasehelper instance = Databasehelper._privateConstructor();

  // asking for a database
  Future<Database> get database async =>
      _database ??= await _initiateDatabase();

  // function to return a database
  Future<Database> _initiateDatabase() async {
    Directory documentdirecoty = await getApplicationDocumentsDirectory();
    String path = join(documentdirecoty.path, _databasename);
    return await openDatabase(path,
        version: _databaseversion, onCreate: _onCreate);
  }

  // create a database since it doesn't exist
  Future _onCreate(Database db, int version) async {
    // sql code
    await db.execute('''
      CREATE TABLE $table (
        $columnID INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnNum  TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnPass TEXT NOT NULL,
        $columnPic TEXT NOT NULL
      );
      ''');
  }

  // functions to insert data
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // function to query all the rows
  Future<List<Map<String, dynamic>>> queryall() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // function to delete some data
  Future<int> deletedata() async {
    Database db = await instance.database;
    var res = await db.delete(table);
    return res;
  }
}

class Utility {
  static Image imageFromBase64String(String base64String){
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }
  static Uint8List dataFromBase64String(String base64String){
    return base64Decode(base64String);
  }
  static String  base64String(Uint8List data){
    return base64Encode(data);
  }
}


class Author {
  late String firstName;
   late String lastName;
  late String gender;


  Author(this.firstName,
     this.lastName,
     this.gender);

  Author.fromJson(Map<String, dynamic> json) {
    firstName = json['author'];
    lastName = json['url'];
    gender = json['download_url'];

  }
}
