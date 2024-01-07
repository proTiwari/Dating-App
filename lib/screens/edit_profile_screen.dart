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

  /// User Birthday info
  int _userBirthDay = UserModel().user.userBirthDay;
  int _userBirthMonth = UserModel().user.userBirthMonth;
  int _userBirthYear = UserModel().user.userBirthYear;
  // End
  DateTime _initialDateTime = DateTime.now();
  String? _birthday = DateTime(UserModel().user.userBirthYear, UserModel().user.userBirthMonth, UserModel().user.userBirthDay).toString().split(' ')[0];
  String _selectedGender = UserModel().user.userGender;

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


