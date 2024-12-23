import 'package:dating_app/api/dislikes_api.dart';
import 'package:dating_app/api/likes_api.dart';
import 'package:dating_app/api/matches_api.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/its_match_dialog.dart';
import 'package:dating_app/dialogs/report_dialog.dart';
import 'package:dating_app/helpers/app_helper.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/carousel_pro/carousel_pro.dart';
import 'package:dating_app/widgets/custom_badge.dart';
import 'package:dating_app/widgets/cicle_button.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../utils/colors.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  /// Params
  final User user;
  final bool showButtons;
  final bool hideDislikeButton;
  final bool fromDislikesScreen;

  // Constructor
  const ProfileScreen(
      {Key? key,
      required this.user,
      this.showButtons = true,
      this.hideDislikeButton = false,
      this.fromDislikesScreen = false})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Local variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppHelper _appHelper = AppHelper();
  final LikesApi _likesApi = LikesApi();
  final DislikesApi _dislikesApi = DislikesApi();
  final MatchesApi _matchesApi = MatchesApi();
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    // TODO: uncomment the line below if you want to display the Ads
    // Note: before make sure to add your Interstial AD ID
    // AppAdHelper().showInterstitialAd();
  }

  @override
  void dispose() {
    // TODO: uncomment the line below to dispose it.
    // AppAdHelper().disposeInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    //
    // Get User Birthday
    final DateTime userBirthday = DateTime(widget.user.userBirthYear,
        widget.user.userBirthMonth, widget.user.userBirthDay);
    // Get User Current Age
    final int userAge = UserModel().calculateUserAge(userBirthday);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme:
          IconThemeData(color: Theme.of(context).primaryColor),
          actions: <Widget>[
            // Check the current User ID
            if (UserModel().user.userId != widget.user.userId)
              IconButton(
                icon: Icon(Icons.flag,
                    color: Theme.of(context).primaryColor, size: 32),
                // Report/Block profile dialog
                onPressed: () =>
                    ReportDialog(userId: widget.user.userId).show(),
              )
          ],
        ),
        body: ScopedModelDescendant<UserModel>(
            builder: (context, child, userModel) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    /// Carousel Profile images
                    AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Carousel(
                          autoplay: false,
                          dotBgColor: Colors.transparent,
                          dotIncreasedColor: Theme.of(context).primaryColor,
                          images: UserModel()
                              .getUserProfileImages(widget.user)
                              .map((url) => NetworkImage(url))
                              .toList()),
                    ),

                    /// Profile details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Full Name
                              Expanded(
                                child: Text(
                                  '${widget.user.userFullname}, '
                                  '${userAge.toString()}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),

                              /// Show verified badge
                              widget.user.userIsVerified
                                  ? Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      child: Image.asset(
                                          'assets/images/verified_badge.png',
                                          width: 30,
                                          height: 30))
                                  : const SizedBox(width: 0, height: 0),

                              /// Show VIP badge for current user
                              UserModel().user.userId == widget.user.userId &&
                                      UserModel().userIsVip
                                  ? Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      child: Image.asset(
                                          'assets/images/crow_badge.png',
                                          width: 25,
                                          height: 25))
                                  : const SizedBox(width: 0, height: 0),

                              /// Location distance
                              CustomBadge(
                                  icon: const SvgIcon(
                                      "assets/icons/location_point_icon.svg",
                                      color: Colors.white,
                                      width: 15,
                                      height: 15),
                                  text:
                                      '${_appHelper.getDistanceBetweenUsers(userLat: widget.user.userGeoPoint.latitude, userLong: widget.user.userGeoPoint.longitude)} km')
                            ],
                          ),

                          const SizedBox(height: 5),

                          /// Home location
                          _rowProfileInfo(
                            context,
                            icon: const SvgIcon(
                                "assets/icons/location_point_icon.svg",
                                color: Colors.black87,
                                width: 24,
                                height: 24),
                            title: 'Location',
                            value:
                                "${widget.user.userLocality}, ${widget.user.userCountry}",
                          ),

                          const SizedBox(height: 5),

                          /// Height title
                          widget.user.userHeight != null ? _rowProfileInfo(context,
                              icon: const Icon(Icons.height,
                                  color: Colors.black87,
                                  size: 28),
                              title: _i18n.translate('height'),
                              value: widget.user.userHeight.toString()) : Container(),

                          SizedBox(height: widget.user.userHeight != null ? 5 : 0),

                          /// Birthday
                          _rowProfileInfo(context,
                              icon: const SvgIcon("assets/icons/gift_icon.svg",
                                  color: Colors.black87,
                                  width: 28,
                                  height: 28),
                              title: _i18n.translate('birthday'),
                              value:
                                  '${widget.user.userBirthYear}/${widget.user.userBirthMonth}/${widget.user.userBirthDay}'),

                          /// Gender
                          _rowProfileInfo(context,
                              icon: const Icon(Icons.wc,
                                  color: Colors.black87, size: 28),
                              title: _i18n.translate('gender'),
                              value: widget.user.userGender
                          ),

                          /// Join date
                          _rowProfileInfo(context,
                              icon: const SvgIcon("assets/icons/info_icon.svg",
                                  color: Colors.black87,
                                  width: 28,
                                  height: 28),
                              title: _i18n.translate('join_date'),
                              value: timeago.format(widget.user.userRegDate)),

                          const SizedBox(height: 16),
                          const Divider(
                            indent: 3,
                            height: 1,
                            color: borderColor,
                          ),
                          const SizedBox(height: 16),

                          /// Profile bio
                          ListTile(
                            title: Text(_i18n.translate("bio"),
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            subtitle: Text(widget.user.userBio,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.grey)),
                          ),

                          const SizedBox(height: 16),
                          const Divider(
                            indent: 3,
                            height: 1,
                            color: borderColor,
                          ),
                          const SizedBox(height: 16),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text("Personal Interests",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ),

                          widget.user.userPersonalInterests?.dreamPlaces != null ? ListTile(
                            title: const Text("Dream Places",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87)),
                            subtitle: Wrap(
                              children: widget.user.userPersonalInterests!.dreamPlaces.map((interest) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Chip(
                                  label: Text(interest),
                                ),
                              )).toList(),
                            ),
                          ) : Container(),


                          widget.user.userPersonalInterests?.favoriteBooks != null ? ListTile(
                            title: const Text("Favourite Books",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87)),
                            subtitle: Wrap(
                              children: widget.user.userPersonalInterests!.favoriteBooks.map((interest) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Chip(
                                  label: Text(interest),
                                ),
                              )).toList(),
                            ),
                          ) : Container(),

                          widget.user.userPersonalInterests?.favoriteAnimeOrMovies != null ? ListTile(
                            title: const Text("Favourite Anime/Movies",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87)),
                            subtitle: Wrap(
                              children: widget.user.userPersonalInterests!.favoriteAnimeOrMovies.map((interest) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Chip(
                                  label: Text(interest),
                                ),
                              )).toList(),
                            ),
                          ) : Container(),

                          widget.user.userPersonalInterests?.interests != null ? ListTile(
                            title: const Text("Interests",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87)),
                            subtitle: Wrap(
                              children: widget.user.userPersonalInterests!.interests.map((interest) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Chip(
                                  label: Text(interest),
                                ),
                              )).toList(),
                            ),
                          ) : Container(),

                          widget.user.userPersonalInterests?.smokingDrinking != null ? ListTile(
                            title: const Text("Smoke/Drink",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87)),
                            subtitle: Text(widget.user.userPersonalInterests!.smokingDrinking ? "Yes" : "No",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ) : Container(),

                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /*/// AppBar to return back
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme:
                      IconThemeData(color: Theme.of(context).primaryColor),
                  actions: <Widget>[
                    // Check the current User ID
                    if (UserModel().user.userId != widget.user.userId)
                      IconButton(
                        icon: Icon(Icons.flag,
                            color: Theme.of(context).primaryColor, size: 32),
                        // Report/Block profile dialog
                        onPressed: () =>
                            ReportDialog(userId: widget.user.userId).show(),
                      )
                  ],
                ),
              ),*/
            ],
          );
        }),
        bottomNavigationBar:
            widget.showButtons ? _buildButtons(context) : null);
  }

  Widget _rowProfileInfo(BuildContext context,
      {required Widget icon, required String title, required String value}) {
    return ListTile(
      leading: icon,
      title: Text(title,
          style: const TextStyle(fontSize: 18, color: Colors.black87)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }

  /// Build Like and Dislike buttons
  Widget _buildButtons(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            /// Dislike profile button
            if (!widget.hideDislikeButton)
              cicleButton(
                  padding: 8.0,
                  icon:
                      Icon(Icons.close, color: Theme.of(context).primaryColor),
                  bgColor: Colors.grey,
                  onTap: () {
                    // Dislike profile
                    _dislikesApi.dislikeUser(
                        dislikedUserId: widget.user.userId,
                        onDislikeResult: (result) {
                          /// Check result to show message
                          if (!result) {
                            // Show error message
                            showScaffoldMessage(
                                context: context,
                                message: _i18n.translate(
                                    "you_already_disliked_this_profile"));
                          }
                        });
                  }),

            /// Like profile button
            cicleButton(
                padding: 8.0,
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                bgColor: Theme.of(context).primaryColor,
                onTap: () {
                  // Like user
                  _likeUser(context);
                }),
          ],
        ));
  }

  /// Like user function
  Future<void> _likeUser(BuildContext context) async {
    /// Check match first
    _matchesApi
        .checkMatch(
            userId: widget.user.userId,
            onMatchResult: (result) {
              if (result) {
                /// Show It`s match dialog
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return ItsMatchDialog(
                        matchedUser: widget.user,
                        showSwipeButton: false,
                        swipeKey: null,
                      );
                    });
              }
            })
        .then((_) {
      /// Like user
      _likesApi.likeUser(
          likedUserId: widget.user.userId,
          userDeviceToken: widget.user.userDeviceToken,
          nMessage: "${UserModel().user.userFullname.split(' ')[0]}, "
              "${_i18n.translate("liked_your_profile_click_and_see")}",
          onLikeResult: (result) async {
            if (result) {
              // Show success message
              showScaffoldMessage(
                  context: context,
                  message:
                      '${_i18n.translate("like_sent_to")} ${widget.user.userFullname}');
            } else if (!result) {
              // Show error message
              showScaffoldMessage(
                  context: context,
                  message: _i18n.translate("you_already_liked_this_profile"));
            }

            /// Validate to delete disliked user from disliked list
            else if (result && widget.fromDislikesScreen) {
              // Delete in database
              await _dislikesApi.deleteDislikedUser(widget.user.userId);
            }
          });
    });
  }
}
