// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:socialauth_flutter/provider/internet_provider.dart';
import 'package:socialauth_flutter/provider/sign_in_provider.dart';

import '../utils/config.dart';
import '../utils/snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Image(
                        image: AssetImage(Config.app_icon),
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome to FlutterFirebase",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Learn Authentication with Provider",
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              //  RoundedButton
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedLoadingButton(
                    onPressed: () {
                      handleGoogleSignIn();
                    },
                    controller: googleController,
                    successColor: Colors.green,
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    color: Colors.red,
                    child: Wrap(
                      children: const [
                        Icon(
                          //  Here, i'm using fontAwesomeIcons.
                          FontAwesomeIcons.google,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  //  FaceBook login button.
                  RoundedLoadingButton(
                    onPressed: () {
                      handleFacebookAuth();
                    },
                    controller: facebookController,
                    successColor: Colors.blue,
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    color: Colors.blue,
                    child: Wrap(
                      children: const [
                        Icon(
                          //  Here, i'm using fontAwesomeIcons.
                          FontAwesomeIcons.facebook,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15),
                        Text(
                          "Sign in with Facebook",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Handling Google Sign In.
  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    //  Below is internet provider.
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    if (ip.hasInternet == false) {
      try {
        openSnackBar(context, "Check your internet connection", Colors.red);
        //  Below i'm reseting my buttons bcz let say user have presssed
        //  on any of the button & internet connection get losts, so
        //  following commands will reset the buttons to their default.
        googleController.reset();
      } catch (error) {
        print("It's an Custom error that i'm getting inside login_screen.");
      }
    } else {
      await sp.signInWithGoogle().then(
        (value) {
          //  Here, I'm ensured that sign-in is successful
          if (sp.hasError == true) {
            openSnackBar(context, sp.erroCode.toString(), Colors.red);
            googleController.reset();
          } else {
            //  Here, I'm checking whether user exists or not.
            sp.checkUserExists().then((value) async {
              if (value == true) {
                //  user exists.
                await sp.getUserDataFromFirebase(sp.uid).then(
                      (value) => sp.saveDataToSharedPreferences().then(
                            (value) => sp.setSignIn().then(
                              (value) {
                                googleController.success();
                                handleAfterSignIn();
                              },
                            ),
                          ),
                    );
              } else {
                //  user doesn't exists.
                //  Hence, user does not exist therefore, I am
                //  going to save user data on FireStore along with
                //  saving user information on SharedPreferences.
                sp
                    .saveDataToFirestore()
                    .then((value) => sp.saveDataToSharedPreferences())
                    .then(
                      (value) => sp.setSignIn().then(
                        (value) {
                          googleController.success();
                          handleAfterSignIn();
                          //  Above function would be used by Google, Twitter,
                          //  Facebook and even within Phone authentication.
                        },
                      ),
                    );
              }
            });
          }
        },
      );
    }
  }

  //  Handling Facebook Auth
  Future handleFacebookAuth() async {
    final sp = context.read<SignInProvider>();
    //  Below is internet provider.
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    if (ip.hasInternet == false) {
      openSnackBar(context, "Check your internet connection", Colors.red);
      //  Below i'm reseting my buttons bcz let say user have presssed
      //  on any of the button & internet connection get losts, so
      //  following commands will reset the buttons to their default.
      facebookController.reset();
    } else {
      await sp.signInWithFacebook().then(
        (value) {
          //  Here, I'm ensured that sign-in is successful
          if (sp.hasError == true) {
            openSnackBar(context, sp.erroCode.toString(), Colors.red);
            facebookController.reset();
          } else {
            //  Here, I'm checking whether user exists or not.
            sp.checkUserExists().then((value) async {
              if (value == true) {
                //  user exists.
                await sp.getUserDataFromFirebase(sp.uid).then(
                      (value) => sp.saveDataToSharedPreferences().then(
                            (value) => sp.setSignIn().then(
                              (value) {
                                facebookController.success();
                                handleAfterSignIn();
                              },
                            ),
                          ),
                    );
              } else {
                //  user doesn't exists.
                //  Hence, user does not exist therefore, I am
                //  going to save user data on FireStore along with
                //  saving user information on SharedPreferences.
                sp
                    .saveDataToFirestore()
                    .then((value) => sp.saveDataToSharedPreferences())
                    .then(
                      (value) => sp.setSignIn().then(
                        (value) {
                          facebookController.success();
                          handleAfterSignIn();
                          //  Above function would be used by Google, Twitter,
                          //  Facebook and even within Phone authentication.
                        },
                      ),
                    );
              }
            });
          }
        },
      );
    }
  }

  //  Handle after sign in
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then(
      (value) {},
    );
  }
}
