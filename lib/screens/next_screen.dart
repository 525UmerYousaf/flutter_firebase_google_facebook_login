import 'package:flutter/material.dart';

void nextScreenReplace(context, page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}
