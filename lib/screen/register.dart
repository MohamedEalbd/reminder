import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reminder/db/auth.dart';
import 'package:reminder/db/user.dart';
import 'package:reminder/screen/login.dart';
import 'package:reminder/screen/task_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wc_form_validators/wc_form_validators.dart';
import 'dart:async';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  StorageReference storageReference;
  File file;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailTextConroller = new TextEditingController();
  TextEditingController _nameTextConroller = new TextEditingController();
  TextEditingController _passwordTextConroller = new TextEditingController();
  TextEditingController _confirmPasswordTextConroller = new TextEditingController();
  UserService _userServices = new UserService();
  bool showpassconfrim = true;
  SharedPreferences preferences;
  bool loading = false;
  Auth auth = Auth();
  bool showen = true;
  String postId = Uuid().v4();
  final StorageReference storageRef = FirebaseStorage.instance.ref();
  Future<String> savePref(String username, String email,String photoUrl ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("displayName", username);
    sharedPreferences.setString("email", email);
    sharedPreferences.setString("photoUrl", photoUrl);
    print(sharedPreferences.getString("displayName"));
    print(sharedPreferences.getString("email"));
  }

  Future _vaildForm() async {
    setState(() {
      loading = true;
    });
    String mediaUrl = await uploadImage(file);
    FormState formState = _formKey.currentState;
    if (_formKey.currentState.validate()) {
      if (_passwordTextConroller.text == _confirmPasswordTextConroller.text) {
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailTextConroller.text,
                password: _passwordTextConroller.text)
            .then((currentUser) => Firestore.instance
                .collection("users")
                .document(currentUser.user.uid)
                .setData({
                  "uid": currentUser.user.uid,
                  "displayName": _nameTextConroller.text,
                  "email": _emailTextConroller.text,
                  "password": _passwordTextConroller.text,
                   "photoUrl": mediaUrl,
                })
                .then((result) => {
                      _userServices.creatUser({
                        "username": _nameTextConroller.text,
                        "email": _emailTextConroller.text,
                        "userId": currentUser.user.uid,
                      }),
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => TaskScreen()),
                          (_) => false),
                      _nameTextConroller.clear(),
                      _emailTextConroller.clear(),
                      _passwordTextConroller.clear(),
                      _confirmPasswordTextConroller.clear(),
                    })
                .catchError((err) {
                  firebaseAuth.createUserWithEmailAndPassword(
                    email: _emailTextConroller.text,
                  );
                  print(err);
                }))
            .catchError((singUpError) {
          if (singUpError is PlatformException) {
            if (singUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text("The email Really exist"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              loading = false;
                            });
                          },
                        )
                      ],
                    );
                  });
            }
          }
          print(singUpError);
        });
        savePref(_nameTextConroller.text, _emailTextConroller.text,mediaUrl);
        print(preferences.getString("email"));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("The passwords do not match"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        loading = false;
                      });
                    },
                  )
                ],
              );
            });
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Please Enter the form"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      loading = false;
                    });
                  },
                )
              ],
            );
          });
    }
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }
  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
    storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.red[900],
                Colors.pink[800],
                Colors.purple[400],
                Colors.pinkAccent[100]
          ])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 80,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "SignUp",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      )),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              onTap: () => selectImage(context),
                              child: Center(
                                  child:  CircleAvatar(
                                    radius: 50,
                                   backgroundColor: Colors.blueGrey,
                                   backgroundImage: file == null ? NetworkImage("https://cdn.onlinewebfonts.com/svg/img_234957.png") : FileImage(file),
                                  )),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.blueGrey,
                                        blurRadius: 30,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[600]))),
                                    child: TextFormField(
                                      controller: _nameTextConroller,
                                      decoration: InputDecoration(
                                          hintText: "Name",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'The name field cannot be empty';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[600]))),
                                    child: TextFormField(
                                      controller: _emailTextConroller,
                                      decoration: InputDecoration(
                                          hintText: "Email",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                      validator: Validators.compose([
                                        Validators.required(
                                            'Email is required'),
                                        Validators.email(
                                            'Invalid email address'),
                                      ]),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[600]))),
                                    child: TextFormField(
                                      controller: _passwordTextConroller,
                                      obscureText: showen,
                                      decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              icon: showen
                                                  ? Icon(Icons.remove_red_eye)
                                                  : Icon(
                                                      Icons.panorama_fish_eye),
                                              onPressed: () {
                                                setState(() {
                                                  if (showen == true) {
                                                    showen = false;
                                                  } else if (showen == false) {
                                                    showen = true;
                                                  }
                                                });
                                              }),
                                          hintText: "Password",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'The Password field cannot be empty';
                                        } else if (value.length < 6) {
                                          return 'The Password must to be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]))),
                                    child: TextFormField(
                                      controller: _confirmPasswordTextConroller,
                                      obscureText: showpassconfrim,
                                      decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              icon: showpassconfrim
                                                  ? Icon(Icons.remove_red_eye)
                                                  : Icon(
                                                      Icons.panorama_fish_eye),
                                              onPressed: () {
                                                setState(() {
                                                  if (showpassconfrim == true) {
                                                    showpassconfrim = false;
                                                  } else if (showpassconfrim ==
                                                      false) {
                                                    showpassconfrim = true;
                                                  }
                                                });
                                              }),
                                          hintText: "re-Password",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'The Password field cannot be empty';
                                        } else if (value.length < 6) {
                                          return 'The Password must to be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
//                          Text("Forgot Password?", style: TextStyle(color: Colors.grey),),
//                          SizedBox(height: 40,),
                            SizedBox(
                              height: 50,
//                            margin: EdgeInsets.symmetric(horizontal: 20),
                              width: MediaQuery.of(context).size.width,
                              child: RaisedButton(
                                onPressed: () => _vaildForm(),
                                child: new Text(
                                  "SignUp",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                                color: Colors.blue[900],
                                shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(50),
                                    side: BorderSide(color: Colors.blueGrey)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              child: new FlatButton(
                                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => LogIn())),
                                  child: new RichText(text: TextSpan(
                                      children:<TextSpan>[
                                          TextSpan(
                                            text: "Have an account?",
                                            style: TextStyle(color: Colors.blueGrey[900],fontSize: 18,fontWeight: FontWeight.bold)
                                          ),
                                        TextSpan(
                                            text: "  Sign in",
                                            style: TextStyle(color: Colors.red[900],fontSize: 16,fontWeight: FontWeight.w600)
                                        )
                                      ]

                                  ))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Visibility(
            visible: loading ?? true,
            child: Container(
              alignment: Alignment.center,
              color: Colors.white.withOpacity(.9),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ))
      ],
    ));
  }
}

