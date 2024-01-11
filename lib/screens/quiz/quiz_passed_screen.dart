import 'package:dating_app/screens/personal_interest_profile/personal_interest_profile_form_screen.dart';
import 'package:dating_app/screens/quiz/quiz_failed_screen.dart';
import 'package:dating_app/screens/quiz/quiz_home_screen.dart';
import 'package:dating_app/screens/quiz/quiz_screen.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../blocked_account_screen.dart';
import '../home_screen.dart';
import '../sign_up_screen.dart';
import '../update_location_sceen.dart';

class QuizPassedScreen extends StatefulWidget {
  const QuizPassedScreen({Key? key}) : super(key: key);

  @override
  _QuizPassedScreenState createState() => _QuizPassedScreenState();
}

class _QuizPassedScreenState extends State<QuizPassedScreen> {
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
                  SvgIcon('assets/images/nerdy_test_passed.svg', width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.width * 0.8),
                  SizedBox(height: 20),
                  Text("Congratulations!", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text("You've aced our Nerdy Quiz and joined the ranks of brainy romantics. Welcome to a world where intellect and charm intertwine!", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      // open QuizScreen
                      UserModel().authUserAccount(
                        updateLocationScreen: () => _nextScreen(const UpdateLocationScreen()),
                        signUpScreen: () => _nextScreen(const SignUpScreen()),
                        homeScreen: () => _nextScreen(const HomeScreen()),
                        blockedScreen: () => _nextScreen(const BlockedAccountScreen()),
                        quizHomeScreen: () => _nextScreen(const QuizHomeScreen()),
                        quizFailedScreen: () => _nextScreen(const QuizFailedScreen()),
                        personalInterestProfileFormScreen: () => _nextScreen(const PersonalInterestProfileFormScreen()),
                      );
                    },
                    child: Text("Let's meet amazing people!"),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }

  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }
}