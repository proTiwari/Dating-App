import 'package:flutter/material.dart';

class QuizFailedScreen extends StatefulWidget {
  const QuizFailedScreen({Key? key}) : super(key: key);

  @override
  _QuizFailedScreenState createState() => _QuizFailedScreenState();
}

class _QuizFailedScreenState extends State<QuizFailedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Quiz Failed Screen"),
      ),
    );
  }
}