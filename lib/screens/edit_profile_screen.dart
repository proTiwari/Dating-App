import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/widgets/image_source_sheet.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:dating_app/widgets/user_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:scoped_model/scoped_model.dart';

import '../components/decimal_input_formater.dart';
import '../constants/constants.dart';
import '../datas/user.dart';
import '../utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _schoolController =
      TextEditingController(text: UserModel().user.userSchool);
  final _jobController =
      TextEditingController(text: UserModel().user.userJobTitle);
  final _bioController = TextEditingController(text: UserModel().user.userBio);
  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  final _nameController = TextEditingController(text: UserModel().user.userFullname);
  final _birthdayController = TextEditingController(text: DateTime(UserModel().user.userBirthYear, UserModel().user.userBirthMonth, UserModel().user.userBirthDay).toString().split(' ')[0]);
  final _emailController = TextEditingController(text: UserModel().user.userEmail);
  final _heightController = TextEditingController(text: UserModel().user.userHeight?.toStringAsFixed(2));

  final _dreamPlaceController = TextEditingController();
  final _booksController = TextEditingController();
  TextEditingController _animeController = TextEditingController();

  /// User Birthday info
  int _userBirthDay = UserModel().user.userBirthDay;
  int _userBirthMonth = UserModel().user.userBirthMonth;
  int _userBirthYear = UserModel().user.userBirthYear;
  // End
  DateTime _initialDateTime = DateTime.now();
  String? _birthday = DateTime(UserModel().user.userBirthYear, UserModel().user.userBirthMonth, UserModel().user.userBirthDay).toString().split(' ')[0];
  String _selectedGender = UserModel().user.userGender;
  List<String> dreamPlaces = UserModel().user.userPersonalInterests?.dreamPlaces ?? [];
  List<String> favBooks = UserModel().user.userPersonalInterests?.favoriteBooks ?? [];
  List<String> favAnimeMovies = UserModel().user.userPersonalInterests?.favoriteAnimeOrMovies ?? [];
  List<String> interests = UserModel().user.userPersonalInterests?.interests ?? [];
  bool smokingOrDrinking = UserModel().user.userPersonalInterests?.smokingDrinking ?? false;

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_i18n.translate("edit_profile")),
        actions: [
          // Save changes button
          TextButton(
            child: Text(_i18n.translate("SAVE"),
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              /// Validate form
              if (_formKey.currentState!.validate()) {
                _saveChanges();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ScopedModelDescendant<UserModel>(
              builder: (context, child, userModel) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Profile photo
                GestureDetector(
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(userModel.user.userProfilePhoto),
                          radius: 80,
                          backgroundColor: Theme.of(context).primaryColor,
                        ),

                        /// Edit icon
                        Positioned(
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          right: 0,
                          bottom: 0,
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    /// Update profile image
                    _selectImage(
                        imageUrl: userModel.user.userProfilePhoto,
                        path: 'profile');
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(_i18n.translate("profile_photo"),
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center),
                ),

                /// Profile gallery
                Text(_i18n.translate("gallery"),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.left),
                const SizedBox(height: 5),

                /// Show gallery
                const UserGallery(),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: _i18n.translate("fullname"),
                      hintText: _i18n.translate("enter_your_fullname"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.person_outline),
                      )),
                  validator: (name) {
                    // Basic validation
                    if (name?.isEmpty ?? false) {
                      return _i18n.translate("please_enter_your_fullname");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: _i18n.translate("email"),
                      hintText: _i18n.translate("enter_your_email"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.email_outlined),
                      )),
                  validator: (email) {
                    // Basic validation
                    if (email?.isEmpty ?? false) {
                      return _i18n.translate("please_enter_your_email");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// User gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: _i18n.translate("lang") != 'en'
                          ? Text(
                          '${gender.toString()} - ${_i18n.translate(gender.toString().toLowerCase())}')
                          : Text(gender.toString()),
                    );
                  }).toList(),
                  hint: Text(_i18n.translate("select_gender")),
                  onChanged: (gender) {
                    if(gender != null) {
                      setState(() {
                        _selectedGender = gender;
                      });
                    }
                  },
                  validator: (String? value) {
                    if (value == null) {
                      return _i18n.translate("please_select_your_gender");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Bio field
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: _i18n.translate("bio"),
                    hintText: _i18n.translate("write_about_you"),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SvgIcon("assets/icons/info_icon.svg"),
                    ),
                  ),
                  validator: (bio) {
                    if (bio == null) {
                      return _i18n.translate("please_write_your_bio");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /*/// School field
                TextFormField(
                  controller: _schoolController,
                  decoration: InputDecoration(
                      labelText: _i18n.translate("school"),
                      hintText: _i18n.translate("enter_your_school_name"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(9.0),
                        child: SvgIcon("assets/icons/university_icon.svg"),
                      )),
                  validator: (school) {
                    if (school == null) {
                      return _i18n.translate("please_enter_your_school_name");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Job title field
                TextFormField(
                  controller: _jobController,
                  decoration: InputDecoration(
                      labelText: _i18n.translate("job_title"),
                      hintText: _i18n.translate("enter_your_job_title"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SvgIcon("assets/icons/job_bag_icon.svg"),
                      )),
                  validator: (job) {
                    if (job == null) {
                      return _i18n.translate("please_enter_your_job_title");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),*/
                TextFormField(
                  controller: _birthdayController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: _i18n.translate("birthday"),
                    hintText: _i18n.translate("select_your_birthday"),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.calendar_month_outlined),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),

                  onTap: () {
                    /// Select birthday
                    _showDatePicker();
                  },
                ),
                const SizedBox(height: 20),

                /// Height field
                TextFormField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                  decoration: InputDecoration(
                    labelText: _i18n.translate("height_optional"),
                    hintText: _i18n.translate("enter_your_height_in_cm"),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.height_outlined),
                    ),
                    suffix: Text(_i18n.translate("cm")),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(
                  indent: 3,
                  height: 1,
                  color: borderColor,
                ),
                const SizedBox(height: 20),

                const Text("Personal Interests",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 8),

                SizedBox(height: 16,),

                const Text("Dream Places",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87)),

                const SizedBox(height: 16,),

                Row(
                  children: [
                    Expanded(child: TextFormField(
                      controller: _dreamPlaceController,
                      decoration: InputDecoration(
                          labelText: 'Add Dream Place',
                          hintText: 'Eg: Paris, France, etc.',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.place),
                          )),
                    ),),
                    SizedBox(width: 16,),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if(_dreamPlaceController.text.trim().isNotEmpty) {
                            setState(() {
                              dreamPlaces.add(_dreamPlaceController.text.trim());
                              _dreamPlaceController.clear();
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),

                SizedBox(height: 8,),

                Wrap(
                  children: dreamPlaces.map((dreamPlace) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Chip(
                      label: Text(dreamPlace),
                      onDeleted: () {
                        if(dreamPlaces.length > 1) {
                          setState(() {
                            dreamPlaces.remove(dreamPlace);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Cannot Delete. At least one dream place is required.'),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 16),
                const Divider(
                  indent: 3,
                  height: 1,
                  color: borderColor,
                ),
                const SizedBox(height: 16,),

                const Text("Favourite Books",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87)),

                const SizedBox(height: 16,),

                Row(
                  children: [
                    Expanded(child: TextFormField(
                      controller: _booksController,
                      decoration: const InputDecoration(
                          labelText: 'Add Book',
                          hintText: 'Eg: Harry Potter.',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.library_books),
                          )),
                    ),),
                    SizedBox(width: 16,),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if(_booksController.text.trim().isNotEmpty) {
                            setState(() {
                              favBooks.add(_booksController.text.trim());
                              _booksController.clear();
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),

                SizedBox(height: 8,),

                Wrap(
                  children: favBooks.map((book) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Chip(
                      label: Text(book),
                      onDeleted: () {
                        if(favBooks.length > 1) {
                          setState(() {
                            favBooks.remove(book);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Cannot Delete. At least one book is required.'),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 16),
                const Divider(
                  indent: 3,
                  height: 1,
                  color: borderColor,
                ),
                const SizedBox(height: 16,),

                const Text("Favourite Anime/Movies/Web Series",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87)),


                const SizedBox(height: 16,),

                Row(
                  children: [
                    Expanded(child: TextFormField(
                      controller: _animeController,
                      decoration: InputDecoration(
                          labelText: 'Add Anime/Movies/Web Series',
                          hintText: 'Eg: Naruto, etc.',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.movie),
                          )),
                    ),),
                    SizedBox(width: 16,),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if(_animeController.text.trim().isNotEmpty) {
                            setState(() {
                              favAnimeMovies.add(_animeController.text.trim());
                              _animeController.clear();
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),

                SizedBox(height: 16,),

                Wrap(
                  children: favAnimeMovies.map((dreamPlace) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Chip(
                      label: Text(dreamPlace),
                      onDeleted: () {
                        if(favAnimeMovies.length > 1) {
                          setState(() {
                            favAnimeMovies.remove(dreamPlace);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Cannot Delete. At least one anime/movie/web series is required.'),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 16),
                const Divider(
                  indent: 3,
                  height: 1,
                  color: borderColor,
                ),
                const SizedBox(height: 16,),

                const Text("Interests",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87)),

                const SizedBox(height: 16,),

                Wrap(
                  children: interestCategories.map((interest) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text(interest),
                      selected: interests.contains(interest),
                      onSelected: (bool selected) {
                        setState(() {
                          if(selected) {
                            interests.add(interest);
                          }
                          else {
                            if(interests.length > 1) {
                              interests.remove(interest);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Cannot unselect. At least one interest is required.'),
                                duration: Duration(seconds: 2),
                              ));
                            }
                          }
                        });
                      },
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 16),
                const Divider(
                  indent: 3,
                  height: 1,
                  color: borderColor,
                ),
                SizedBox(height: 16,),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Smoking/Drinking", style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87)),
                  value: smokingOrDrinking,
                  onChanged: (bool value) {
                    setState(() {
                      smokingOrDrinking = value;
                    });
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Get image from camera / gallery
  void _selectImage({required String imageUrl, required String path}) async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  /// Show progress dialog
                  _pr.show(_i18n.translate("processing"));

                  /// Update profile image
                  await UserModel().updateProfileImage(
                      imageFile: image, oldImageUrl: imageUrl, path: 'profile');
                  // Hide dialog
                  _pr.hide();
                  // close modal
                  Navigator.of(context).pop();
                }
              },
            ));
  }

  /// Update profile changes for TextFormField only
  void _saveChanges() {
    /// Update uer profile
    UserModel().updateProfile(
        userSchool: _schoolController.text.trim(),
        userJobTitle: _jobController.text.trim(),
        userBio: _bioController.text.trim(),
        userFullName: _nameController.text.trim(),
        userGender: _selectedGender,
        userBirthDay: _userBirthDay,
        userBirthMonth: _userBirthMonth,
        userBirthYear: _userBirthYear,
        userHeight: double.tryParse(_heightController.text.trim()),
        userEmail: _emailController.text.trim(),
        userPersonalInterests: UserPersonalInterests(
          dreamPlaces: dreamPlaces,
          favoriteBooks: favBooks,
          favoriteAnimeOrMovies: favAnimeMovies,
          interests: interests,
          smokingDrinking: smokingOrDrinking,
        ),
        onSuccess: () {
          /// Show success message
          successDialog(context,
              message: _i18n.translate("profile_updated_successfully"),
              positiveAction: () {
            /// Close dialog
            Navigator.of(context).pop();

            /// Go to profilescreen
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen(user: UserModel().user, showButtons: false)));
          });
        },
        onFail: (error) {
          // Debug error
          debugPrint(error);
          // Show error message
          errorDialog(context,
              message: _i18n
                  .translate("an_error_occurred_while_updating_your_profile"));
        });
  }

  void _updateUserBithdayInfo(DateTime date) {
    setState(() {
      // Update the inicial date
      _initialDateTime = date;
      // Set for label
      _birthday = date.toString().split(' ')[0];
      _birthdayController.text = _birthday!;
      // User birthday info
      _userBirthDay = date.day;
      _userBirthMonth = date.month;

      _userBirthYear = date.year;
    });
  }

  // Get Date time picker app locale
  DateTimePickerLocale _getDatePickerLocale() {
    // Inicial value
    DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
    // Get the name of the current locale.
    switch (_i18n.translate('lang')) {
    // Handle your Supported Languages below:
      case 'en': // English
        _locale = DateTimePickerLocale.en_us;
        break;
    }
    return _locale;
  }

  /// Display date picker.
  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text(_i18n.translate('DONE'),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Theme.of(context).primaryColor)),
      ),
      minDateTime: DateTime(1920, 1, 1),
      maxDateTime: DateTime.now(),
      initialDateTime: _initialDateTime,
      dateFormat: 'yyyy-MMMM-dd', // Date format
      locale: _getDatePickerLocale(), // Set your App Locale here
      onClose: () => debugPrint("----- onClose -----"),
      onCancel: () => debugPrint('onCancel'),
      onChange: (dateTime, List<int> index) {
        // Get birthday info
        _updateUserBithdayInfo(dateTime);
      },
      onConfirm: (dateTime, List<int> index) {
        // Get birthday info
        _updateUserBithdayInfo(dateTime);
      },
    );
  }
}


