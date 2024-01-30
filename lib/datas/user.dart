import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/constants/constants.dart';

class User {
  /// User info
  final String userId;
  final String userProfilePhoto;
  final String userFullname;
  final String userGender;
  final int userBirthDay;
  final int userBirthMonth;
  final int userBirthYear;
  final String userSchool;
  final String userJobTitle;
  final String userBio;
  final String userPhoneNumber;
  final String userEmail;
  final double? userHeight;
  final String userCountry;
  final String userLocality;
  final GeoPoint userGeoPoint;
  final String userStatus;
  final bool userIsVerified;
  final String userLevel;
  final DateTime userRegDate;
  final DateTime userLastLogin;
  final String userDeviceToken;
  final int userTotalLikes;
  final int userTotalVisits;
  final int userTotalDisliked;
  final Map<String, dynamic>? userGallery;
  final Map<String, dynamic>? userSettings;
  final UserPersonalInterests? userPersonalInterests;

  // Constructor
  User({
    required this.userId,
    required this.userProfilePhoto,
    required this.userFullname,
    required this.userGender,
    required this.userBirthDay,
    required this.userBirthMonth,
    required this.userBirthYear,
    required this.userSchool,
    required this.userJobTitle,
    required this.userBio,
    required this.userPhoneNumber,
    required this.userEmail,
    required this.userGallery,
    required this.userCountry,
    required this.userLocality,
    required this.userGeoPoint,
    required this.userSettings,
    required this.userStatus,
    required this.userLevel,
    required this.userIsVerified,
    required this.userRegDate,
    required this.userLastLogin,
    required this.userDeviceToken,
    required this.userTotalLikes,
    required this.userTotalVisits,
    required this.userTotalDisliked,
    required this.userHeight,
    this.userPersonalInterests,
  });

  /// factory user object
  factory User.fromDocument(Map<String, dynamic> doc) {
    return User(
      userId: doc[USER_ID],
      userProfilePhoto: doc[USER_PROFILE_PHOTO],
      userFullname: doc[USER_FULLNAME],
      userGender: doc[USER_GENDER],
      userBirthDay: doc[USER_BIRTH_DAY],
      userBirthMonth: doc[USER_BIRTH_MONTH],
      userBirthYear: doc[USER_BIRTH_YEAR],
      userSchool: doc[USER_SCHOOL] ?? '',
      userJobTitle: doc[USER_JOB_TITLE] ?? '',
      userBio: doc[USER_BIO] ?? '',
      userPhoneNumber: doc[USER_PHONE_NUMBER] ?? '',
      userEmail: doc[USER_EMAIL] ?? '',
      userGallery: doc[USER_GALLERY],
      userCountry: doc[USER_COUNTRY] ?? '',
      userLocality: doc[USER_LOCALITY] ?? '',
      userGeoPoint: doc[USER_GEO_POINT]['geopoint'] is GeoPoint
          ? doc[USER_GEO_POINT]['geopoint']
          : GeoPoint(doc[USER_GEO_POINT]['geopoint']['_latitude'] ?? 0, doc[USER_GEO_POINT]['geopoint']['_longitude'] ?? 0),
      userSettings: doc[USER_SETTINGS],
      userStatus: doc[USER_STATUS],
      userIsVerified: doc[USER_IS_VERIFIED] ?? false,
      userLevel: doc[USER_LEVEL],
      userRegDate: doc[USER_REG_DATE] is Timestamp ? doc[USER_REG_DATE].toDate() : Timestamp(doc[USER_REG_DATE]['_seconds'], doc[USER_REG_DATE]['_nanoseconds']).toDate(), // Firestore Timestamp
      userLastLogin: doc[USER_LAST_LOGIN] is Timestamp ? doc[USER_LAST_LOGIN].toDate() : Timestamp(doc[USER_LAST_LOGIN]['_seconds'], doc[USER_LAST_LOGIN]['_nanoseconds']).toDate(), // Firestore Timestamp
      userDeviceToken: doc[USER_DEVICE_TOKEN],
      userTotalLikes: doc[USER_TOTAL_LIKES] ?? 0,
      userTotalVisits: doc[USER_TOTAL_VISITS] ?? 0,
      userTotalDisliked: doc[USER_TOTAL_DISLIKED] ?? 0,
      userHeight: doc[USER_HEIGHT] is double ? doc[USER_HEIGHT] : doc[USER_HEIGHT].toDouble(),
      userPersonalInterests: doc['personalInterests'] is Map ? UserPersonalInterests.fromJson(doc['personalInterests']) : null,
    );
  }
}

/// UserPersonalInterests model
class UserPersonalInterests {
  /// User personal interests
  List<String> dreamPlaces;
  List<String> favoriteBooks;
  List<String> favoriteAnimeOrMovies;
  List<String> interests;
  bool smokingDrinking;

  // Constructor
  UserPersonalInterests({
    required this.dreamPlaces,
    required this.favoriteBooks,
    required this.favoriteAnimeOrMovies,
    required this.interests,
    required this.smokingDrinking,
  });

  /// factory user personal interests object
  factory UserPersonalInterests.fromJson(Map<String, dynamic> doc) {
    return UserPersonalInterests(
      dreamPlaces: doc['dream_places'] is List ? doc['dream_places'].map<String>((e) => e.toString()).toList() : [],
      favoriteBooks: doc['fav_books'] is List ? doc['fav_books'].map<String>((e) => e.toString()).toList() : [],
      favoriteAnimeOrMovies: doc['fav_anime_movies'] is List ? doc['fav_anime_movies'].map<String>((e) => e.toString()).toList() : [],
      interests: doc['interests'] is List ? doc['interests'].map<String>((e) => e.toString()).toList() : [],
      smokingDrinking: doc['smoking_drinking'] is bool ? doc['smoking_drinking'] : false,
    );
  }

  /// Convert user personal interests to json
  Map<String, dynamic> toJson() {
    return {
      'dream_places': dreamPlaces,
      'favorite_books': favoriteBooks,
      'fav_anime_movies': favoriteAnimeOrMovies,
      'interests': interests,
      'smoking_drinking': smokingDrinking,
    };
  }
}
