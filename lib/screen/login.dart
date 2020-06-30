import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:reminder/screen/register.dart';
import 'package:reminder/screen/task_screen.dart';
import 'package:reminder/widgets/sharepref.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class LogIn extends StatefulWidget {
  String message;
  LogIn({Key key,this.message}):super(key:key);
  @override
  _LogInState createState() => _LogInState(message: message);
}

class _LogInState extends State<LogIn> {
  String message;
  bool showSigin = true;
  _LogInState({Key key,this.message});
  SharedPreferences preferences;
  final GlobalKey<FormState> _globalKey = new GlobalKey<FormState>();//form
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();//snack
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String _email;
  String _password;
  String _name;
  bool loading = false;
  bool isLogedIn = false;
  bool showen = true;
  TapGestureRecognizer _changeSign;
  @override
  void initState() {
    super.initState();
//    _checkLogin();TODO move it with her method to home screen in init State and verfi
    if(message!=null) {
//      print(message);
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _scaffoldKey.currentState.showSnackBar(
            new SnackBar(content: new Text('$message')),
          ));
    }
  }
//  void _checkLogin()async{
//    SharedPreferences pref = await SharedPreferences.getInstance();
////    pref.clear();
////    pref.commit();
//    try{
//
//      if(pref.getBool("google")){
//        final AuthCredential credential = GoogleAuthProvider.getCredential(
//          accessToken: pref.getString("accessToken"),
//          idToken: pref.getString("idToken"),
//        );
//        final AuthResult authResult = await _auth.signInWithCredential(credential);
//        final FirebaseUser user = authResult.user;
//        Navigator.of(context)
//            .pushNamedAndRemoveUntil("/Home", (Route<dynamic> route) => false);
//      }else{
//        _email =await pref.getString("email");
//        _password =await pref.getString("password");
//        await _auth.signInWithEmailAndPassword(email: _email, password: _password);
//        Navigator.of(context).pushNamedAndRemoveUntil(
//            "/Home", (Route<dynamic> route) => false);
//      }
//    }catch (e){
//      print(e);
//    }
//  }
  Future<String> savePref(String username, String email,String photoUrl ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("displayName", username);
    sharedPreferences.setString("email", email);
    sharedPreferences.setString("photoUrl", photoUrl);
  }
  //google sign in
  Future handleLogin() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      loading = true;
    });
    GoogleSignInAccount googleuser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
    await googleuser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final FirebaseUser user =
        (await firebaseAuth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    if (user != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection("users")
          .where("id", isEqualTo: user.uid)
          .getDocuments();
      final List<DocumentSnapshot> document = result.documents;
      if (document.length == 0) {
        //insert the user to our collection
        Firestore.instance.collection("users").document(user.uid).setData({
          "id": user.uid,
          "displayName": user.displayName,
          "profilePicture": user.photoUrl
        });
        await preferences.setString("id", user.uid);
        await preferences.setString("displayName", user.displayName);
        await preferences.setString("profilePicture", user.photoUrl);
      } else {
        await preferences.setString("id", document[0]['id']);
        await preferences.setString("username", document[0]['username']);
        await preferences.setString(
            "profilePicture", document[0]['profilePicture']);
      }
      Fluttertoast.showToast(msg: "Login was successful");
      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => TaskScreen(userid: user.uid,)));
    } else {
      Fluttertoast.showToast(msg: "Login failed");
    }
  }

  void _login() async {
    setState(() {
      loading = true;
    });
    final formData = _globalKey.currentState;

    if (formData.validate()) {
      formData.save();
      try {
        FirebaseUser user = (await _auth.signInWithEmailAndPassword(
            email: _email, password: _password))
            .user;
        assert(user != null);
        if(FirebaseAuth.instance.currentUser() != null){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => TaskScreen(userid: user.uid,)));
          Fluttertoast.showToast(msg: "Login was successful");
         // Provider.of(context).auth.getCurrentUser();
        }
        savePref(user.displayName, _email, user.photoUrl);
        print(preferences.getString('email'));
        print(preferences.getString("displayName"));
      } catch (e) {
        //Go to sign Up
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("The email or Password wrong"),
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
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
   double width = double.infinity;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.red[900],
              Colors.pink[800],
              Colors.purple[400],
              Colors.pinkAccent[100]
            ])),
        child:Stack(
          children: <Widget>[
            Column(
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
                      Container(
                        child: Text(
                          "Login",textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
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
                        key: _globalKey,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 60,
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
                                        decoration: InputDecoration(
                                            hintText: "Email",
                                            suffixIcon: Icon(Icons.email),
                                            hintStyle:
                                            TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                        validator: (val) {
                                          if (val.isEmpty) {
                                            return 'enter your email';
                                          }
                                        },
                                        onSaved: (val) => _email = val,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))),
                                      child: TextFormField(
                                        obscureText: showen,
                                        decoration: InputDecoration(
                                            hintText: "Password",
                                            suffixIcon: IconButton(
                                                icon: showen
                                                    ? Icon(Icons.remove_red_eye)
                                                    : Icon(Icons.panorama_fish_eye),
                                                onPressed: () {
                                                  setState(() {
                                                    if (showen == true) {
                                                      showen = false;
                                                    } else if (showen == false) {
                                                      showen = true;
                                                    }
                                                  });
                                                }),
                                            hintStyle:
                                            TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                        validator: (val) {
                                          if (val.isEmpty) {
                                            return 'enter you password';
                                          }
                                        },
                                        onSaved: (val) => _password = val,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
//                          Text("Forgot Password?", style: TextStyle(color: Colors.grey),),
//                          SizedBox(height: 40,),
                              SizedBox(
                                height: 50,
//                            margin: EdgeInsets.symmetric(horizontal: 20),
                                width: MediaQuery.of(context).size.width,
                                child: RaisedButton(
                                  onPressed: _login,
                                  child: new Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  color: Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(50),
                                      side: BorderSide(color: Colors.blueGrey)),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              SizedBox(
                                height: 50,
//                            margin: EdgeInsets.symmetric(horizontal: 20),
                                width: MediaQuery.of(context).size.width,
                                child: RaisedButton(
                                  onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUp())),
                                  child: new Text(
                                    "Sign Up",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  color: Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(50),
                                      side: BorderSide(color: Colors.blueGrey)),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Divider(),
                              Material(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.red,
                                  elevation: 0.0,
                                  child: MaterialButton(
                                    onPressed: () {
                                      handleLogin();
                                    },
                                    minWidth: MediaQuery.of(context).size.width,
                                    child: Text(
                                      " Google",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22.0,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
        )
      ),
    );
  }
}
