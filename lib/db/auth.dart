import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';


abstract class BaseAuth{
  Future<FirebaseUser> googleSignin();
}
class Auth implements BaseAuth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<FirebaseUser> googleSignin() async {
    final GoogleSignIn _googleSignIn = new GoogleSignIn();
    final GoogleSignInAccount googleAccount =await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    try{
      FirebaseUser user = (await _firebaseAuth.signInWithCredential(credential)) as FirebaseUser;
      return user;
    }catch(e){
      print(e.toString());
      return null;
    }
    // TODO: implement googleSignin
  }

}