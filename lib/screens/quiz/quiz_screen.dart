import 'package:dating_app/models/user_model.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart';

enum AttractivePersonalityType {
  dressingSense,
  looks,
  intellect,
  empathy,
  humour,
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

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentPage = 0;
  PageController pageController = PageController();

  bool? _ans1;
  bool? _ans2;
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
                              const Text("Do you like to read?", style: TextStyle(fontSize: 20)),
                              SizedBox(height: 16,),
                              RadioListTile<bool>(
                                title: const Text('Yes'),
                                value: true,
                                groupValue: _ans1,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _ans1 = value;
                                  });
                                },
                              ),
                              RadioListTile<bool>(
                                title: const Text('No'),
                                value: false,
                                groupValue: _ans1,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _ans1 = value;
                                  });
                                },
                              ),
                            ]
                            else if(index == 1) ...[
                              const Text("Do you like anime?", style: TextStyle(fontSize: 20)),
                              SizedBox(height: 16,),
                              RadioListTile<bool>(
                                title: const Text('Yes'),
                                value: true,
                                groupValue: _ans2,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _ans2 = value;
                                  });
                                },
                              ),
                              RadioListTile<bool>(
                                title: const Text('No'),
                                value: false,
                                groupValue: _ans2,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _ans2 = value;
                                  });
                                },
                              ),
                            ]
                            else if(index == 2) ...[
                                const Text("What in a person attracts you the most?", style: TextStyle(fontSize: 20)),
                                SizedBox(height: 16,),
                                ...AttractivePersonalityType.values.map((e) => RadioListTile<AttractivePersonalityType>(
                                  title: Text(e.name),
                                  value: e,
                                  groupValue: _ans3,
                                  onChanged: (AttractivePersonalityType? value) {
                                    setState(() {
                                      _ans3 = value;
                                    });
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
        onPressed: () {
          if(currentPage == 4) {
            setState(() {
              isLoading = true;
            });
            UserModel().updateQuizAnswers(quizData: {
              "ans1": _ans1,
              "ans2": _ans2,
              "ans3": _ans3?.name,
              "ans4": _ans4,
              "ans5": _ans5,
              "passed": true,
            }, onSuccess: () {
              _nextScreen(const HomeScreen());
              setState(() {
                isLoading = false;
              });
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
        child: const Icon(Icons.arrow_forward, color: Colors.white,),
      ) : null,
    );
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
      case 0:
        if(_ans1 != null) {
          flag = true;
        }
        break;
      case 1:
        if(_ans2 != null) {
          flag = true;
        }
        break;
      case 2:
        if(_ans3 != null) {
          flag = true;
        }
        break;
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