  import 'dart:io';

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_demo_structure/core/db/app_db.dart';
  import 'package:flutter_demo_structure/main.dart';
  import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
  import 'package:flutter_demo_structure/util/firebase_chat_manager/constants/firestore_constants.dart';
  import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
  import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
  import 'package:flutter_demo_structure/values/colors.dart';
  import 'package:flutter_demo_structure/values/export.dart';
  import 'package:flutter_demo_structure/widget/base_app_bar.dart';
  import 'package:flutter_demo_structure/widget/image_picker_dialog.dart';
  import 'package:images_picker/images_picker.dart';
  import 'package:intl/intl.dart';

  class ChatPageArguments {
    final FirebaseChatUser chatUser;

    ChatPageArguments({required this.chatUser});
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
      _chatId = FirestoreConstants.getChatId(widget.arguments.chatUser.userId);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: BaseAppBar(
          showTitle: true,
          leadingIcon: true,
          title: this.widget.arguments.chatUser.userName,
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
                        style: TextStyle(color: AppColor.blackColor),
                      ),
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      width: 200,
                      decoration: BoxDecoration(color: AppColor.greyTealColor, borderRadius: BorderRadius.circular(8)),
                      margin: EdgeInsets.only(bottom: !messageChat.isLeftSide ? 20 : 10, right: 10),
                    )
                  : messageChat.messageType == SendMessageType.image.typeValue
                      // Image
                      ? Container(
                          child: OutlinedButton(
                            child: Material(
                              child: Image.network(
                                messageChat.mediaPath ?? '',
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
                                      'images/img_not_available.jpeg',
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
                              /*Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullPhotoPage(
                          url: messageChat.content,
                        ),
                      ),
                    );*/
                            },
                            style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                          ),
                          margin: EdgeInsets.only(bottom: !messageChat.isLeftSide ? 20 : 10, right: 10),
                        )
                      // Sticker
                      : Container(
                          child: Image.asset(
                            'images/${messageChat.mediaPath}.gif',
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
                              widget.arguments.chatUser.userImage ?? '',
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
                                return Icon(
                                  Icons.account_circle,
                                  size: 35,
                                  color: AppColor.greyColor,
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
                            child: Text(
                              messageChat.message??'',
                              style: TextStyle(color: Colors.white),
                            ),
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            width: 200,
                            decoration:
                                BoxDecoration(color: AppColor.primaryColor, borderRadius: BorderRadius.circular(8)),
                            margin: EdgeInsets.only(left: 10),
                          )
                        : messageChat.messageType == SendMessageType.image.typeValue
                            ? Container(
                                child: TextButton(
                                  child: Material(
                                    child: Image.network(
                                      messageChat.mediaPath??'',
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
                                          'images/img_not_available.jpeg',
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
                                    /*Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullPhotoPage(url: messageChat.content),
                                      ),
                                    );*/
                                  },
                                  style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                                ),
                                margin: EdgeInsets.only(left: 10),
                              )
                            : Container(
                                child: Image.asset(
                                  'images/${messageChat.mediaPath}.gif',
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
                  icon: Icon(Icons.image),
                  onPressed: _pickImage,
                  color: AppColor.primaryColor,
                ),
              ),
              color: Colors.white,
            ).visiblity(true),
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1),
                child: IconButton(
                  icon: Icon(Icons.face),
                  onPressed: null,
                  color: AppColor.primaryColor,
                ),
              ),
              color: Colors.white,
            ).visiblity(false),

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
                  icon: Icon(Icons.send),
                  onPressed: () => onSendMessage(textEditingController.text, SendMessageType.text.typeValue),
                  color: AppColor.primaryColor,
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
        ChatMessage sendMessageRequest = ChatMessage(
          message: content,
          messageType: type.toString(),
          chatId: _chatId,
          receiverId: widget.arguments.chatUser.userId,
          // mediaPath: _downloadUrl,
        );
        firebaseChatManager.sendMessage(sendMessageRequest, widget.arguments.chatUser);
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
