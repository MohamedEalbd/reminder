import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';


Future<void> setData(String email,String name,String password,String photoUrl,bool google,String accessToken,String idToken) async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  await pref.setString("email", email);
  await pref.setString('displayName', name);
  await pref.setString('photoUrl', photoUrl);
  await pref.setString("password", password);
  await pref.setBool("google",google);
  await pref.setString("accessToken",accessToken);
  await pref.setString("idToken",idToken);
}