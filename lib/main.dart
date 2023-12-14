import 'package:flutter/material.dart';
import 'package:game_of_life/game_of_life.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Of Life',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Game Of Life',
              style: TextStyle(color: Colors.white),
            ),
            toolbarHeight: 30,
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black26,
          body: GameOfLife(board: Board.fromDimensions(20, 30))),
    );
  }
}
