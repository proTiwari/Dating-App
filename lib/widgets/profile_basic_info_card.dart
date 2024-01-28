import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/edit_profile_screen.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/screens/settings_screen.dart';
import 'package:dating_app/widgets/cicle_button.dart';
import 'package:dating_app/widgets/default_card_border.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class ProfileBasicInfoCard extends StatelessWidget {
  const ProfileBasicInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    //
    // Get User Birthday
    final DateTime userBirthday = DateTime(UserModel().user.userBirthYear,
        UserModel().user.userBirthMonth, UserModel().user.userBirthDay);
    // Get User Current Age
    final int userAge = UserModel().calculateUserAge(userBirthday);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ScrollPhysics(),
      child: Card(
        surfaceTintColor: Theme.of(context).primaryColor,
        shape: defaultCardBorder(),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width - 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile image
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 40,
                      backgroundImage:
                          NetworkImage(UserModel().user.userProfilePhoto),
                      onBackgroundImageError: (e, s) => { debugPrint(e.toString()) },
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// Profile details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${UserModel().user.userFullname.split(' ')[0]}, "
                        "${userAge.toString()}",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 5),

                      /// Location
                      Row(
                        children: [
                          SvgIcon("assets/icons/location_point_icon.svg",
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // City
                              Text("${UserModel().user.userLocality},",
                                  style: TextStyle(color: Theme.of(context).primaryColor)),
                              // Country
                              Text(UserModel().user.userCountry,
                                  style: TextStyle(color: Theme.of(context).primaryColor)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 30,
                    child: OutlinedButton.icon(
                        icon: Icon(Icons.remove_red_eye, color: Theme.of(context).primaryColor),
                        label: Text(i18n.translate("view"),
                            style: TextStyle(color: Theme.of(context).primaryColor)),
                        style: ButtonStyle(
                            side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(color: Theme.of(context).primaryColor)),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ))),
                        onPressed: () {
                          /// Go to profile screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                  user: UserModel().user, showButtons: false)));
                        }),
                  ),
                  cicleButton(
                    bgColor: Theme.of(context).primaryColor,
                    padding: 13,
                    icon: const SvgIcon("assets/icons/settings_icon.svg",
                        color: Colors.white, width: 30, height: 30),
                    onTap: () {
                      /// Go to profile settings
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                    },
                  ),
                  SizedBox(
                    height: 35,
                    child: TextButton.icon(
                        icon: const Icon(Icons.edit,
                            color: Colors.white),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ))),
                        label: Text(i18n.translate("edit"),
                            style: const TextStyle(
                                color: Colors.white,)),
                        onPressed: () {
                          /// Go to edit profile screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const EditProfileScreen()));
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
