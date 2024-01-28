import 'package:dating_app/api/dislikes_api.dart';
import 'package:dating_app/api/likes_api.dart';
import 'package:dating_app/api/matches_api.dart';
import 'package:dating_app/api/visits_api.dart';
import 'package:dating_app/components/bottom_sheet_filter_discover.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/its_match_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/app_model.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:dating_app/screens/disliked_profile_screen.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/widgets/cicle_button.dart';
import 'package:dating_app/widgets/no_data.dart';
import 'package:dating_app/widgets/processing.dart';
import 'package:dating_app/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/api/users_api.dart';
import 'package:scoped_model/scoped_model.dart';

import '../datas/filter_data.dart';
import '../utils/colors.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({Key? key}) : super(key: key);

  @override
  DiscoverTabState createState() => DiscoverTabState();
}

class DiscoverTabState extends State<DiscoverTab> {
  // Variables
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();
  final LikesApi _likesApi = LikesApi();
  final DislikesApi _dislikesApi = DislikesApi();
  final MatchesApi _matchesApi = MatchesApi();
  final VisitsApi _visitsApi = VisitsApi();
  final UsersApi _usersApi = UsersApi();
  List<User>? _users;
  bool isLoading = false;
  late AppLocalizations _i18n;

  /// Get all Users
  Future<void> loadUsers(FilterData? filterData) async {
    setState(() {
      isLoading = true;
    });
    _matchesApi.getUserMatchesFromFunctions(filterData: filterData, onSuccess: (matches) {
      if (matches.isNotEmpty) {
        if (mounted) {
          setState(() {
            _users = matches;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _users = [];
            isLoading = false;
          });
        }
      }
    }, onError: (e) {
      debugPrint('getUserMatchesFromFunctions() -> error: $e');
      setState(() {
        _users = [];
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadUsers(AppModel().discoverFilterData);
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Divider(
          indent: 3,
          height: 1,
          color: borderColor.withOpacity(0.5),
        ),
      ),
      _showUsers(),

    ],);
  }

  Widget _showUsers() {
    /// Check result
    if (_users == null || isLoading) {
      return Processing(text: _i18n.translate("loading"));
    } else if (_users!.isEmpty) {
      /// No user found
      return NoData(
          svgName: 'search_icon',
          text: _i18n
              .translate("no_user_found_around_you_please_try_again_later"));
    } else {
      return Expanded(
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// User card list
            SwipeStack(
                key: _swipeKey,
                children: _users!.map((user) {
                  // Get User object
                  // Return user profile
                  return SwiperItem(
                      builder: (SwiperPosition position, double progress) {
                    /// Return User Card
                    return ProfileCard(
                        page: 'discover', position: position, user: user);
                  });
                }).toList(),
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                translationInterval: 6,
                scaleInterval: 0.03,
                stackFrom: StackFrom.None,
                onEnd: () => debugPrint("onEnd"),
                onSwipe: (int index, SwiperPosition position) {
                  /// Control swipe position
                  switch (position) {
                    case SwiperPosition.None:
                      break;
                    case SwiperPosition.Left:

                      /// Swipe Left Dislike profile
                      _dislikesApi.dislikeUser(
                          dislikedUserId: _users![index].userId,
                          onDislikeResult: (r) =>
                              debugPrint('onDislikeResult: $r'));

                      break;

                    case SwiperPosition.Right:

                      /// Swipe right and Like profile
                      _likeUser(context, clickedUserDoc: _users![index]);

                      break;
                  }
                }),

            /// Swipe buttons
            Container(
                margin: const EdgeInsets.only(bottom: 34),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: swipeButtons(context),
                )),
          ],
        ),
      );
    }
  }

  /// Build swipe buttons
  Widget swipeButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Rewind profiles
        ///
        /// Go to Disliked Profiles
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: const Icon(Icons.restore, size: 22, color: Colors.grey),
            onTap: () {
              // Go to Disliked Profiles Screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DislikedProfilesScreen()));
            }),

        const SizedBox(width: 20),

        /// Swipe left and reject user
        cicleButton(
            bgColor: lightRedColor,
            padding: 10,
            icon: const Icon(Icons.close, size: 31, color: redColor),
            onTap: () {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Swipe left
                _swipeKey.currentState!.swipeLeft();
              }
            }),

        const SizedBox(width: 20),

        /// Swipe right and like user
        cicleButton(
            bgColor: lightGrassGreenColor,
            padding: 10,
            icon: const Icon(Icons.favorite, size: 31, color: grassGreenColor),
            onTap: () async {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Swipe right
                _swipeKey.currentState!.swipeRight();
              }
            }),

        const SizedBox(width: 20),

        /// Go to user profile
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: const Icon(Icons.remove_red_eye, size: 22, color: Colors.grey),
            onTap: () {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Get User object
                final User user = _users![cardIndex];

                /// Go to profile screen
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(user: user, showButtons: false)));

                /// Increment user visits an push notification
                _visitsApi.visitUserProfile(
                  visitedUserId: user.userId,
                  userDeviceToken: user.userDeviceToken,
                  nMessage: "${UserModel().user.userFullname.split(' ')[0]}, "
                      "${_i18n.translate("visited_your_profile_click_and_see")}",
                );
              }
            }),
      ],
    );
  }

  /// Like user function
  Future<void> _likeUser(BuildContext context,
      {required User clickedUserDoc}) async {
    /// Check match first
    await _matchesApi.checkMatch(
        userId: clickedUserDoc.userId,
        onMatchResult: (result) {
          if (result) {
            /// It`s match - show dialog to ask user to chat or continue playing
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return ItsMatchDialog(
                    swipeKey: _swipeKey,
                    matchedUser: clickedUserDoc,
                  );
                });
          }
        });

    /// like profile
    await _likesApi.likeUser(
        likedUserId: clickedUserDoc.userId,
        userDeviceToken: clickedUserDoc.userDeviceToken,
        nMessage: "${UserModel().user.userFullname.split(' ')[0]}, "
            "${_i18n.translate("liked_your_profile_click_and_see")}",
        onLikeResult: (result) {
          debugPrint('likeResult: $result');
        });
  }
}
