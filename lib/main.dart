import 'package:flutter/material.dart';
import 'views/decklist.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.amber,
    ),
    home: const DeckList(),
  ));
}
