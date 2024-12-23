import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/utils/helpers.dart';
import 'package:flutter/material.dart';

import '../datas/filter_data.dart';
import '../datas/user.dart';

class MatchesApi {
  /// Get firestore instance
  ///
  final _firestore = FirebaseFirestore.instance;

  /// Save match
  Future<void> _saveMatch({
    required String docUserId,
    required String matchedWithUserId,
  }) async {
    await _firestore
        .collection(C_CONNECTIONS)
        .doc(docUserId)
        .collection(C_MATCHES)
        .doc(matchedWithUserId)
        .set({TIMESTAMP: FieldValue.serverTimestamp()});
  }

  /// Get current user matches
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getMatches() async {
    final QuerySnapshot<Map<String, dynamic>> query = await _firestore
        .collection(C_CONNECTIONS)
        .doc(UserModel().user.userId)
        .collection(C_MATCHES)
        .orderBy(TIMESTAMP, descending: true)
        .get();
    return query.docs;
  }

  /// Delete match
  Future<void> deleteMatch(String matchedUserId) async {
    // Delete match for current user
    await _firestore
        .collection(C_CONNECTIONS)
        .doc(UserModel().user.userId)
        .collection(C_MATCHES)
        .doc(matchedUserId)
        .delete();
    // Delete the current user id from matched user list
    await _firestore
        .collection(C_CONNECTIONS)
        .doc(matchedUserId)
        .collection(C_MATCHES)
        .doc(UserModel().user.userId)
        .delete();
  }

  /// Check if It's Match - when onother user already liked current one
  Future<void> checkMatch(
      {required String userId, required Function(bool) onMatchResult}) async {
    _firestore
        .collection(C_LIKES)
        .where(LIKED_USER_ID, isEqualTo: UserModel().user.userId)
        .where(LIKED_BY_USER_ID, isEqualTo: userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        /// It's Match - show dialog
        onMatchResult(true);

        /// Save match for current user
        await _saveMatch(
          docUserId: UserModel().user.userId,
          matchedWithUserId: userId,
        );

        /// Save match copy for matched user
        await _saveMatch(
          docUserId: userId,
          matchedWithUserId: UserModel().user.userId,
        );
        debugPrint('checkMatch() -> true');
      } else {
        onMatchResult(false);
        debugPrint('checkMatch() -> false');
      }
    }).catchError((e) {
      debugPrint('checkMatch() -> error: $e');
    });
  }

  /// Get user matches
  void getUserMatchesFromFunctions({
    required FilterData? filterData,
    required Function(List<User>) onSuccess,
    required Function(String) onError,
  }) async {
    Map<String, dynamic> _filterData = {};
    if(filterData?.ageRange != null) {
      _filterData.addAll({
        'ageRange': [
          filterData!.ageRange!.start.toInt(),
          filterData.ageRange!.end.toInt()
        ]
      });
    }

    if(filterData?.maxDistance != null) {
      _filterData.addAll({
        'distance': filterData!.maxDistance
      });
    }

    if(filterData?.gender != null) {
      _filterData.addAll({
        'gender': filterData!.gender,
      });
    }

    final result = await FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable('getMatchList').call({
      'filters': _filterData,
    });
    final _response = result.data as Map<String, dynamic>;
    if(_response['success'] == true) {
      final _matches = _response['data'] as List<dynamic>;
      final _matchesList = _matches.map((e) => User.fromDocument(castMap(e))).toList();
      onSuccess(_matchesList);
    } else {
      onError(_response['message'] ?? 'Something went wrong');
    }
  }
}
