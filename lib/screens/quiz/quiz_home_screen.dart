import 'package:dating_app/screens/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({Key? key}) : super(key: key);

  @override
  _QuizFailedScreenState createState() => _QuizFailedScreenState();
}

class _QuizFailedScreenState extends State<QuizHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Ready to embark on a quest of intellect and wit? Ace our Nerdy Challenge to unlock the wonders of our unique platform!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // open QuizScreen
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => QuizScreen()));
                  },
                  child: Text("Start Quiz"),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}