import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';


class UserService{
  FirebaseDatabase _database =FirebaseDatabase.instance;
  Firestore _firestore =Firestore.instance;
  String ref = "users";
  // String collection = "users";

  creatUser(Map value){
    String id = value["userId"];
    _database.reference().child("$ref / $id").set(
        value
    ).catchError((e) => print(e.toString()));
  }
//   creatUser1(Map data){
//   _firestore.collection(collection).document(data['key']).setData(data);
//   }
Future updateUserDate(){

}
}