import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/chat_detail/chat_details.dart';
import 'package:flutter_demo_structure/ui/home/new_group/new_group_page.dart';
import 'package:flutter_demo_structure/ui/home/user_list_page.dart';
import 'package:flutter_demo_structure/ui/web/widgets/contactlist_appbar.dart';
import 'package:flutter_demo_structure/util/date_time_helper.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/popup_choices.dart';
import 'package:flutter_demo_structure/util/utilities.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/constants.dart';
import 'package:flutter_demo_structure/values/extensions/widget_ext.dart';
import 'package:flutter_demo_structure/values/style.dart';
import 'package:flutter_demo_structure/widget/button_widget.dart';
import 'package:flutter_demo_structure/widget/debouncer.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  final bool fetchOnlyGroups;

  const HomePage({this.fetchOnlyGroups = false, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*
   * *****************************************************
   * Class members
   * *****************************************************
   */

  // region Class members
  ValueNotifier<bool> showLoading = ValueNotifier<bool>(false);
  final ScrollController listScrollController = ScrollController();
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);

  final List<ChatMessage> _recentChatList = [];

  int _limit = 20;

  ChatMessage? _selectedItem;

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Log out', icon: Icons.exit_to_app),
  ];

  // endregion

  /*
    * *****************************************************
    * Lifecycle functions
    * *****************************************************
    * */

  // region Lifecycle functions

  @override
  void initState() {
    super.initState();
    getPermission();

    firebaseChatManager.updateDataFirestore(
      FirebaseCollection.users.name,
      appDB.currentUserId,
      {'device_token': appDB.fcmToken},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        // floatingActionButton: buildFab(context),
        backgroundColor: AppColor.white,
        body: Stack(
          children: <Widget>[
            // List
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      //WEB PROFILE
                      ContactlistAppBar(),

                      //SEARCH
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: buildSearchBar(),
                      ),
                      10.h.verticalSpace,

                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 100,
                          child: AppButton(
                            'Create Group',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserListPage(
                                    isForGroup: true,
                                    pageType: PageType.NEW_GROUP,
                                  ),
                                ),
                              );
                            },
                            height: 30,
                            radius: 6,
                          ),
                        ),
                      ).visiblity(
                        widget.fetchOnlyGroups,
                      ),

                      // buildSearchBar(),
                      10.h.verticalSpace,
                      Flexible(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: firebaseChatManager.getRecentChatStream(
                              _limit, searchBarTec.text.trim(), widget.fetchOnlyGroups),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              _recentChatList.clear();

                              _recentChatList.addAll(
                                  (snapshot.data?.docs.map((e) => ChatMessage.toDocumentToClass(e)).toList() ?? []));

                              if (chatID.isNotEmpty) {
                                var itemData = _recentChatList.firstWhereOrNull((element) => element.chatId == chatID);
                                chatID = '';
                                if (itemData != null) {
                                  if (_selectedItem != null) {
                                    _selectedItem?.isSelected = false;
                                    _selectedItem = null;
                                  }
                                  itemData.isSelected = true;
                                  _selectedItem = itemData;

                                  debugPrint('SelectedITem = ${_selectedItem?.chatId}');
                                  debugPrint('SelectedITem = ${_selectedItem?.isSelected}');
                                  Future.delayed(
                                    Duration(milliseconds: 1500),
                                    () {
                                      debugPrint('Set State Called --> SelectedITem = ${_selectedItem?.isSelected}');
                                      setState(() {});
                                    },
                                  );
                                }
                              }

                              return (_recentChatList.isNotEmpty)
                                  ? ListView.separated(
                                      itemCount: _recentChatList.length,
                                      shrinkWrap: true,
                                      // physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return buildItem(context, _recentChatList[index]);
                                      },
                                      separatorBuilder: (context, index) {
                                        return 15.h.verticalSpace;
                                      },
                                    )
                                  : Center(
                                      child: 'No Recent Messages'.text.make(),
                                    );
                            } else {
                              return _buildLoader();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                //DiVIDER
                Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: ColorData.lightGrey),
                      bottom: BorderSide(color: ColorData.lightGrey),
                    ),
                    color: ColorData.white,
                  ),
                ),

                if (_selectedItem != null)
                  Expanded(
                    flex: 2,
                    child: ChatDetailsPage(
                      arguments: ChatPageArguments(
                        chatUser: FirebaseChatUser(
                          isOnline: false,
                          userId: _selectedItem?.getOtherUserId,
                          userEmail: '',
                          userName: _selectedItem?.getName,
                          createdAt: _selectedItem?.createdAt,
                        ),
                        isGroup: (_selectedItem?.isGroup ?? false),
                        groupName: (_selectedItem?.isGroup ?? false) ? _selectedItem?.groupName : '',
                        chatId: (_selectedItem?.isGroup ?? false) ? _selectedItem?.chatId : '',
                        recentChat: _selectedItem,
                        isDialog: true,
                      ),
                    ),
                  )
                else
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Text('Welcome to Chat app'),
                    ).centered(),
                  )
              ],
            ),

            Positioned(bottom: 0, left: 40, child: buildFab(context)),

            // Loading
            Positioned(
              child: ValueListenableBuilder(
                valueListenable: showLoading,
                builder: (BuildContext context, bool isLoading, Widget? child) {
                  return isLoading ? CircularProgressIndicator.adaptive() : SizedBox.shrink();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  ExpandableFab buildFab(BuildContext context) {
    return ExpandableFab(
      overlayStyle: ExpandableFabOverlayStyle(
        blur: 5,
      ),
      foregroundColor: AppColor.white,
      backgroundColor: AppColor.primaryColor,
      closeButtonStyle: ExpandableFabCloseButtonStyle(
        foregroundColor: AppColor.white,
        backgroundColor: AppColor.primaryColor,
      ),
      children: [
        FloatingActionButton.small(
          heroTag: null,
          child: const Icon(Icons.group_add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserListPage(
                  isForGroup: true,
                  pageType: PageType.NEW_GROUP,
                ),
              ),
            );
          },
          foregroundColor: AppColor.white,
          backgroundColor: AppColor.primaryColor,
        ),
        FloatingActionButton.small(
          heroTag: null,
          child: const Icon(Icons.supervised_user_circle),
          foregroundColor: AppColor.white,
          backgroundColor: AppColor.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserListPage(
                  isForGroup: false,
                  pageType: PageType.USERS,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // endregion

  /*
   * *****************************************************
   * UI functions
   * *****************************************************
   * */

  // region UI functions
  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 40,
      width: double.infinity,
      // height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorData.grey200.withOpacity(.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              cursorColor: ColorData.black,
              keyboardType: TextInputType.text,
              controller: searchBarTec,
              onChanged: (value) {
                searchDebouncer.run(() {
                  if (value.isNotEmpty) {
                    btnClearController.add(true);
                    setState(() {});
                  } else {
                    btnClearController.add(false);
                    setState(() {});
                  }
                });
              },
              decoration: InputDecoration(
                counterText: '',
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  child: SvgPicture.asset(
                    Assets.svgsSearch,
                  ),
                ),
                suffixIcon: StreamBuilder<bool>(
                    stream: btnClearController.stream,
                    builder: (context, snapshot) {
                      return snapshot.data == true
                          ? GestureDetector(
                              onTap: () {
                                searchBarTec.clear();
                                btnClearController.add(false);
                                setState(() {});
                              },
                              child: Icon(Icons.clear_rounded, color: AppColor.greyColor, size: 20))
                          : SizedBox.shrink();
                    }),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                hintText: 'Search here...',
                labelStyle: GoogleFonts.openSans(
                  color: ColorData.black,
                ),
                // contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: GoogleFonts.openSans(
                  color: ColorData.black,
                  fontSize: 14,
                ),
              ),
              style: GoogleFonts.openSans(
                color: ColorData.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPopupMenu() {
    return PopupMenuButton<PopupChoices>(
      onSelected: onItemMenuPress,
      itemBuilder: (BuildContext context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
            value: choice,
            child: Row(
              children: <Widget>[
                Icon(
                  choice.icon,
                  color: AppColor.primaryColor,
                ),
                Container(
                  width: 10,
                ),
                Text(
                  choice.title,
                  style: TextStyle(color: AppColor.primaryColor),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == 'Log out') {
      appDB.logout();
      firebaseChatManager.logoutUser();
    } else {}
  }

// endregion

// region LiveData observers

/*
    * *****************************************************
    * LiveData observers
    * *****************************************************

    * */
  Widget buildItem(BuildContext context, ChatMessage itemData) {
    if (itemData != null) {
      return Container(
        child: TextButton(
          child: Row(
            children: <Widget>[
              Material(
                child: !(itemData.getChatIcon.isEmptyOrNull ?? true)
                    ? Image.network(
                        itemData.getChatIcon ?? '',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColor.primaryColor,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return SvgPicture.asset(
                            (itemData.isGroup ?? false) ? Assets.svgsGroupIcon : Assets.svgsUserIcon,
                            height: 40.sm,
                            width: 40.sm,
                          );
                        },
                      )
                    : SvgPicture.asset(
                        (itemData.isGroup ?? false) ? Assets.svgsGroupIcon : Assets.svgsUserIcon,
                        height: 40.sm,
                        width: 40.sm,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          (itemData.isGroup ?? false) ? '${itemData.groupName}' : '${itemData.getName}',
                          maxLines: 1,
                          style: TextStyle(color: AppColor.primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      ),
                      Text(
                        (itemData.isGroup ?? false)
                            ? itemData.message != null
                                ? '${itemData.getGroupSenderName} : ${itemData.messageType == SendMessageType.text.typeValue ? itemData.message : 'sent an image'}'
                                : 'new group'
                            : '${itemData.messageType == SendMessageType.text.typeValue ? itemData.message : 'Sent an image'}',
                        maxLines: 1,
                        style: TextStyle(color: AppColor.greyColor, fontSize: 12),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    itemData.createdAt?.convertToAgo(text: 'ago') ??
                        (itemData.createdAt?.convertToAgoWithTimeStamp(text: 'ago') ?? ''),
                    style: textRegular10.copyWith(color: AppColor.greyColor),
                  ),
                  if (itemData.unreadCount > 0) ...[
                    SizedBox(
                      height: 20.spMin,
                      width: 20.spMin,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.redColor,
                        ),
                        child: Text(
                          '${itemData.unreadCount}',
                          style: textMedium.copyWith(fontSize: 10.spMin, color: AppColor.white),
                        ).centered(),
                      ),
                    ),
                  ],
                ],
              ).wrapPadding(
                padding: EdgeInsets.only(right: 10.w),
              ),
            ],
          ),
          onPressed: () {
            if (Utilities.isKeyboardShowing()) {
              Utilities.closeKeyboard(context);
            }

            if (_selectedItem != null) {
              _selectedItem?.isSelected = false;
              _selectedItem = null;
            }
            itemData.isSelected = true;
            _selectedItem = itemData;

            debugPrint('SelectedITem = ${_selectedItem?.chatId}');
            debugPrint('SelectedITem = ${_selectedItem?.isSelected}');
            setState(() {});
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 16, horizontal: 16)),
            // backgroundColor: MaterialStateProperty.all<Color>(AppColor.greyTealColor),
            backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) return AppColor.lightPurple;
              if (states.contains(MaterialState.hovered)) return AppColor.lightPurple;
              if (states.contains(MaterialState.pressed))
                return (_selectedItem != null) ? AppColor.lightPurple : AppColor.white;
              return Colors.white; // null throus error in flutter 2.2+.
            }),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
      );

      // FirebaseChatUser userChat = FirebaseChatUser.fromDocument(document);
      /*if (itemData.id == appDB.currentUserId) {
        return SizedBox.shrink();
      } else {*/
      // }
    } else {
      return SizedBox.shrink();
    }
  }

// endregion

  Future<void> getPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }
}
