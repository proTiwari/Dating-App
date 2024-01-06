import 'package:dating_app/screens/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';

class QuizFailedScreen extends StatefulWidget {
  const QuizFailedScreen({Key? key}) : super(key: key);

  @override
  _QuizFailedScreenState createState() => _QuizFailedScreenState();
}

class _QuizFailedScreenState extends State<QuizFailedScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //SvgIcon('assets/images/nerdy_love.svg', width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.width * 0.8),
                  Image.asset('assets/images/nerdy_love2.jpg', width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.width * 0.8),
                  SizedBox(height: 20),
                  Text("Ooops! You failed our nerd assessment.", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text("Take quiz again and ace our Nerdy Challenge to unlock the wonders of our unique platform!", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      // open QuizScreen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => QuizScreen()));
                    },
                    child: Text("Take Quiz Again"),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}