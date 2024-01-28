import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/disliked_profile_screen.dart';
import 'package:dating_app/screens/profile_likes_screen.dart';
import 'package:dating_app/screens/profile_visits_screen.dart';
import 'package:dating_app/utils/colors.dart';
import 'package:dating_app/widgets/default_card_border.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class ProfileStatisticsCard extends StatelessWidget {
  // Text style
  final _textStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  const ProfileStatisticsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    
    return Column(
      children: [
        Card(
          shape: defaultCardBorder().copyWith(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          surfaceTintColor: grassGreenColor,
          child: ListTile(
            leading: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: grassGreenColor.withAlpha(60),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite, color: grassGreenColor),
                ),
            title: Text(UserModel().user.userTotalLikes.toString(), style: _textStyle.copyWith(fontSize: 30.0, fontWeight: FontWeight.w900)),
            subtitle: Text(i18n.translate('LIKES'), style: _textStyle.copyWith(fontSize: 16.0, color: Colors.black54)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.black54),
            onTap: () {
              /// Go to profile likes screen
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ProfileLikesScreen()));
            },
          ),
        ),
        Card(
          shape: defaultCardBorder().copyWith(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          surfaceTintColor: blueColor,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: blueColor.withAlpha(60),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove_red_eye, color: blueColor)
            ),
            title: Text(UserModel().user.userTotalVisits.toString(), style: _textStyle.copyWith(fontSize: 30.0, fontWeight: FontWeight.w900)),
            subtitle: Text(i18n.translate("VISITS"), style: _textStyle.copyWith(fontSize: 16.0, color: Colors.black54)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.black54),
            onTap: () {
              /// Go to profile visits screen
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ProfileVisitsScreen()));
            },
          ),
        ),
        Card(
          shape: defaultCardBorder().copyWith(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          surfaceTintColor: yellowColor,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: yellowColor.withAlpha(60),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.thumb_down, color: yellowColor),
            ),
            title: Text(UserModel().user.userTotalDisliked.toString(), style: _textStyle.copyWith(fontSize: 30.0, fontWeight: FontWeight.w900)),
            subtitle: Text(i18n.translate("DISLIKED_PROFILES"), style: _textStyle.copyWith(fontSize: 16.0, color: Colors.black54)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.black54),
            onTap: () {
              /// Go to disliked profile screen
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const DislikedProfilesScreen()));
            },
          ),
        )
      ],
    );
  }

  Widget _counter(BuildContext context, int value) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, //.withAlpha(85),
          shape: BoxShape.circle),
      padding: const EdgeInsets.all(6.0),
      child: Text(value.toString(), style: const TextStyle(color: Colors.white)));
  }
}
