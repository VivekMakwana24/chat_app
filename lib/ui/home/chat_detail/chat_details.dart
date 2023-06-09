import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/new_group/new_group_page.dart';
import 'package:flutter_demo_structure/util/date_time_helper.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firestore_constants.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/widget/base_app_bar.dart';
import 'package:flutter_demo_structure/widget/image_picker_dialog.dart';
import 'package:flutter_demo_structure/widget/image_viewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:images_picker/images_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatPageArguments {
  final FirebaseChatUser chatUser;
  final bool isGroup;
  final String? groupName;
  final String? chatId;
  final ChatMessage? recentChat;
  final bool isDialog;

  ChatPageArguments({
    required this.chatUser,
    required this.isGroup,
    required this.isDialog,
    this.groupName,
    this.chatId,
    this.recentChat,
  });
}

class ChatDetailsPage extends StatefulWidget {
  final ChatPageArguments arguments;

  const ChatDetailsPage({Key? key, required this.arguments}) : super(key: key);

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> with MediaPickerListener, SingleTickerProviderStateMixin {
  /*
     * *****************************************************
     * Class members
     * *****************************************************
     */

  // region Class members
  late String currentUserId;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";

  File? imageFile;
  ValueNotifier<bool> showLoading = ValueNotifier<bool>(false);
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  String _chatId = '';

  MediaPickerHandler? _mediaPickerHandler;

  bool get _isGroup => widget.arguments.isGroup;

  String get _groupName => widget.arguments.groupName ?? '';

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
    _mediaPickerHandler = MediaPickerHandler(
      this,
      AnimationController(duration: Duration(milliseconds: 100), vsync: this),
    );
    _mediaPickerHandler?.init();

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    // readLocal();
    debugPrint('==>');
    debugPrint('_isGroup $_isGroup');
    debugPrint('groupName $_groupName');
    if (_isGroup) {
      _chatId = widget.arguments.chatId ?? '';
    } else {
      _chatId = FirestoreConstants.getChatId(widget.arguments.chatUser.userId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    debugPrint('didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    if (_isGroup) {
      _chatId = widget.arguments.chatId ?? '';
    } else {
      _chatId = FirestoreConstants.getChatId(widget.arguments.chatUser.userId);
    }

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: BaseAppBar(
        showTitle: true,
        centerTitle: false,
        leadingIcon: widget.arguments.isDialog ? false : true,
        // title: _isGroup ? this.widget.arguments.chatUser.userName : _groupName,
        titleWidget: Text(
          _isGroup ? (_groupName ?? '') : (this.widget.arguments.chatUser.userName ?? ''),
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorData.black,
          ),
        ).addGestureTap(
          () {
            if (!_isGroup) return;
            debugPrint('Navigate to group details');

            if (kIsWeb && widget.arguments.isDialog)
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
                        width: context.width * 0.6,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: NewGroupPage(
                            participantsList: [],
                            isGroupDetails: true,
                            pageType: PageType.EDIT_GROUP,
                            groupDetails: widget.arguments.recentChat,
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
                    participantsList: [],
                    isGroupDetails: true,
                    pageType: PageType.EDIT_GROUP,
                    groupDetails: widget.arguments.recentChat,
                  ),
                ),
              );
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages
                buildListMessage(),

                // Sticker
                // isShowSticker ? buildSticker() : SizedBox.shrink(),

                // Input content
                buildInput(),
              ],
            ),

            // Loading
            buildLoading()
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
  Widget buildLoading() {
    return Positioned(
      child: ValueListenableBuilder(
        valueListenable: showLoading,
        builder: (BuildContext context, bool isLoading, Widget? child) {
          return isLoading ? CircularProgressIndicator.adaptive() : SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: _chatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: firebaseChatManager.getChatStream(_chatId, _limit),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  //Remove unread count
                  firebaseChatManager.removeUnreadCount(_chatId);

                  if (listMessage.length > 0) {
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return Center(child: Text("No message here yet..."));
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                color: AppColor.primaryColor,
              ),
            ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      ChatMessage messageChat = ChatMessage.toDocumentToClass(document);
      // MessageChat messageChat = MessageChat.fromDocument(document);
      if (!messageChat.isLeftSide) {
        // Right (my message)
        return Row(
          children: <Widget>[
            messageChat.messageType == SendMessageType.text.typeValue
                // Text
                ? Container(
                    child: Text(
                      messageChat.message ?? '',
                      style: textRegular14.copyWith(color: AppColor.white, fontSize: 16.sm),
                    ),
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(color: AppColor.primaryColor, borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(bottom: !messageChat.isLeftSide ? 20 : 10, right: 10),
                  )
                : messageChat.messageType == SendMessageType.image.typeValue
                    // Image
                    ? Container(
                        child: OutlinedButton(
                          child: Material(
                            child: Image.network(
                              messageChat.message ?? '',
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.greyTealColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
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
                                return Material(
                                  child: Image.asset(
                                    Assets.imageImgNotAvailable,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                );
                              },
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewerWidget(
                                  imageUrl: messageChat.message ?? '',
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                        ),
                        margin: EdgeInsets.only(bottom: !messageChat.isLeftSide ? 20 : 10, right: 10),
                      )
                    // Sticker
                    : Container(
                        child: Image.asset(
                          'images/${messageChat.message}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(bottom: !messageChat.isLeftSide ? 20 : 10, right: 10),
                      ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  messageChat.isLeftSide
                      ? Material(
                          child: Image.network(
                            _isGroup ? messageChat.getChatIcon ?? '' : widget.arguments.chatUser.userImage ?? '',
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.primaryColor,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return SvgPicture.asset(
                                Assets.svgsUserIcon,
                                height: 35.sm,
                                width: 35.sm,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(width: 35),
                  messageChat.messageType == SendMessageType.text.typeValue
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isGroup) ...[
                                Text(
                                  messageChat.senderName ?? '',
                                  style: textBold.copyWith(
                                    fontSize: 12,
                                    color: AppColor.primaryColorDark,
                                  ),
                                ),
                                5.h.VBox,
                              ],
                              Text(
                                messageChat.message ?? '',
                                style: textRegular14.copyWith(fontSize: 16.sm,fontWeight: FontWeight.w300,color: AppColor.blackColor.withOpacity(0.8)),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                          width: 200,
                          decoration: BoxDecoration(
                            color: AppColor.lightPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: EdgeInsets.only(left: 10),
                        )
                      : messageChat.messageType == SendMessageType.image.typeValue
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: Image.network(
                                    messageChat.message ?? '',
                                    loadingBuilder:
                                        (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: AppColor.greyTealColor,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColor.greyTealColor,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, object, stackTrace) => Material(
                                      child: Image.asset(
                                        Assets.imageImgNotAvailable,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewerWidget(
                                        imageUrl: messageChat.message ?? '',
                                      ),
                                    ),
                                  );
                                },
                                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                              ),
                              margin: EdgeInsets.only(left: 10),
                            )
                          : Container(
                              child: Image.asset(
                                'images/${messageChat.message}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(bottom: !messageChat.isLeftSide ? 20 : 10, right: 10),
                            ),
                ],
              ),

              // Time
              /*isLastMessageLeft(index)
                    ? Container(
                        child: Text(
                          DateFormat('dd MMM kk:mm')
                              .format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageChat.createdAt))),
                          style: TextStyle(color: AppColor.greyColor, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                        margin: EdgeInsets.only(left: 50, top: 5, bottom: 5),
                      )
                    : SizedBox.shrink()*/
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: SvgPicture.asset(Assets.svgsGallery),
                onPressed: () async {
                  if (kIsWeb) {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null) {
                      Uint8List? fileBytes = result.files.first.bytes;
                      String fileName = result.files.first.name;
                      String? fileExt = result.files.first.extension;
                      debugPrint('FILE --> ${result.files.first.bytes}');
                      if (result.files.first.bytes != null) {
                        // Upload file
                        VxToast.show(context, msg: 'Uploading...');

                        _uploadFileBytes(fileBytes, fileName, fileExt);
                      }
                    }
                    // if (result != null) {
                    //   PlatformFile file = result.files.first;
                    //   debugPrint('FILE --> ${file.name}');
                    //   debugPrint('FILE --> ${file.bytes}');
                    //   if (file.bytes != null) {
                    //     imageFile = File.fromRawPath(file.bytes!);
                    //     if (imageFile != null) {
                    //       ///Call Upload File
                    //       _uploadFile();
                    //     }
                    //   }
                    // }
                  } else {
                    _pickImage();
                  }
                },
                color: AppColor.primaryColorDark,
              ),
            ),
            color: Colors.white,
          ).visiblity(true),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, SendMessageType.text.typeValue);
                },
                style: TextStyle(color: AppColor.primaryColor, fontSize: 15),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: AppColor.greyColor),
                ),
                focusNode: focusNode,
                autofocus: true,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: SvgPicture.asset(Assets.svgsSend),
                onPressed: () => onSendMessage(textEditingController.text, SendMessageType.text.typeValue),
                color: AppColor.primaryColorDark,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColor.greyTealColor, width: 0.5)),
        color: Colors.white,
      ),
    );
  }

  void onSendMessage(String content, String type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      if (_isGroup) {
        ChatMessage sendMessageRequest = ChatMessage(
          message: content,
          messageType: type.toString(),
          chatId: _chatId,
          createdAt: generateUTC(DateTime.now().toUtc()),
          isGroup: true,
          groupName: widget.arguments.recentChat?.groupName,
          participants: widget.arguments.recentChat?.participants,
        );

        firebaseChatManager.sendGroupMessage(sendMessageRequest, widget.arguments.chatUser);
      } else {
        ChatMessage sendMessageRequest = ChatMessage(
          message: content,
          messageType: type.toString(),
          chatId: _chatId,
          receiverId: widget.arguments.chatUser.userId,
          // mediaPath: _downloadUrl,
        );

        firebaseChatManager.sendMessage(sendMessageRequest, widget.arguments.chatUser);
      }

      if (listScrollController.hasClients) {
        listScrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      SnackBar(
        content: Text('Nothing to send'),
        backgroundColor: AppColor.greyColor,
      );
    }
  }

  // endregion

  /*
      * *****************************************************
      * Functions
      * *****************************************************
      * */

  // region Functions observers
  void readLocal() {
    currentUserId = appDB.currentUserId;

    String peerId = widget.arguments.chatUser.userId ?? '';
    if (currentUserId.compareTo(peerId) > 0) {
      _chatId = '$currentUserId-$peerId';
    } else {
      _chatId = '$peerId-$currentUserId';
    }

    firebaseChatManager.updateDataFirestore(
      FirebaseCollection.chat.name,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  void _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future _uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = firebaseChatManager.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      showLoading.value = false;
      setState(() {
        onSendMessage(imageUrl, SendMessageType.image.typeValue);
      });
    } on FirebaseException catch (e) {
      showLoading.value = false;
    }
  }

  Future _uploadFileBytes(Uint8List? fileBytes, String fileName, String? fileExt) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = firebaseChatManager.uploadFileBytes(fileBytes, '$fileName.$fileExt');
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      showLoading.value = false;
      setState(() {
        onSendMessage(imageUrl, SendMessageType.image.typeValue);
      });
    } on FirebaseException catch (e) {
      showLoading.value = false;
    }
  }

  Future _pickImage() async {
    _mediaPickerHandler?.showDialog(context, PickFileType.image);
  }

  @override
  void pickedFiles(List<Media?>? _pickedFilesList, PickFileType pickFileType) {
    if (_pickedFilesList?.isNotEmpty ?? false) {
      imageFile = File(_pickedFilesList?.first?.path ?? '');
      if (imageFile != null) {
        ///Call Upload File
        _uploadFile();
      }
    }
  }

// endregion
}
