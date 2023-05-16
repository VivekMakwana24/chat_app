import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/chat_detail/chat_details.dart';
import 'package:flutter_demo_structure/ui/home/new_group/new_group_page.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/popup_choices.dart';
import 'package:flutter_demo_structure/util/utilities.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/extensions/context_ext.dart';
import 'package:flutter_demo_structure/values/extensions/widget_ext.dart';
import 'package:flutter_demo_structure/widget/app_utils.dart';
import 'package:flutter_demo_structure/widget/base_app_bar.dart';
import 'package:flutter_demo_structure/widget/debouncer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class UserListPage extends StatefulWidget {
  final bool isForGroup;
  PageType pageType;
  List<String>? participantsList;

  UserListPage({
    required this.isForGroup,
    required this.pageType,
    this.participantsList,
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
      appDB.user?.userId.toString(),
      {'pushToken': appDB.fcmToken},
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: BaseAppBar(
          showTitle: true,
          leadingIcon: context.width >= 1024 ? false : true,
          title: widget.pageType == PageType.NEW_GROUP
              ? 'New Group'
              : (widget.pageType == PageType.USERS)
                  ? 'Users'
                  : 'Add Participants',
          action: [],
        ),
        floatingActionButton: (widget.pageType != PageType.USERS) ? buildFloatingAction(context) : null,
        body: Stack(
          children: <Widget>[
            // List
            Column(
              children: [
                if (widget.pageType != PageType.USERS) buildParticipantsList(),
                buildSearchBar(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firebaseChatManager.getStreamFireStore(
                        FirebaseCollection.users.name, _limit, _textSearch, widget.participantsList),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      debugPrint('HasDaTA ${snapshot.hasData}');

                      if (snapshot.hasData) {
                        debugPrint('HasDaTA ${(snapshot.data?.docs.length ?? 0) > 0}');
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

  FloatingActionButton buildFloatingAction(BuildContext context) {
    return FloatingActionButton(
      child: Icon(
        Icons.arrow_forward,
        color: AppColor.white,
      ),
      backgroundColor: AppColor.primaryColor,
      onPressed: () {
        if (_participantsList.value.isEmpty) {
          showMessage('At least 1 contact must be selected');
        } else {
          //navigate to group screen
          if (widget.pageType == PageType.NEW_GROUP) {
            if (kIsWeb)
              showGeneralDialog(
                context: context,
                barrierColor: Colors.black54,
                barrierDismissible: true,
                barrierLabel: 'Label',
                pageBuilder: (_, __, ___) {
                  return Row(
                    children: [
                      Spacer(),
                      SizedBox(
                        width: context.width * 0.4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: NewGroupPage(
                            participantsList: _participantsList.value,
                            isGroupDetails: false,
                            pageType: PageType.NEW_GROUP,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            else
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewGroupPage(
                    participantsList: _participantsList.value,
                    isGroupDetails: false,
                    pageType: PageType.NEW_GROUP,
                  ),
                ),
              );
          } else {
            Navigator.pop(context, _participantsList.value);
          }
        }
      },
    );
  }

  Widget buildParticipantsList() {
    return ValueListenableBuilder(
      valueListenable: _participantsList,
      builder: (BuildContext context, List<FirebaseChatUser> participants, Widget? child) {
        return Container(
          margin: EdgeInsets.only(top: 10),
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: participants.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                FirebaseChatUser userChat = participants[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 : 0),
                  child: _buildParticipantsItem(userChat),
                );
              },
            ),
          ).visiblity(participants.isNotEmpty),
        );
      },
    );
  }

  Column _buildParticipantsItem(FirebaseChatUser userChat) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
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
                          return SvgPicture.asset(
                            Assets.svgsUserIcon,
                            height: 30.sm,
                            width: 30.sm,
                          );
                        },
                      )
                    : SvgPicture.asset(
                        Assets.svgsUserIcon,
                        height: 30.sm,
                        width: 30.sm,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.hardEdge,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(color: AppColor.primaryColor, shape: BoxShape.circle),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColor.greyColor,
                  ),
                ).addGestureTap(() {
                  _participantsList.value.remove(userChat);
                  _participantsList.notifyListeners();
                }),
              )
            ],
          ),
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

  Widget buildSearchBar() {
    return Container(
      height: 40,
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
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: const OutlineInputBorder(),
                prefixIcon: SvgPicture.asset(
                  Assets.svgsSearch,
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
          /*StreamBuilder<bool>(
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
              }),*/
        ],
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
      debugPrint('MyuseriD ==> ${appDB.user?.userId}');

      if (userChat.userId == appDB.user?.userId ||
          (widget.participantsList != null && (widget.participantsList?.contains(userChat.userId ?? '') ?? false))) {
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
                            return SvgPicture.asset(
                              Assets.svgsUserIcon,
                              height: 40.sm,
                              width: 40.sm,
                            );
                          },
                        )
                      : SvgPicture.asset(
                          Assets.svgsUserIcon,
                          height: 40.sm,
                          width: 40.sm,
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
              if (widget.pageType != PageType.USERS) {
                bool check =
                    _participantsList.value.firstWhereOrNull((element) => element.userId == userChat.userId) != null;
                if (check) {
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
                      arguments: ChatPageArguments(chatUser: userChat, isGroup: false, isDialog: false),
                    ),
                  ),
                );
              }
            },
            onLongPress: () {
              if (widget.pageType == PageType.NEW_GROUP) return;
              widget.pageType = PageType.NEW_GROUP;
              setState(() {});

              _participantsList.value.add(userChat);
              _participantsList.notifyListeners();
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 16,horizontal: 16)),
              backgroundColor: MaterialStateProperty.all<Color>(AppColor.white),
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
