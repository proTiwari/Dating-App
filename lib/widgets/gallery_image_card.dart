import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/widgets/default_card_border.dart';
import 'package:dating_app/widgets/image_source_sheet.dart';
import 'package:dating_app/dialogs/vip_dialog.dart';
import 'package:flutter/material.dart';

class GalleryImageCard extends StatelessWidget {
  // Variables
  final ImageProvider imageProvider;
  final String? imageUrl;
  final BoxFit boxFit;
  final int index;

  const GalleryImageCard({
    Key? key,
    required this.imageProvider,
    required this.imageUrl,
    required this.boxFit,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            shape: defaultCardBorder(),
            color: Colors.grey[300],
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(fit: boxFit, image: imageProvider),
                  color: Colors.grey.withAlpha(70),
                ),
              ),
            ),
          ),
          Positioned(
            child: IconButton(
                icon: CircleAvatar(
                  radius: 15,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(imageUrl == null ? Icons.add : Icons.close,
                      color: Colors.white),
                ),
                onPressed: () {
                  /// Check image url to exe action
                  if (imageUrl == null) {
                    /// Add or update image
                    _selectImage(context);
                  } else {
                    /// Delete image from gallery
                    _deleteGalleryImage(context);
                  }
                }),
            right: 8,
            bottom: 5,
          )
        ],
      ),
      onTap: () {
        /// Add or update image
        _selectImage(context);
      },
    );
  }

  /// Get image from camera / gallery
  void _selectImage(BuildContext context) async {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context, isDismissible: false);

    /// Premium code start
    /*/// Check user vip account
    if (!UserModel().userIsVip && index > 3) {
      /// Show VIP dialog
      showDialog(context: context, builder: (context) => const VipDialog());
      debugPrint('You need to activate vip account');
      return;
    }*/
    /// Premium code end

    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  /// Show progress dialog
                  pr.show(i18n.translate("processing"));

                  /// Update gallery image
                  await UserModel().updateProfileImage(
                      imageFile: image,
                      oldImageUrl: imageUrl,
                      path: 'gallery',
                      index: index);
                  // Hide dialog
                  pr.hide();
                  // close modal
                  Navigator.of(context).pop();
                }
              },
            ));
  }

  /// Delete image from gallery
  void _deleteGalleryImage(BuildContext context) async {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context, isDismissible: false);

    /// Premium code start
    /*/// Check user vip account
    if (!UserModel().userIsVip && index > 3) {
      /// Show VIP dialog
      showDialog(context: context, builder: (context) => const VipDialog());
      debugPrint('You need to activate vip account');
      return;
    }*/
    /// Premium code end

    /// Confirm before
    confirmDialog(context,
        message: i18n.translate("photo_will_be_deleted"),
        negativeAction: () => Navigator.of(context).pop(),
        positiveText: i18n.translate("DELETE"),
        positiveAction: () async {
          // Show processing dialog
          pr.show(i18n.translate("processing"));

          /// Delete image
          await UserModel()
              .deleteGalleryImage(imageUrl: imageUrl!, index: index);

          // Hide progress dialog
          pr.hide();
          // Hide confirm dialog
          Navigator.of(context).pop();
        });
  }
}
