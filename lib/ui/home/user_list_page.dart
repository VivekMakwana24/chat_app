import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/chat_detail/chat_details.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/popup_choices.dart';
import 'package:flutter_demo_structure/util/utilities.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/extensions/widget_ext.dart';
import 'package:flutter_demo_structure/widget/base_app_bar.dart';
import 'package:flutter_demo_structure/widget/debouncer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocity_x/velocity_x.dart';

class UserListPage extends StatefulWidget {
  final bool isForGroup;

  const UserListPage({
    required this.isForGroup,
    Key? key,
  }) : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
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
  final ValueNotifier<List<FirebaseChatUser>> _participantsList = ValueNotifier<List<FirebaseChatUser>>([]);

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
    /* firebaseChatManager.updateDataFirestore(
      FirebaseCollection.users.name,
      appDB.user.userId.toString(),
      {'pushToken': appDB.fcmToken},
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: BaseAppBar(
          showTitle: true,
          leadingIcon: true,
          title: widget.isForGroup ? 'New Group' : 'Users',
          action: [],
        ),
        body: Stack(
          children: <Widget>[
            // List
            Column(
              children: [
                if (widget.isForGroup) buildParticipantsList(),
                buildSearchBar(),
                Expanded(
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
                ),
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

  Widget buildParticipantsList() {
    return ValueListenableBuilder(
      valueListenable: _participantsList,
      builder: (BuildContext context, List<FirebaseChatUser> participants, Widget? child) {
        return SizedBox(
          height: 100,
          child: ListView.builder(
            itemCount: participants.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              FirebaseChatUser userChat = participants[index];
              return _buildParticipantsItem(userChat);
            },
          ),
        ).visiblity(participants.isNotEmpty);
      },
    );
  }

  Column _buildParticipantsItem(FirebaseChatUser userChat) {
    return Column(
      children: [
        Material(
          child: !(userChat.userImage?.isEmptyOrNull ?? true)
              ? Image.network(
                  userChat.userImage ?? '',
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
        10.verticalSpace,
        Text(
          '${userChat.userName}',
          maxLines: 1,
          style: TextStyle(color: AppColor.primaryColor),
        )
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

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      FirebaseChatUser userChat = FirebaseChatUser.fromDocument(document);
      debugPrint('USERS ==> ${userChat.userId} ${userChat.userName}');
      debugPrint('MyuseriD ==> ${appDB.user.userId}');

      if (userChat.userId == appDB.user.userId) {
        return SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: !(userChat.userImage?.isEmptyOrNull ?? true)
                      ? Image.network(
                          userChat.userImage ?? '',
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
                      children: <Widget>[
                        Container(
                          child: Text(
                            '${userChat.userName}',
                            maxLines: 1,
                            style: TextStyle(color: AppColor.primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20),
                  ),
                ),
              ],
            ),
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }
              if (widget.isForGroup) {
                if (_participantsList.value.contains(userChat)) {
                  debugPrint('DATA REmoved');

                  _participantsList.value.remove(userChat);
                  _participantsList.notifyListeners();
                } else {
                  debugPrint('DATA ADDED');
                  _participantsList.value.add(userChat);
                  _participantsList.notifyListeners();
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailsPage(
                      arguments: ChatPageArguments(
                        chatUser: userChat,
                      ),
                    ),
                  ),
                );
              }
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
      }
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
