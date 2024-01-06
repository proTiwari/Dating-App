import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/quiz/quiz_failed_screen.dart';
import 'package:dating_app/screens/quiz/quiz_home_screen.dart';
import 'package:dating_app/screens/quiz/quiz_passed_screen.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../blocked_account_screen.dart';
import '../home_screen.dart';
import '../sign_up_screen.dart';
import '../update_location_sceen.dart';

enum AttractivePersonalityType {
  dressingSense,
  looks,
  intellect,
  empathy,
  humour,
}

enum EntertainmentType {
  anime,
  movies,
  webSeries,
  documentaries,
}

extension AttractivePersonalityTypeExtension on AttractivePersonalityType {
  String get name {
    switch (this) {
      case AttractivePersonalityType.dressingSense:
        return "Dressing Sense";
      case AttractivePersonalityType.looks:
        return "Looks";
      case AttractivePersonalityType.intellect:
        return "Intellect";
      case AttractivePersonalityType.empathy:
        return "Empathy";
      case AttractivePersonalityType.humour:
        return "Humour";
      default:
        return "";
    }
  }
}

extension EntertainmentTypeExtension on EntertainmentType {
  String get name {
    switch (this) {
      case EntertainmentType.anime:
        return "Anime";
      case EntertainmentType.movies:
        return "Movies";
      case EntertainmentType.webSeries:
        return "Web Series";
      case EntertainmentType.documentaries:
        return "Documentaries";
      default:
        return "";
    }
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentPage = 0;
  PageController pageController = PageController();

  bool? _ans1;
  EntertainmentType? _ans2;
  AttractivePersonalityType? _ans3;
  int? _ans4;
  int? _ans5;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              iconSize: 20,
              icon: Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('Quiz', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Text("${currentPage + 1}/5", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PageView.builder(
                    itemCount: 5,
                    controller: pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(index == 0) ...[
                              const Text("Are you a reader?", style: TextStyle(fontSize: 20)),
                              SizedBox(height: 16,),
                              RadioListTile<bool>(
                                title: const Text('Yes'),
                                value: true,
                                groupValue: _ans1,
                                onChanged: (bool? value) {
                                  if(value != null) {
                                    setState(() {
                                      _ans1 = value;
                                      currentPage++;
                                    });
                                    pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                                  }
                                },
                              ),
                              RadioListTile<bool>(
                                title: const Text('No'),
                                value: false,
                                groupValue: _ans1,
                                onChanged: (bool? value) {
                                  if(value != null) {
                                    setState(() {
                                      _ans1 = value;
                                      currentPage++;
                                    });
                                    pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                                  }
                                },
                              ),
                            ]
                            else if(index == 1) ...[
                              const Text("What is your favorite type of entertainment to watch?", style: TextStyle(fontSize: 20)),
                              SizedBox(height: 16,),
                              ...EntertainmentType.values.map((e) => RadioListTile<EntertainmentType>(
                                title: Text(e.name),
                                value: e,
                                groupValue: _ans2,
                                onChanged: (EntertainmentType? value) {
                                  if(value != null) {
                                    setState(() {
                                      _ans2 = value;
                                      currentPage++;
                                    });
                                    pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                                  }
                                },
                              )).toList(),
                            ]
                            else if(index == 2) ...[
                                const Text("What in a person attracts you the most?", style: TextStyle(fontSize: 20)),
                                SizedBox(height: 16,),
                                ...AttractivePersonalityType.values.map((e) => RadioListTile<AttractivePersonalityType>(
                                  title: Text(e.name),
                                  value: e,
                                  groupValue: _ans3,
                                  onChanged: (AttractivePersonalityType? value) {
                                    if(value != null) {
                                      setState(() {
                                        _ans3 = value;
                                        currentPage++;
                                      });
                                      pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                                    }
                                  },
                                )).toList(),
                            ]
                              else if(index == 3) ...[
                                const Text("How would you rate your communication skills out of 10?", style: TextStyle(fontSize: 20)),
                                  SizedBox(height: 16,),
                                  Slider(
                                    value: _ans4?.toDouble() ?? 0,
                                    min: 0,
                                    max: 10,
                                    divisions: 10,
                                    label: _ans4?.round().toString(),
                                    onChanged: (double value) {
                                      setState(() {
                                        _ans4 = value.round();
                                      });
                                    },
                                  ),
                                ]
                                else if(index == 4) ...[
                                    const Text("How many relationships have you had in the past?", style: TextStyle(fontSize: 20)),
                                    SizedBox(height: 16,),
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _ans5 = int.tryParse(value);
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Number of relationships",
                                      ),
                                    ),
                                  ]
                          ],
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: showNext() ? FloatingActionButton(
        onPressed: isLoading ? null : () {
          if(currentPage == 4) {
            setState(() {
              isLoading = true;
            });

            Map<String, dynamic> quizData = _getQuizData(_ans1!, _ans2!, _ans3!, _ans4!, _ans5!);

            ScopedModel.of<UserModel>(context, rebuildOnChange: true).updateQuizAnswers(quizData: quizData, onSuccess: () {
              _nextScreen(quizData["passed"] ? QuizPassedScreen() : QuizFailedScreen());
            }, onFail: (error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              setState(() {
                isLoading = false;
              });
            });
          }
          else {
            pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
            setState(() {
              currentPage++;
            });
          }
        },
        child: isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white,),) : const Icon(Icons.arrow_forward, color: Colors.white,),
      ) : null,
    );
  }

  Map<String, dynamic> _getQuizData(bool ans1, EntertainmentType ans2, AttractivePersonalityType ans3, int ans4, int ans5) {
    int score = 0;
    if(ans1) {
      score += 1;
    }

    if(ans2 == EntertainmentType.anime || ans2 == EntertainmentType.webSeries || ans2 == EntertainmentType.documentaries) {
      score += 1;
    }

    if(ans3 == AttractivePersonalityType.empathy || ans3 == AttractivePersonalityType.intellect || ans3 == AttractivePersonalityType.humour) {
      score += 1;
    }

    if(ans4 <= 7) {
      score += 1;
    }

    if(ans5 < 2) {
      score += 1;
    }

    return {
      "ans1": ans1,
      "ans2": ans2.name,
      "ans3": ans3.name,
      "ans4": ans4,
      "ans5": ans5,
      "score": score,
      "passed": score >= 2,
    };
  }

  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  bool showNext() {
    bool flag = false;
    switch(currentPage) {
      case 3:
        if(_ans4 != null) {
          flag = true;
        }
        break;
      case 4:
        if(_ans5 != null) {
          flag = true;
        }
        break;

    }
    return flag;
  }

}