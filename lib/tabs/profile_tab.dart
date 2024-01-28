import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/widgets/app_section_card.dart';
import 'package:dating_app/widgets/profile_basic_info_card.dart';
import 'package:dating_app/widgets/profile_statistics_card.dart';
import 'package:dating_app/widgets/delete_account_button.dart';
import 'package:dating_app/widgets/sign_out_button_card.dart';
import 'package:dating_app/widgets/vip_account_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../dialogs/common_dialogs.dart';
import '../helpers/app_localizations.dart';
import '../screens/delete_account_screen.dart';
import '../screens/sign_in_screen.dart';
import '../utils/colors.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  // Variables
  final _textStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Basic profile info
            const ProfileBasicInfoCard(),

            const SizedBox(height: 10),

            /// Profile Statistics Card
            const ProfileStatisticsCard(),

            const SizedBox(height: 10),

            /// Premium code start
            /*/// Show VIP dialog
            const VipAccountCard(),

            const SizedBox(height: 10),*/
            /// Premium code end

            /// App Section Card
            AppSectionCard(),

            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Account",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left),
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: Text(i18n.translate("sign_out"), style: _textStyle),
                  onTap: () {
                    // Log out button
                    UserModel().signOut().then((_) {
                      /// Go to login screen
                      Future(() {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const SignInScreen()));
                      });
                    });
                  },
                ),
                Divider(
                  indent: 3,
                  height: 1,
                  color: borderColor.withOpacity(0.5),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title:
                  Text(i18n.translate("delete_account"), style: _textStyle),
                  onTap: () async {
                    /// Delete account
                    ///
                    /// Confirm dialog
                    infoDialog(context,
                        icon: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, color: Colors.white),
                        ),
                        title: '${i18n.translate("delete_account")} ?',
                        message: i18n.translate(
                            'all_your_profile_data_will_be_permanently_deleted'),
                        negativeText: i18n.translate("CANCEL"),
                        positiveText: i18n.translate("DELETE"),
                        negativeAction: () => Navigator.of(context).pop(),
                        positiveAction: () async {
                          // Close confirm dialog
                          Navigator.of(context).pop();

                          /// Go to delete account screen
                          Future(() {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => const DeleteAccountScreen()));
                          });
                        });
                  },
                ),
              ],
            ),

            /*/// Sign out button card
            const SignOutButtonCard(),

            const SizedBox(height: 25),
            
            /// Delete Account Button
            const DeleteAccountButton(),

            const SizedBox(height: 25),*/

          ],
        );
      }),
    );
  }
}
