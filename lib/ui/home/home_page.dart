import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/chat_detail/chat_details.dart';
import 'package:flutter_demo_structure/ui/home/user_list_page.dart';
import 'package:flutter_demo_structure/util/date_time_helper.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/popup_choices.dart';
import 'package:flutter_demo_structure/util/utilities.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/extensions/widget_ext.dart';
import 'package:flutter_demo_structure/values/style.dart';
import 'package:flutter_demo_structure/widget/base_app_bar.dart';
import 'package:flutter_demo_structure/widget/debouncer.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
  int _limitIncrement = 20;
  String _textSearch = "";

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
        appBar: BaseAppBar(
          showTitle: true,
          leadingIcon: false,
          title: 'Recent Chats',
          action: [buildPopupMenu()],
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
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
                    builder: (context) => UserListPage(isForGroup: true),
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
                      builder: (context) => UserListPage(isForGroup: false),
                    ));
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            // List
            Column(
              children: [
                buildSearchBar(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firebaseChatManager.getRecentChatStream(_limit),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        _recentChatList.clear();

                        _recentChatList
                            .addAll((snapshot.data?.docs.map((e) => ChatMessage.toDocumentToClass(e)).toList() ?? []));

                        return (_recentChatList.isNotEmpty)
                            ? ListView.separated(
                                itemCount: _recentChatList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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

                /*Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firebaseChatManager.getStreamFireStore(FirebaseCollection.users.name, _limit, _textSearch),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.builder(
                            padding: EdgeInsets.all(10),
                            itemBuilder: (context, index) => buildItem(context, snapshot.data?.docs[index]),
                            itemCount: snapshot.data?.docs.length,
                            controller: listScrollController,
                          );
                        } else {
                          return Center(
                            child: Text("No users"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryColor,
                          ),
                        );
                      }
                    },
                  ),
                ),*/
              ],
            ),

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search, color: AppColor.greyColor, size: 20),
          SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
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
              decoration: InputDecoration.collapsed(
                hintText: 'Search user (you have to type exact string)',
                hintStyle: TextStyle(fontSize: 13, color: AppColor.greyColor),
              ),
              style: TextStyle(fontSize: 13),
            ),
          ),
          StreamBuilder<bool>(
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
                        child: Icon(Icons.clear_rounded, color: AppColor.greyColor, size: 20))
                    : SizedBox.shrink();
              }),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColor.greyTealColor,
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                    : Icon(
                        Icons.account_circle,
                        size: 50,
                        color: AppColor.greyColor,
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
                          '${itemData.getName}',
                          maxLines: 1,
                          style: TextStyle(color: AppColor.primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      ),
                      Text(
                        '${itemData.message}',
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

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailsPage(
                  arguments: ChatPageArguments(
                    chatUser: FirebaseChatUser(
                      isOnline: false,
                      userId: itemData.getOtherUserId,
                      userEmail: '',
                      userName: itemData.getName,
                      createdAt: itemData.createdAt,
                    ),
                  ),
                ),
              ),
            );
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

/*
    * *****************************************************
    * LiveData observers
    * *****************************************************
    * */

// region LiveData observers

// endregion

}
