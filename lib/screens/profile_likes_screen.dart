import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/likes_api.dart';
import 'package:dating_app/api/visits_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/vip_dialog.dart';
import 'package:dating_app/helpers/app_helper.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/widgets/build_title.dart';
import 'package:dating_app/widgets/loading_card.dart';
import 'package:dating_app/widgets/no_data.dart';
import 'package:dating_app/widgets/processing.dart';
import 'package:dating_app/widgets/profile_card.dart';
import 'package:dating_app/widgets/users_grid.dart';
import 'package:flutter/material.dart';

class ProfileLikesScreen extends StatefulWidget {
  const ProfileLikesScreen({Key? key}) : super(key: key);

  @override
  _ProfileLikesScreenState createState() => _ProfileLikesScreenState();
}

class _ProfileLikesScreenState extends State<ProfileLikesScreen> {
  // Variables
  final ScrollController _gridViewController = ScrollController();
  final LikesApi _likesApi = LikesApi();
  final VisitsApi _visitsApi = VisitsApi();
  late AppLocalizations _i18n;
  List<DocumentSnapshot<Map<String, dynamic>>>? _likedMeUsers;
  late DocumentSnapshot<Map<String, dynamic>> _userLastDoc;
  bool _loadMore = true;

  /// Load more users
  void _loadMoreUsersListener() async {
    _gridViewController.addListener(() {
      if (_gridViewController.position.pixels ==
          _gridViewController.position.maxScrollExtent) {
        /// Load more users
        if (_loadMore) {
          _likesApi
              .getLikedMeUsers(loadMore: true, userLastDoc: _userLastDoc)
              .then((users) {
            /// Update users list
            if (users.isNotEmpty) {
              _updateUsersList(users);
            } else {
              setState(() => _loadMore = false);
            }
            debugPrint('load more users: ${users.length}');
          });
        } else {
          debugPrint('No more users');
        }
      }
    });
  }

  /// Update list
  void _updateUsersList(List<DocumentSnapshot<Map<String, dynamic>>> users) {
    if (mounted) {
      setState(() {
        _likedMeUsers!.addAll(users);
        if (users.isNotEmpty) {
          _userLastDoc = users.last;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _likesApi.getLikedMeUsers().then((users) {
      // Check result
      if (users.isNotEmpty) {
        if (mounted) {
          setState(() {
            _likedMeUsers = users;
            _userLastDoc = users.last;
          });
        }
      } else {
        setState(() => _likedMeUsers = []);
      }
    });

    /// Listener
    _loadMoreUsersListener();
  }

  @override
  void dispose() {
    _gridViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_i18n.translate("likes"), style: const TextStyle(color: Colors.black87)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              /// Header Title
              BuildTitle(
                svgIconName: "heart_2_icon",
                title: _i18n.translate("users_who_liked_you"),
              ),

              /// Matches
              Expanded(child: _showProfiles())
            ],
          ),
        ));
  }

  /// Show profiles
  Widget _showProfiles() {
    if (_likedMeUsers == null) {
      return Processing(text: _i18n.translate("loading"));
    } else if (_likedMeUsers!.isEmpty) {
      // No data
      return NoData(svgName: 'heart_icon', text: _i18n.translate("no_like"));
    } else {
      /// Show users
      return UsersGrid(
        gridViewController: _gridViewController,
        itemCount: _likedMeUsers!.length + 1,

        /// Workaround for loading more
        itemBuilder: (context, index) {
          /// Validate fake index
          if (index < _likedMeUsers!.length) {
            /// Get user id
            final userId = _likedMeUsers![index][LIKED_BY_USER_ID];

            /// Load profile
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: UserModel().getUser(userId),
                builder: (context, snapshot) {
                  /// Check result
                  if (!snapshot.hasData) {
                    return const LoadingCard();
                  } else if (snapshot.data?.data() == null) {
                    AppHelper().ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _likedMeUsers!.removeAt(index);
                        });
                      }
                    });

                    return const LoadingCard();
                  } else {
                    /// Get user object
                    final User user = User.fromDocument(snapshot.data!.data()!);

                    /// Show user card
                    return GestureDetector(
                      child: ProfileCard(user: user, page: 'require_vip'),
                      onTap: () {
                        /// Check vip account
                        if (UserModel().userIsVip) {
                          /// Go to profile screen - using showDialog to
                          /// prevents reloading getUser FutureBuilder
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return ProfileScreen(
                                    user: user, hideDislikeButton: true);
                              });

                          /// Increment user visits an push notification
                          _visitsApi.visitUserProfile(
                            visitedUserId: user.userId,
                            userDeviceToken: user.userDeviceToken,
                            nMessage:
                                "${UserModel().user.userFullname.split(' ')[0]}, "
                                "${_i18n.translate("visited_your_profile_click_and_see")}",
                          );
                        } else {
                          /// Show VIP dialog
                          showDialog(
                              context: context,
                              builder: (context) => const VipDialog());
                        }
                      },
                    );
                  }
                });
          } else {
            return Container();
          }
        },
      );
    }
  }
}
