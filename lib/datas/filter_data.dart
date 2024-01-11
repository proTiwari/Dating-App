import 'package:dating_app/constants/constants.dart';
import 'package:flutter/material.dart';

class FilterData {
  /// Variables
  double? maxDistance;
  RangeValues? ageRange;
  final String? gender;

  /// Constructor
  FilterData(
      {
        this.maxDistance,
        this.ageRange,
        this.gender,
      });

  int getAppliedFilterCount() {
    int count = 0;
    if(gender != null) {
      count++;
    }

    if(ageRange != null) {
      count ++;
    }

    if(maxDistance != null) {
      count ++;
    }

    return count;
  }
}
