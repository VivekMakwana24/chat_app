import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gotms_chat/core/db/app_db.dart';
import 'package:gotms_chat/core/navigation/routes.dart';
import 'package:gotms_chat/generated/assets.dart';
import 'package:gotms_chat/main.dart';
import 'package:gotms_chat/ui/home/user_list_page.dart';
import 'package:gotms_chat/util/date_time_helper.dart';
import 'package:gotms_chat/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:gotms_chat/util/firebase_chat_manager/constants/firestore_constants.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/chat_message.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:gotms_chat/util/utilities.dart';
import 'package:gotms_chat/values/colors.dart';
import 'package:gotms_chat/values/colors_new.dart';
import 'package:gotms_chat/values/extensions/widget_ext.dart';
import 'package:gotms_chat/values/style.dart';
import 'package:gotms_chat/widget/base_app_bar.dart';
import 'package:gotms_chat/widget/button_widget.dart';
import 'package:gotms_chat/widget/const.dart';
import 'package:gotms_chat/widget/custom_alert_dialog.dart';
import 'package:gotms_chat/widget/loading.dart';
import 'package:gotms_chat/widget/text_form_filed.dart';
import 'package:velocity_x/velocity_x.dart';

enum PageType { NEW_GROUP, EDIT_GROUP, USERS, ADD_PARTICIPANTS }

class NewGroupPage extends StatefulWidget {
  List<FirebaseChatUser> participantsList;
  final bool isGroupDetails;
  ChatMessage? groupDetails;
  PageType pageType;
  VoidCallback? onPopped;

  NewGroupPage({
    required this.participantsList,
    required this.isGroupDetails,
    required this.pageType,
    this.groupDetails,
    this.onPopped,
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
  ValueNotifier<bool> _groupNameChanged = ValueNotifier<bool>(false);

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
    debugPrint('widget.groupDetails?.systemGenerated ${widget.groupDetails?.systemGenerated}');
    widget.groupDetails?.systemGenerated ??= false;
    if (widget.participantsList.isEmpty) _fetchUserDetails();
    return Scaffold(
      appBar: BaseAppBar(
        showTitle: true,
        leadingIcon: true,
        title: widget.pageType == PageType.NEW_GROUP ? 'New Group' : 'Edit group',
        action: [],
      ),
      floatingActionButton: buildFloatingAction(context).visiblity(
        !(widget.groupDetails?.systemGenerated ?? false) || widget.pageType == PageType.NEW_GROUP,
      ),
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
              // buildGroupImageView(),
              // 20.verticalSpace,
              AppTextField(
                controller: _groupNameController,
                label: 'Type your group subject here..',
                hint: 'Type your group subject here..',
                onChanged: (p0) {
                  _groupNameChanged.value = widget.groupDetails?.groupName != _groupNameController.text.trim();
                  _groupNameChanged.notifyListeners();
                },
                enabled: widget.pageType == PageType.NEW_GROUP || !(widget.groupDetails?.systemGenerated ?? true),
              ),

              if (!(widget.groupDetails?.systemGenerated ?? true) && widget.pageType == PageType.EDIT_GROUP) ...[
                10.verticalSpace,
                ValueListenableBuilder(
                  valueListenable: _groupNameChanged,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return Visibility(visible: value, child: child!);
                  },
                  child: SizedBox(
                    width: 100,
                    child: AppButton(
                      'Update',
                      () async {
                        await firebaseChatManager.updateDataFirestore(
                          FirebaseCollection.recent_chat.name,
                          widget.groupDetails?.chatId ?? '',
                          {
                            FirestoreConstants.group_name: _groupNameController.text.trim(),
                          },
                        );
                        widget.groupDetails?.groupName = _groupNameController.text.trim();
                        _groupNameChanged.value = false;
                      },
                      height: 30,
                      padding: 10,
                    ),
                  ),
                ),
              ],

              20.verticalSpace,
              buildParticipantsTitle(),
              20.verticalSpace,
              _buildParticipantsList(),
              20.verticalSpace,

              Container(
                margin: EdgeInsets.symmetric(horizontal: 100),
                child: AppButton(
                  'Delete Group',
                  height: 45.h,
                  () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomAlertDialog(
                          title: 'Delete group?',
                          subTitle:
                              'Are you sure you want to delete this group, You will lose all the messages related to this?',
                          buttonOkText: 'Yes',
                          buttonCancelText: 'No',
                          onTapOkCallback: () async {
                            Navigator.pop(context, true);
                            await Future.delayed(Duration(seconds: 1));
                            await firebaseChatManager.deleteDocument(widget.groupDetails?.chatId ?? '');
                            debugPrint('===>> DELETE DELETE');
                            if (widget.onPopped != null) widget.onPopped!();
                          },
                        );
                      },
                    );
                  },
                  buttonColor: true,
                  color: ColorData.red,
                ),
              ).visiblity(
                !(widget.groupDetails?.systemGenerated ?? false) && widget.pageType == PageType.EDIT_GROUP,
              ),

              20.verticalSpace,
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
          return TextButton(
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
                              height: 40.spMin,
                              width: 40.spMin,
                            );
                          },
                        )
                      : SvgPicture.asset(
                          Assets.svgsUserIcon,
                          height: 40.spMin,
                          width: 40.spMin,
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
                if (userChat.userId != appDB.user?.userId && !(widget.groupDetails?.systemGenerated ?? true))
                  Icon(
                    Icons.close,
                    color: Colors.red,
                  ).addGestureTap(() {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: '',
                      builder: (context) {
                        return CustomAlertDialog(
                          title: 'Remove ${userChat.userName}?',
                          subTitle: 'Are you sure you want to remove ${userChat.userName} from the group?',
                          buttonOkText: 'Yes',
                          buttonCancelText: 'No',
                          onTapOkCallback: () {
                            widget.participantsList.remove(userChat);

                            final List<String?> updatedParticipants =
                                widget.participantsList.map((element) => element.userId).toList();

                            firebaseChatManager.updateDataFirestore(
                              FirebaseCollection.recent_chat.name,
                              widget.groupDetails?.chatId ?? '',
                              {
                                FirestoreConstants.participants: updatedParticipants,
                              },
                            );
                            // Navigator.pop(context);
                            showSuccessMessage('User Removed');
                            setState(() {});
                          },
                        );
                      },
                    );
                  }),
              ],
            ),
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor.white),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 16))),
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
    Navigator.pushNamedAndRemoveUntil(context, RouteName.webPage, (route) => false);
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
