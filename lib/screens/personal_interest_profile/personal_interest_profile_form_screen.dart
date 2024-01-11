import 'package:dating_app/constants/constants.dart';
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

class PersonalInterestProfileFormScreen extends StatefulWidget {
  const PersonalInterestProfileFormScreen({Key? key}) : super(key: key);

  @override
  _PersonalInterestProfileFormScreenState createState() => _PersonalInterestProfileFormScreenState();
}

class _PersonalInterestProfileFormScreenState extends State<PersonalInterestProfileFormScreen> {
  int currentPage = 0;
  PageController pageController = PageController();

  TextEditingController _dreamPlaceController = TextEditingController();
  TextEditingController _animeController = TextEditingController();
  TextEditingController _booksController = TextEditingController();

  List<String> _ans1 = [];
  List<String> _ans2 = [];
  List<String> _ans3 = [];
  List<String> _ans4 = [];
  bool? _ans5;

  bool isLoading = false;

  String _getHeadingText() {
    switch(currentPage) {
      case 0:
        return "Favourite Books";
      case 1:
        return "Favourite Anime/Movies/Web Series";
      case 2:
        return "Dream Place";
      case 3:
        return "Interests";
      case 4:
        return "Smoking/Drinking";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*IconButton(
              iconSize: 20,
              icon: Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),*/
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: Text(_getHeadingText(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900))),
                  SizedBox(width: 16,),
                  Text("${currentPage + 1}/5", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
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
                              const Text("List down your favourite books.", style: TextStyle(fontSize: 20)),
                              SizedBox(height: 16,),
                              Row(
                                children: [
                                  Expanded(child: TextFormField(
                                    controller: _booksController,
                                    decoration: InputDecoration(
                                        labelText: 'Enter book name',
                                        hintText: 'Eg: Harry Potter.',
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(Icons.library_books),
                                        )),
                                  ),),
                                  SizedBox(width: 16,),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      color: Colors.white,
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        if(_booksController.text.trim().isNotEmpty) {
                                          setState(() {
                                            _ans1.add(_booksController.text.trim());
                                            _booksController.clear();
                                          });
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 16,),

                              Wrap(
                                children: _ans1.map((dreamPlace) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Chip(
                                    label: Text(dreamPlace),
                                    onDeleted: () {
                                      setState(() {
                                        _ans1.remove(dreamPlace);
                                      });
                                    },
                                  ),
                                )).toList(),
                              ),
                            ]
                            else if(index == 1) ...[
                              const Text("Tell us about your favourite Anime/Movies/Web Series.", style: TextStyle(fontSize: 20)),
                              SizedBox(height: 16,),
                              Row(
                                children: [
                                  Expanded(child: TextFormField(
                                    controller: _animeController,
                                    decoration: InputDecoration(
                                        labelText: 'Enter Anime/Movies/Web Series',
                                        hintText: 'Eg: Naruto, etc.',
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(Icons.movie),
                                        )),
                                  ),),
                                  SizedBox(width: 16,),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      color: Colors.white,
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        if(_animeController.text.trim().isNotEmpty) {
                                          setState(() {
                                            _ans2.add(_animeController.text.trim());
                                            _animeController.clear();
                                          });
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 16,),

                              Wrap(
                                children: _ans2.map((dreamPlace) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Chip(
                                    label: Text(dreamPlace),
                                    onDeleted: () {
                                      setState(() {
                                        _ans2.remove(dreamPlace);
                                      });
                                    },
                                  ),
                                )).toList(),
                              ),
                            ]
                            else if(index == 2) ...[
                                const Text("List down your dream places you want to travel to.", style: TextStyle(fontSize: 20)),
                                SizedBox(height: 16,),
                                Row(
                                  children: [
                                    Expanded(child: TextFormField(
                                      controller: _dreamPlaceController,
                                      decoration: InputDecoration(
                                          labelText: 'Enter Dream Place',
                                          hintText: 'Eg: Paris, France, etc.',
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          prefixIcon: const Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Icon(Icons.place),
                                          )),
                                    ),),
                                    SizedBox(width: 16,),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: IconButton(
                                        color: Colors.white,
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          if(_dreamPlaceController.text.trim().isNotEmpty) {
                                            setState(() {
                                              _ans3.add(_dreamPlaceController.text.trim());
                                              _dreamPlaceController.clear();
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),

                                SizedBox(height: 16,),

                                Wrap(
                                  children: _ans3.map((dreamPlace) => Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Chip(
                                        label: Text(dreamPlace),
                                        onDeleted: () {
                                          setState(() {
                                            _ans3.remove(dreamPlace);
                                          });
                                        },
                                      ),
                                    )).toList(),
                                ),
                              ]
                              else if(index == 3) ...[
                                  const Text("Select the categories you have interest in.", style: TextStyle(fontSize: 20)),
                                  SizedBox(height: 16,),
                                  Wrap(
                                    children: interestCategories.map((interest) => Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: FilterChip(
                                          label: Text(interest),
                                          selected: _ans4.contains(interest),
                                          onSelected: (bool selected) {
                                            setState(() {
                                              if(selected) {
                                                _ans4.add(interest);
                                              }
                                              else {
                                                _ans4.remove(interest);
                                              }
                                            });
                                          },
                                        ),
                                      )).toList(),
                                  ),
                                ]
                                else if(index == 4) ...[
                                    const Text("Do you smoke or drink?", style: TextStyle(fontSize: 20)),
                                    SizedBox(height: 16,),
                                    RadioListTile<bool>(
                                      title: const Text('Yes'),
                                      value: true,
                                      groupValue: _ans5,
                                      onChanged: (bool? value) {
                                        if(value != null) {
                                          setState(() {
                                            _ans5 = value;
                                          });
                                        }
                                      },
                                    ),
                                    RadioListTile<bool>(
                                      title: const Text('No'),
                                      value: false,
                                      groupValue: _ans5,
                                      onChanged: (bool? value) {
                                        if(value != null) {
                                          setState(() {
                                            _ans5 = value;
                                          });
                                        }
                                      },
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

            Map<String, dynamic> data = _getData();

            ScopedModel.of<UserModel>(context, rebuildOnChange: true).updatePersonalInterests(data: data, onSuccess: () {
              UserModel().authUserAccount(
                updateLocationScreen: () => _nextScreen(const UpdateLocationScreen()),
                signUpScreen: () => _nextScreen(const SignUpScreen()),
                homeScreen: () => _nextScreen(const HomeScreen()),
                blockedScreen: () => _nextScreen(const BlockedAccountScreen()),
                quizHomeScreen: () => _nextScreen(const QuizHomeScreen()),
                quizFailedScreen: () => _nextScreen(const QuizFailedScreen()),
                personalInterestProfileFormScreen: () => _nextScreen(const PersonalInterestProfileFormScreen()),
              );
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

  Map<String, dynamic> _getData() {
    return {
      "fav_books": _ans1,
      "fav_anime_movies": _ans2,
      "dream_places": _ans3,
      "interests": _ans4,
      "smoking_drinking": _ans5,
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
      case 0:
        if(_ans1.isNotEmpty) {
          flag = true;
        }
        break;
      case 1:
        if(_ans2.isNotEmpty) {
          flag = true;
        }
        break;
      case 2:
        if(_ans3.isNotEmpty) {
          flag = true;
        }
        break;
      case 3:
        if(_ans4.isNotEmpty) {
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