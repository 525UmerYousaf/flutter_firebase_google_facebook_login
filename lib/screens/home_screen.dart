import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './login_screen.dart';
import './next_screen.dart';
import '../provider/sign_in_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  //  Reason for initState here is whenever home screen is
  //  loaded I need to fetch data of user from SharedPreferences
  //  instead of Cloud FireStore bcz I've stored my data.
  @override
  void initState() {
    super.initState();
    getData();
  }

  //  Here, I would sign out whether everything is working fine
  //  or not, and show user profile information.
  @override
  Widget build(BuildContext context) {
    //  Reason, why I does not use "read" below is bcz "watch"
    //  helps me to read same data again and again unless like
    //  read. With "watch" I'm watching everything that has
    //  been changing in the data.
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage("${sp.imageUrl}"),
              radius: 50,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome ${sp.name}",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text("${sp.email}",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text("${sp.uid}",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Provider: "),
                const SizedBox(width: 5),
                Text(
                  "${sp.provider}".toUpperCase(),
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                sp.userSignOut();
                nextScreenReplace(context, const LoginScreen());
              },
              child: const Text(
                "Sign out",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
