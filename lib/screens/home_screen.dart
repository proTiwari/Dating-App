import 'dart:async';
import 'dart:io';

import 'package:dating_app/models/app_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/conversations_api.dart';
import 'package:dating_app/api/notifications_api.dart';
import 'package:dating_app/helpers/app_helper.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/helpers/app_notifications.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/notifications_screen.dart';
import 'package:dating_app/tabs/conversations_tab.dart';
import 'package:dating_app/tabs/discover_tab.dart';
import 'package:dating_app/tabs/matches_tab.dart';
import 'package:dating_app/tabs/profile_tab.dart';
import 'package:dating_app/utils/colors.dart';
import 'package:dating_app/widgets/notification_counter.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scoped_model/scoped_model.dart';

import '../components/bottom_sheet_filter_discover.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Variables
  final _conversationsApi = ConversationsApi();
  final _notificationsApi = NotificationsApi();
  final _appNotifications = AppNotifications();
  int _selectedIndex = 0;
  late AppLocalizations _i18n;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  // in_app_purchase stream
  late StreamSubscription<List<PurchaseDetails>> _inAppPurchaseStream;

  final GlobalKey<DiscoverTabState> discoverTabKey = GlobalKey();

  /// Tab navigation
  Widget _showCurrentNavBar() {
    List<Widget> options = <Widget>[
      DiscoverTab(key: discoverTabKey,),
      const MatchesTab(),
      const ConversationsTab(),
      const ProfileTab()
    ];

    return options.elementAt(_selectedIndex);
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (context) => BottomSheetFilterDiscoverWidget(onFilterDataChanged: (filters) {
        discoverTabKey.currentState?.loadUsers(filters);
      },),
    );
  }

  /// Update selected tab
  void _onTappedNavBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Get current User Real Time updates
  void _getCurrentUserUpdates() {
    /// Get user stream
    _userStream = UserModel().getUserStream();

    /// Subscribe to user updates
    _userStream.listen((userEvent) {
      // Update user
      UserModel().updateUserObject(userEvent.data()!);
    });
  }

  ///
  /// Handle in-app purchases upates
  ///
  void _handlePurchaseUpdates() {
    // Listen purchase updates
    _inAppPurchaseStream =
        InAppPurchase.instance.purchaseStream.listen((purchases) async {
      // Loop incoming purchases
      for (var purchase in purchases) {
        // Control purchase status
        switch (purchase.status) {
          case PurchaseStatus.pending:
            // Handle this case.
            break;
          case PurchaseStatus.purchased:

            /// **** Deliver product to user **** ///
            ///
            /// Update User VIP Status to true
            UserModel().setUserVip();
            // Set Vip Subscription Id
            UserModel().setActiveVipId(purchase.productID);

            /// Update user verified status
            await UserModel().updateUserData(
                userId: UserModel().user.userId,
                data: {USER_IS_VERIFIED: true});

            // User first name
            final String userFirstname =
                UserModel().user.userFullname.split(' ')[0];

            /// Save notification in database for user
            _notificationsApi.onPurchaseNotification(
              nMessage: '${_i18n.translate("hello")} $userFirstname, '
                  '${_i18n.translate("your_vip_account_is_active")}\n '
                  '${_i18n.translate("thanks_for_buying")}',
            );

            if (purchase.pendingCompletePurchase) {
              /// Complete pending purchase
              InAppPurchase.instance.completePurchase(purchase);
              debugPrint('Success pending purchase completed!');
            }
            break;
          case PurchaseStatus.error:
            // Handle this case.
            debugPrint('purchase error-> ${purchase.error?.message}');
            break;
          case PurchaseStatus.restored:

            ///
            /// <--- Restore VIP Subscription --->
            ///
            UserModel().setUserVip();
            // Set Vip Subscription Id
            UserModel().setActiveVipId(purchase.productID);
            // Debug
            debugPrint('Active VIP SKU: ${purchase.productID}');
            // Check
            if (UserModel().showRestoreVipMsg) {
              // Show toast message
              Fluttertoast.showToast(
                msg: _i18n.translate('VIP_subscription_successfully_restored'),
                gravity: ToastGravity.BOTTOM,
                backgroundColor: APP_PRIMARY_COLOR,
                textColor: Colors.white,
              );
            }
            break;
          case PurchaseStatus.canceled:
            // Show canceled feedback
            Fluttertoast.showToast(
              msg:
                  _i18n.translate('you_canceled_the_purchase_please_try_again'),
              gravity: ToastGravity.BOTTOM,
              backgroundColor: APP_PRIMARY_COLOR,
              textColor: Colors.white,
            );
            break;
        }
      }
    });
  }

  Future<void> _handleNotificationClick(Map<String, dynamic>? data) async {
    /// Handle notification click
    await _appNotifications.onNotificationClick(
      context,
      nType: data?[N_TYPE] ?? '',
      nSenderId: data?[N_SENDER_ID] ?? '',
      nMessage: data?[N_MESSAGE] ?? '',
    );
  }

  /// Request permission for push notifications
  /// Only for iOS
  void _requestPermissionForIOS() async {
    if (Platform.isIOS) {
      // Request permission for iOS devices
      await FirebaseMessaging.instance.requestPermission();
    }
  }

  ///
  /// Handle incoming notifications while the app is in the Foreground
  ///
  Future<void> _initFirebaseMessage() async {
    // Get inicial message if the application
    // has been opened from a terminated state.
    final message = await FirebaseMessaging.instance.getInitialMessage();
    // Check notification data
    if (message != null) {
      // Debug
      debugPrint('getInitialMessage() -> data: ${message.data}');
      // Handle notification data
      await _handleNotificationClick(message.data);
    }

    // Returns a [Stream] that is called when a user
    // presses a notification message displayed via FCM.
    // Note: A Stream event will be sent if the app has
    // opened from a background state (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Debug
      debugPrint('onMessageOpenedApp() -> data: ${message.data}');
      // Handle notification data
      await _handleNotificationClick(message.data);
    });

    // Listen for incoming push notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      // Debug
      debugPrint('onMessage() -> data: ${message?.data}');
      // Handle notification data
      await _handleNotificationClick(message?.data);
    });
  }

  @override
  void initState() {
    super.initState();

    /// Restore VIP Subscription
    AppHelper().restoreVipAccount();

    /// Init streams
    _getCurrentUserUpdates();
    _handlePurchaseUpdates();
    _initFirebaseMessage();

    /// Request permission for IOS
    _requestPermissionForIOS();
  }

  @override
  void dispose() {
    super.dispose();
    // Close streams
    _userStream.drain();
    _inAppPurchaseStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScopedModelDescendant<UserModel>(
              builder: (context, child, model) => Text('Hello, ' + model.user.userFullname + ' 👋',
                  style: const TextStyle(fontSize: 20, color: textPrimaryColor, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 2),
            Text('Find your match now...', style: TextStyle(fontSize: 14, color: textSecondaryColor)),
          ],
        ),
        actions: [
          _selectedIndex != 0 ?
          IconButton(
              icon: _getNotificationCounter(),
              onPressed: () async {
                // Go to Notifications Screen
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotificationsScreen()));
              }): Container(),

          _selectedIndex == 0 ?
          ScopedModelDescendant<AppModel>(rebuildOnChange: true, builder: (context, child, model) {
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                showFilterBottomSheet();
              },

              child: Badge(
                largeSize: 20,
                backgroundColor: APP_PRIMARY_COLOR,
                isLabelVisible: (model.discoverFilterData?.getAppliedFilterCount() ?? 0) > 0,
                label: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    AppModel().discoverFilterData?.getAppliedFilterCount().toString() ?? '',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.sort, color: APP_PRIMARY_COLOR, size: 30),
                ),
              ),
            );
          }) : Container(),
          SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: Platform.isIOS ? 0 : 8,
          currentIndex: _selectedIndex,
          onTap: _onTappedNavBar,
          items: [
            /// Discover Tab
            BottomNavigationBarItem(
                icon: Icon(Icons.search,
                    size: 27,
                    color: _selectedIndex == 0
                        ? Theme.of(context).primaryColor
                        : null),
                label: _i18n.translate("discover")),

            /// Matches Tab
            BottomNavigationBarItem(
                icon: Icon(
                    _selectedIndex == 1
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
                    color: _selectedIndex == 1
                        ? Theme.of(context).primaryColor
                        : null),
                label: _i18n.translate("matches")),

            /// Conversations Tab
            BottomNavigationBarItem(
                icon: _getConversationCounter(),
                label: _i18n.translate("conversations")),

            /// Profile Tab
            BottomNavigationBarItem(
                icon: Icon(
                    _selectedIndex == 3
                        ? FontAwesomeIcons.solidUser
                        : FontAwesomeIcons.user,
                    color: _selectedIndex == 3
                        ? Theme.of(context).primaryColor
                        : null),
                label: _i18n.translate("profile")),
          ]),
      body: _showCurrentNavBar(),
    );
  }

  /// Count unread notifications
  Widget _getNotificationCounter() {
    // Set icon
    const icon = Icon(Icons.notifications_outlined, size: 30,);

    /// Handle stream
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationsApi.getNotifications(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return icon;
          } else {
            /// Get total counter to alert user
            final total = snapshot.data!.docs
                .where((doc) => doc.data()[N_READ] == false)
                .toList()
                .length;
            if (total == 0) return icon;
            return NotificationCounter(icon: icon, counter: total);
          }
        });
  }

  /// Count unread conversations
  Widget _getConversationCounter() {
    // Set icon
    final icon = Icon(
        _selectedIndex == 2
            ? FontAwesomeIcons.solidCommentDots
            : FontAwesomeIcons.commentDots,
        size: 27,
        color: _selectedIndex == 2 ? Theme.of(context).primaryColor : null);

    /// Handle stream
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _conversationsApi.getConversations(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return icon;
          } else {
            /// Get total counter to alert user
            final total = snapshot.data!.docs
                .where((doc) => doc.data()[MESSAGE_READ] == false)
                .toList()
                .length;
            if (total == 0) return icon;
            return NotificationCounter(icon: icon, counter: total);
          }
        });
  }
}
