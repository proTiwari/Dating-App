import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dating_app/datas/app_info.dart';

import '../datas/filter_data.dart';

class AppModel extends Model {
  // Variables
  late AppInfo appInfo;
  FilterData? discoverFilterData;

  /// Create Singleton factory for [AppModel]
  ///
  static final AppModel _appModel = AppModel._internal();
  factory AppModel() {
    return _appModel;
  }
  AppModel._internal();
  // End

  /// Set data to AppInfo object
  void setAppInfo(Map<String, dynamic> appDoc) {
    appInfo = AppInfo.fromDocument(appDoc);
    notifyListeners();
    debugPrint('AppInfo object -> updated!');
  }

  /// Set data to FilterData object
  FilterData setFilterData(double? maxDistance, RangeValues? ageRange, String? gender) {
    FilterData mFilter = FilterData(maxDistance: maxDistance, ageRange: ageRange, gender: gender);
    discoverFilterData = mFilter;
    notifyListeners();
    debugPrint('FilterData object -> updated!');
    return mFilter;
  }
}
