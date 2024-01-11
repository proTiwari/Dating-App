import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../constants/constants.dart';
import '../datas/filter_data.dart';
import '../dialogs/show_me_dialog.dart';
import '../helpers/app_localizations.dart';
import '../models/app_model.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';

class BottomSheetFilterDiscoverWidget extends StatefulWidget {
  Function(FilterData?)? onFilterDataChanged;
  BottomSheetFilterDiscoverWidget({super.key, this.onFilterDataChanged});

  @override
  State<StatefulWidget> createState() {
    return _BottomSheetFilterDiscoverWidgetState();
  }
}

class _BottomSheetFilterDiscoverWidgetState extends State<BottomSheetFilterDiscoverWidget> {
  double? _selectedMaxDistance;
  late AppLocalizations _i18n;
  RangeValues? _selectedAgeRange;
  RangeLabels? _selectedAgeRangeLabels;
  String? _gender;

  @override
  void initState() {
    init();
    super.initState();

  }

  void init() {
    FilterData? filterData = AppModel().discoverFilterData;
    // Update variables state
    setState(() {
      // Get user max distance
      _selectedMaxDistance = filterData?.maxDistance;

      // Set range values
      _selectedAgeRange = filterData?.ageRange;
      _gender = filterData?.gender;
    });
  }

  double _getMaxDistance(AppModel model) {
    final Map<String, dynamic> _userSettings = UserModel().user.userSettings!;
    return _selectedMaxDistance ?? model.discoverFilterData?.maxDistance ?? _userSettings[USER_MAX_DISTANCE].toDouble();
  }

  String _getGender(AppModel model) {
    final Map<String, dynamic> _userSettings = UserModel().user.userSettings!;
    return _gender ?? model.discoverFilterData?.gender ?? _userSettings[USER_SHOW_ME] ?? 'Everyone';
  }

  RangeValues _getAgeRangeValues(AppModel model) {
    final Map<String, dynamic> _userSettings = UserModel().user.userSettings!;
    // Get age range
    final double minAge = _selectedAgeRange?.start ?? model.discoverFilterData?.ageRange?.start ?? _userSettings[USER_MIN_AGE].toDouble();
    final double maxAge = _selectedAgeRange?.end ?? model.discoverFilterData?.ageRange?.end ?? _userSettings[USER_MAX_AGE].toDouble();

    // Set range values
    return RangeValues(minAge, maxAge);
  }

  RangeLabels _getAgeRangeLabels(AppModel model) {
    final Map<String, dynamic> _userSettings = UserModel().user.userSettings!;
    // Get age range
    final double minAge = _selectedAgeRange?.start ?? model.discoverFilterData?.ageRange?.start ?? _userSettings[USER_MIN_AGE].toDouble();
    final double maxAge = _selectedAgeRange?.end ?? model.discoverFilterData?.ageRange?.end ?? _userSettings[USER_MAX_AGE].toDouble();

    // Set range values
    return RangeLabels('$minAge', '$maxAge');
  }

  int _getFiltersCount(FilterData? filterData) {
    int count = 0;
    if((_selectedMaxDistance ?? filterData?.maxDistance) != null) {
      count++;
    }

    if((_selectedAgeRange ?? filterData?.ageRange) != null) {
      count++;
    }

    if((_gender ?? filterData?.gender) != null) {
      count++;
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return ScopedModelDescendant(rebuildOnChange: true, builder: (context, child, AppModel model) {
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
                          'Filters ${_getFiltersCount(model.discoverFilterData) > 0 ? '(${_getFiltersCount(model.discoverFilterData)})' : ''}',
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
                            '${_i18n.translate("maximum_distance")} ${_getMaxDistance(model).round()} km',
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
                    value: _getMaxDistance(model),
                    label:
                    _getMaxDistance(model).round().toString() + ' km',
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
                            "${_getAgeRangeValues(model).start.toStringAsFixed(0)} - "
                                "${_getAgeRangeValues(model).end.toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      RangeSlider(
                          activeColor: Theme.of(context).primaryColor,
                          values: _getAgeRangeValues(model),
                          labels: _getAgeRangeLabels(model),
                          divisions: 100,
                          min: 18,
                          max: 100,
                          onChanged: (newRange) {
                            // Update state
                            setState(() {
                              _selectedAgeRange = newRange;
                            });
                            debugPrint('_selectedAgeRange: $_selectedAgeRange');
                          },
                          onChangeEnd: (endValues) {
                            /// Update age range
                            ///
                            /// Get start value
                            /*final int minAge =
                            int.parse(endValues.start.toStringAsFixed(0));

                            /// Get end value
                            final int maxAge =
                            int.parse(endValues.end.toStringAsFixed(0));*/

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
                            _getGender(model),
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
                                return ShowMeDialog(onSavePressManual: (gender) {
                                  setState(() {
                                    _gender = gender;
                                  });
                                },);
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
                    setState(() {
                      _selectedAgeRange = null;
                      _selectedMaxDistance = null;
                      _gender = null;
                    });
                    model.setFilterData(null, null, null);
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
                    FilterData filter = model.setFilterData(_selectedMaxDistance, _selectedAgeRange, _gender);
                    debugPrint('FilterData: ${filter.getAppliedFilterCount()}; ${filter.ageRange.toString()}; ${filter.gender}; ${filter.maxDistance}');
                    if(widget.onFilterDataChanged != null) {
                      widget.onFilterDataChanged!(filter);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Apply ${_getFiltersCount(model.discoverFilterData) > 0 ? '(${_getFiltersCount(model.discoverFilterData)})' : ''}',
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
    });
  }
}
