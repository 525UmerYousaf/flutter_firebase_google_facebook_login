// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SignInProvider extends ChangeNotifier {
  //  Instance of FirebaseAuth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //  Below I have created an sign-in instance for my app.
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //  Below I have created instance for hasError, errorCode, provider,
  //  also includes:  uid, email, name, imageUrl.
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get erroCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _name;
  String? get name => _name;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    //  Whenever user sign in with any option i'm storing user
    //  status with help of following property
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  //  Below I'm checking if user has successfully signed in
  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  //  Sign in with google.com
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // Here, I will execute my authentication.
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          //  Here, i would get my access token.
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        //  Sigining to Firebase user instance.
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        //  below I'm saving all values i'm getting in user instance
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        //  below is custom value we will be storing in user instance
        _provider = "Google";
        _uid = userDetails.uid;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider.";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  //  Sign in with facebook.com
  Future signInWithFacebook() async {
    //  When I check official documentation of Facebook authentication
    //  then, there I found that I required an Facebook Auth result.
    final LoginResult result = await facebookAuth.login();
    //  Below I'm getting the user profile.
    //  Below is graphQL command to get profile image from Facebook bcz
    //  it is not available freely to us by Facebook.
    final graphResponse = await http.get(
      Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${result.accessToken!.token}'),
    );
    //  After fetching picture now I can fetch the response.
    final profile = jsonDecode(graphResponse.body);

    if (result.status == LoginStatus.success) {
      try {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await firebaseAuth.signInWithCredential(credential);
        //  Below I'm saving the value.
        _name = profile['name'];
        _email = profile['email'];
        _imageUrl = profile['picture']['data']['url'];
        _uid = profile['id'];
        _hasError = false;
        _provider = "FACEBOOK";
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider.";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('name', _name!);
    await s.setString('email', _email!);
    await s.setString('uid', _uid!);
    await s.setString('image_url', _imageUrl!);
    await s.setString('provider', _provider!);
    notifyListeners();
  }

  //  Below I'm getting my data from SharedPreferences.
  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _name = s.getString("name");
    _email = s.getString("email");
    _imageUrl = s.getString("image_url");
    _uid = s.getString("uid");
    _provider = s.getString("provider");
    notifyListeners();
  }

  //  Below i'm checking inside my cloudFireStore whether user exists or not.
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("Existing User.");
      return true;
    } else {
      print("New User.");
      return false;
    }
  }

  //  Entry For Firebase Cloud Firestore
  Future getUserDataFromFirebase(uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).get().then(
          (DocumentSnapshot snapshot) => {
            _uid = snapshot['uid'],
            _name = snapshot['name'],
            _email = snapshot['email'],
            _imageUrl = snapshot['image_url'],
            _provider = snapshot['provider'],
          },
        );
  }

  Future saveDataToFirestore() async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection("users").doc(uid);
    await reference.set({
      "name": _name,
      "email": _email,
      "uid": _uid,
      "image_url": _imageUrl,
      "provider": _provider,
    });
    notifyListeners();
  }

  //  Below is user sign-out method.
  Future userSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    _isSignedIn = false;
    notifyListeners();
    //  Below i'm clearing my storage information of SharedPreferences.
    clearStoreData();
  }

  Future clearStoreData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }
}
