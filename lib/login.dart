import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testing/dbms.dart';
import 'package:testing/home.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:testing/signup.dart';

class todoui extends StatefulWidget {
  // final String email;
  // final String pass;
  // todoui({required this.email, required this.pass});
  @override
  _todouiState createState() => _todouiState();
}

class _todouiState extends State<todoui> {
  final dbhelper = Databasehelper.instance;
  late TextEditingController  user_email,user_pass;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool validated = true;
  String errtext = "";
  String todoedited = "";
  String ests = "Email";
  String psts = "Password";
  String sts = "";
  String userName = '';
  String useremail = '';
  String pass1 = '';

  void checkuser() async {
    Map<String, dynamic> row = {
      Databasehelper.columnName: todoedited,
    };
    final id = await dbhelper.insert(row);
    print(id);
    Navigator.pop(context);
    todoedited = "";
    setState(() {
      validated = true;
      errtext = "";

    });
  }
  void initState() {

    super.initState();
    user_email = TextEditingController();
    user_pass = TextEditingController();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FlutterLogo(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Sign In Here",
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
                          hintText: ests,

                        ),

                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        obscureText: true,
                        maxLines: 1,
                        autofocus: false,
                        //initialValue: 'yu',
                        controller: user_pass,
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: "Password Is Required"),
                          MinLengthValidator(6,errorText: "Maximum 6 character only")
                        ]),
                        decoration: InputDecoration(
                          fillColor: Colors.black38,
                          filled: true,
                          contentPadding: EdgeInsets.all(15),
                          hintText: psts,

                        ),

                      ),


                      RaisedButton(
                        onPressed: login,
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text(
                          "Sign In",
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.0,),
              InkWell(
                onTap: () {
                  // send to login screen
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>SignUpScreen()));
                },
                child: Text(
                  "Sign Up Here",
                ),
              ),
              SizedBox(height: 10.0,),
              Text(
                sts,style: TextStyle(color: Colors.red,fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {

      var all = await dbhelper.queryall();
      all.forEach((row){
        setState(() {
          pass1= row['pass'];
          userName = row['name'];
          useremail = row['email'];
        });
      });
      print(userName);

    print(user_email.text.length);
    if (user_email.text.length <=0 || user_pass.text.length <=0) {
      setState(() {
        ests = "This field is required";
        psts = "This field is required";
      });
    }
    else {
        print(user_email.text);
        print(user_pass.text);
        print(useremail);
        print(pass1);
        if(useremail!=user_email.text && pass1!=user_pass.text){
          setState(() {
            sts = "Wrong EmailId or Password.";
          });
        }
        else {
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
  }
}