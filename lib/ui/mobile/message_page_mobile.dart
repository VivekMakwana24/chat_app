import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/chat_detail/chat_details.dart';
import 'package:flutter_demo_structure/ui/home/new_group/new_group_page.dart';
import 'package:flutter_demo_structure/ui/home/user_list_page.dart';
import 'package:flutter_demo_structure/util/date_time_helper.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/popup_choices.dart';
import 'package:flutter_demo_structure/util/utilities.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/extensions/widget_ext.dart';
import 'package:flutter_demo_structure/values/style.dart';
import 'package:flutter_demo_structure/widget/base_app_bar.dart';
import 'package:flutter_demo_structure/widget/debouncer.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class MessagePageMobile extends StatefulWidget {
  const MessagePageMobile({Key? key}) : super(key: key);

  @override
  _MessagePageMobileState createState() => _MessagePageMobileState();
}

class _MessagePageMobileState extends State<MessagePageMobile> {
  /*
   * *****************************************************
   * Class members
   * *****************************************************
   */

  // region Class members
  ValueNotifier<bool> showLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isDataUpdated = ValueNotifier<bool>(false);
  final ScrollController listScrollController = ScrollController();
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);

  final List<ChatMessage> _recentChatList = [];

  int _limit = 20;
  int _limitIncrement = 20;
  String _textSearch = "";

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
    firebaseChatManager.updateDataFirestore(
      FirebaseCollection.users.name,
      appDB.currentUserId,
      {'pushToken': appDB.fcmToken},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: buildFab(context),
        appBar: BaseAppBar(
          title: 'Messages',
          showTitle: true,
          leadingIcon: false,
          action: [buildPopupMenu()],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: <Widget>[
              // List
              Column(
                children: [
                  //SEARCH
                  buildSearchBar(),

                  // buildSearchBar(),
                  10.h.verticalSpace,
                  Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firebaseChatManager.getRecentChatStream(_limit, searchBarTec.text.trim()),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          _recentChatList.clear();

                          _recentChatList.addAll(
                              (snapshot.data?.docs.map((e) => ChatMessage.toDocumentToClass(e)).toList() ?? []));

                          return (_recentChatList.isNotEmpty)
                              ? ListView.separated(
                                  itemCount: _recentChatList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return buildItem(context, _recentChatList[index]);
                                  },
                                  separatorBuilder: (context, index) {
                                    return 15.sm.verticalSpace;
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
              // Positioned(bottom: 0, left: 40, child: buildFab(context)),
            ],
          ),
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
                ));
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
                    setState(() {
                      _textSearch = value;
                    });
                  } else {
                    btnClearController.add(false);
                    setState(() {
                      _textSearch = "";
                    });
                  }
                });
              },
              decoration: InputDecoration(
                counterText: '',
                border: const OutlineInputBorder(),
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
                              setState(() {
                                _textSearch = "";
                              });
                            },
                            child: Icon(Icons.clear_rounded, color: AppColor.greyColor, size: 20),
                          )
                        : SizedBox.shrink();
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                hintText: 'Search here...',
                labelStyle: GoogleFonts.nunito(
                  color: ColorData.black,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: GoogleFonts.nunito(
                  color: ColorData.black,
                  fontSize: 16,
                ),
              ),
              style: GoogleFonts.nunito(
                color: ColorData.black,
                fontSize: 16,
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
              ));
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
                          return Icon(
                            Icons.account_circle,
                            size: 50,
                            color: AppColor.greyColor,
                          );
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          (itemData.isGroup ?? false) ? Icons.group : Icons.account_circle,
                          size: 30,
                          color: AppColor.greyColor,
                        ),
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
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.redColor,
                      ),
                      child: Text(
                        '${itemData.unreadCount}',
                        style: textMedium.copyWith(fontSize: 10.sm, color: AppColor.white),
                      ).wrapPadding(
                        padding: EdgeInsets.only(top: 8.w, bottom: 8.w, left: 8.w, right: 6.w),
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

            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ChatDetailsPage(
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
                      isDialog: false),
                );
              },
            ));

            debugPrint('SelectedITem = ${_selectedItem?.chatId}');
            debugPrint('SelectedITem = ${_selectedItem?.isSelected}');
            setState(() {});
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(AppColor.greyTealColor),
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
}
