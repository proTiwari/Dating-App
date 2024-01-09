import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../dialogs/show_me_dialog.dart';
import '../helpers/app_localizations.dart';
import '../models/app_model.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';

class BottomSheetFilterDiscoverWidget extends StatefulWidget {

  BottomSheetFilterDiscoverWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BottomSheetFilterDiscoverWidgetState();
  }
}

class _BottomSheetFilterDiscoverWidgetState extends State<BottomSheetFilterDiscoverWidget> {
  late double _selectedMaxDistance;
  late AppLocalizations _i18n;
  late RangeValues _selectedAgeRange;
  late RangeLabels _selectedAgeRangeLabels;

  @override
  void initState() {
    initUserSettings();
    super.initState();

  }

  void initUserSettings() {
    // Get user settings
    final Map<String, dynamic> _userSettings = UserModel().user.userSettings!;
    // Update variables state
    setState(() {
      // Get user max distance
      _selectedMaxDistance = _userSettings[USER_MAX_DISTANCE].toDouble();

      // Get age range
      final double minAge = _userSettings[USER_MIN_AGE].toDouble();
      final double maxAge = _userSettings[USER_MAX_AGE].toDouble();

      // Set range values
      _selectedAgeRange = RangeValues(minAge, maxAge);
      _selectedAgeRangeLabels = RangeLabels('$minAge', '$maxAge');

    });
  }

  String _showMeOption(AppLocalizations i18n) {
    // Variables
    final Map<String, dynamic> settings = UserModel().user.userSettings!;
    final String? showMe = settings[USER_SHOW_ME];
    // Check option

    return showMe ?? i18n.translate("everyone");
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.height * 0.65, maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'Filter',
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                  ),
                  SizedBox(width: 8,),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                      child: Icon(Icons.close, color: Colors.red)),
                ],
              ),
            ),
          ),
          SizedBox(height: 16,),
          Divider(
            indent: 3,
            height: 1,
            color: borderColor.withOpacity(0.5),
          ),
          SizedBox(height: 16,),
          Expanded(child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          '${_i18n.translate("maximum_distance")} ${_selectedMaxDistance.round()} km',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 3),
                      Text(
                          _i18n.translate(
                              "show_people_within_this_radius"),
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Slider(
                  activeColor: Theme.of(context).primaryColor,
                  value: _selectedMaxDistance,
                  label:
                  _selectedMaxDistance.round().toString() + ' km',
                  divisions: 100,
                  min: 0,

                  /// Check User VIP Account to set max distance available
                  /*max: UserModel().userIsVip
                      ? AppModel().appInfo.vipAccountMaxDistance
                      : AppModel().appInfo.freeAccountMaxDistance,*/
                  max: AppModel().appInfo.vipAccountMaxDistance,
                  onChanged: (radius) {
                    setState(() {
                      _selectedMaxDistance = radius;
                    });
                    // debug
                    debugPrint('_selectedMaxDistance: '
                        '${radius.toStringAsFixed(2)}');
                  },
                  onChangeEnd: (radius) {
                    /// Update user max distance
                    UserModel().updateUserData(
                        userId: UserModel().user.userId,
                        data: {
                          '$USER_SETTINGS.$USER_MAX_DISTANCE':
                          double.parse(radius.toStringAsFixed(2))
                        }).then((_) {
                      debugPrint(
                          'User max distance updated -> ${radius.toStringAsFixed(2)}');
                    });
                  },
                ),
                const SizedBox(height: 16),
                Divider(
                  indent: 3,
                  height: 1,
                  color: borderColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(_i18n.translate("age_range"),
                          style: const TextStyle(fontSize: 18)),
                      subtitle: Text(
                          _i18n.translate("show_people_within_this_age_range")),
                      trailing: Text(
                          "${_selectedAgeRange.start.toStringAsFixed(0)} - "
                              "${_selectedAgeRange.end.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    RangeSlider(
                        activeColor: Theme.of(context).primaryColor,
                        values: _selectedAgeRange,
                        labels: _selectedAgeRangeLabels,
                        divisions: 100,
                        min: 18,
                        max: 100,
                        onChanged: (newRange) {
                          // Update state
                          setState(() {
                            _selectedAgeRange = newRange;
                            _selectedAgeRangeLabels = RangeLabels(
                                newRange.start.toStringAsFixed(0),
                                newRange.end.toStringAsFixed(0));
                          });
                          debugPrint('_selectedAgeRange: $_selectedAgeRange');
                        },
                        onChangeEnd: (endValues) {
                          /// Update age range
                          ///
                          /// Get start value
                          final int minAge =
                          int.parse(endValues.start.toStringAsFixed(0));

                          /// Get end value
                          final int maxAge =
                          int.parse(endValues.end.toStringAsFixed(0));

                          // Update age range
                          UserModel().updateUserData(
                              userId: UserModel().user.userId,
                              data: {
                                '$USER_SETTINGS.$USER_MIN_AGE': minAge,
                                '$USER_SETTINGS.$USER_MAX_AGE': maxAge,
                              }).then((_) {
                            debugPrint('Age range updated');
                          });
                        }),
                    SizedBox(height: 16,),
                    Divider(
                      indent: 3,
                      height: 1,
                      color: borderColor.withOpacity(0.5),
                    ),
                    SizedBox(height: 16,),
                    ListTile(
                      leading: Icon(
                        Icons.wc_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                      title: Text(_i18n.translate('gender'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text('Choose gender to filter on'),
                      trailing: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: Text(
                          _showMeOption(_i18n),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        /// Choose Show me option
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return const ShowMeDialog();
                            });
                      },
                    ),
                  ],
                ),
              ],
            ),
          )),
          SizedBox(height: 16,),
          Divider(
            indent: 3,
            height: 1,
            color: borderColor.withOpacity(0.5),
          ),
          SizedBox(height: 16,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
