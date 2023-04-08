import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/home_page.dart';
import 'package:flutter_demo_structure/ui/home/user_list_page.dart';
import 'package:flutter_demo_structure/ui/navbar/navbar.dart';
import 'package:flutter_demo_structure/ui/web/chat_screen/chat_screen.dart';
import 'package:flutter_demo_structure/util/date_time_helper.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/util/utilities.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/extensions/context_ext.dart';
import 'package:flutter_demo_structure/values/style.dart';
import 'package:flutter_demo_structure/widget/base_app_bar.dart';
import 'package:flutter_demo_structure/widget/loading.dart';
import 'package:flutter_demo_structure/widget/text_form_filed.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocity_x/velocity_x.dart';

enum PageType { NEW_GROUP, EDIT_GROUP, USERS, ADD_PARTICIPANTS }

class NewGroupPage extends StatefulWidget {
  List<FirebaseChatUser> participantsList;
  final bool isGroupDetails;
  ChatMessage? groupDetails;
  PageType pageType;

  NewGroupPage({
    required this.participantsList,
    required this.isGroupDetails,
    required this.pageType,
    this.groupDetails,
    Key? key,
  }) : super(key: key);

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  String? _selectedImagePath;

  TextEditingController _groupNameController = TextEditingController();

  bool get _isGroupDetails => widget.isGroupDetails;
  ValueNotifier<bool> _showLoading = ValueNotifier<bool>(false);

  ChatMessage? get _groupDetails => widget.isGroupDetails ? widget.groupDetails : null;

  @override
  void initState() {
    super.initState();
    if (widget.pageType != PageType.NEW_GROUP) {
      _groupNameController.text = widget.groupDetails?.groupName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('widget.participantsList ${widget.participantsList}');
    if (widget.participantsList.isEmpty) _fetchUserDetails();
    return Scaffold(
      appBar: BaseAppBar(
        showTitle: true,
        leadingIcon: true,
        title: widget.pageType == PageType.NEW_GROUP ? 'New Group' : 'Edit group',
        action: [],
      ),
      floatingActionButton: buildFloatingAction(context),
      body: ValueListenableBuilder(
        valueListenable: _showLoading,
        builder: (BuildContext context, bool value, Widget? child) {
          return Loading(status: value, child: child!);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              20.verticalSpace,
              buildGroupImageView(),
              20.verticalSpace,
              AppTextField(
                controller: _groupNameController,
                label: 'Type your group subject here..',
                hint: 'Type your group subject here..',
                enabled: widget.pageType == PageType.NEW_GROUP,
              ),
              20.verticalSpace,
              buildParticipantsTitle(),
              20.verticalSpace,
              _buildParticipantsList(),
            ],
          ),
        ),
      ),
    );
  }

  Center buildGroupImageView() {
    return Center(
      child: kIsWeb
          ? Image.asset(
              Assets.imageImgNotAvailable,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
              errorBuilder: (context, object, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.group,
                      size: 100,
                      color: AppColor.greyColor,
                    ),
                  ),
                );
              },
            )
          : Image.file(
              File(_selectedImagePath ?? ''),
              fit: BoxFit.cover,
              width: 100,
              height: 100,
              errorBuilder: (context, object, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.group,
                      size: 100,
                      color: AppColor.greyColor,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Row buildParticipantsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        'Total Participants'.text.textStyle(textRegular).make(),
        widget.participantsList.length
            .toString()
            .text
            .textStyle(textBold.copyWith(color: AppColor.primaryColor))
            .make(),
      ],
    );
  }

  Expanded _buildParticipantsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.participantsList.length,
        itemBuilder: (context, index) {
          FirebaseChatUser userChat = widget.participantsList[index];
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
        },
      ),
    );
  }

  FloatingActionButton buildFloatingAction(BuildContext context) {
    return FloatingActionButton(
      child: Icon(
        (widget.pageType == PageType.NEW_GROUP) ? Icons.arrow_forward : Icons.add,
        color: AppColor.white,
      ),
      backgroundColor: AppColor.primaryColor,
      onPressed: () {
        if (widget.pageType == PageType.NEW_GROUP)
          _createGroupAndNavigate();
        else
          navigateAndAddParticipants();
        return;
      },
    );
  }

  Future<void> _createGroupAndNavigate() async {
    _showLoading.value = true;
    List<String?> participantsList = widget.participantsList.map((e) => e.userId).toList();
    participantsList.insert(0, appDB.currentUserId);

    ChatMessage sendMessageRequest = ChatMessage(
      messageType: SendMessageType.text.typeValue,
      chatId: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: generateUTC(DateTime.now().toUtc()),
      isGroup: true,
      groupName: _groupNameController.text.toString(),
      participants: participantsList,
    );

    // await FirebaseFirestore.instance.collection(FirebaseCollection.chat.name).doc().set(sendMessageRequest.toJson());
    await FirebaseFirestore.instance
        .collection(FirebaseCollection.recent_chat.name)
        .doc(sendMessageRequest.chatId)
        .set(sendMessageRequest.toJson());

    _showLoading.value = false;

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return (kIsWeb && context.width >= 1024) ? WebChatScreen() : MyBottomNavigationBar();
      },
    ), (route) => false);
  }

  Future<void> _fetchUserDetails() async {
    Stream<List<FirebaseChatUser>> stream = firebaseChatManager.getUsers(widget.groupDetails?.participants ?? []);

    debugPrint('==> stream ${stream.toList()}');
    widget.participantsList = [];
    await stream.forEach((element) {
      if (widget.participantsList.isEmpty) {
        debugPrint('Element $element');
        widget.participantsList = element;
        setState(() {});
      }
    });
  }

  Future<void> navigateAndAddParticipants() async {
    List<String> participantsListOld = widget.participantsList.map((e) => e.userId ?? '').toList();

    List<FirebaseChatUser>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserListPage(
          isForGroup: false,
          pageType: PageType.ADD_PARTICIPANTS,
          participantsList: participantsListOld,
        ),
      ),
    );

    if (result?.isNotEmpty ?? false) {
      debugPrint('RESULT => $result');
      List<String>? participantsList = result?.map((e) => e.userId ?? '').toList();

      participantsListOld.addAll(participantsList ?? []);

      debugPrint('participantsList $participantsList');

      await FirebaseFirestore.instance
          .collection(FirebaseCollection.recent_chat.name)
          .doc(widget.groupDetails?.chatId ?? '')
          .update({'participants': participantsListOld});

      widget.participantsList.addAll(result!);

      debugPrint('widget.participantsList ${widget.participantsList}');

      widget.groupDetails?.participants = participantsListOld;

      _fetchUserDetails();
    }
  }
}
