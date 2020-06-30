import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:reminder/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerApp extends StatefulWidget {
  @override
  _DrawerAppState createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {
  var username;
  var email;
  var mediaUrl;
  bool isSignIn = true;
  @override
  void initState() {
    // TODO: implement initState
    getPref();
    super.initState();
  }

  getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString('displayName');
    email = sharedPreferences.getString('email');
    mediaUrl = sharedPreferences.getString("photoUrl");
    if (username != null) {
      setState(() {
        username = sharedPreferences.getString('displayName');
        email = sharedPreferences.getString('email');
        mediaUrl = sharedPreferences.getString("photoUrl");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.red[900]),
            accountName: isSignIn ? Text(username) :Text(""),
            accountEmail: isSignIn ? Text(email) : Text(""),
            currentAccountPicture: CircleAvatar(
                  backgroundImage:isSignIn ? NetworkImage(mediaUrl):NetworkImage(""),
                ),
          ),
          ListTile(
            title: Text(
              "Update Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            leading: Icon(
              Icons.settings,
              color: Colors.blue,
              size: 25,
            ),
            onTap: () {},
          ),
          Divider(),
          ListTile(
              title: Text(
                "logout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.blue,
                size: 25,
              ),
              onTap: () async {
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.remove("username");
                sharedPreferences.remove("email");
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => LogIn()));
              }),

        ],
      ),
    );
  }
}
