import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:gotms_chat/core/db/app_db.dart';
import 'package:gotms_chat/core/di/api/req_params.dart';
import 'package:gotms_chat/core/navigation/navigation_service.dart';
import 'package:gotms_chat/core/navigation/routes.dart';
import 'package:gotms_chat/main.dart';
import 'package:gotms_chat/util/date_time_helper.dart';
import 'package:gotms_chat/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:gotms_chat/util/firebase_chat_manager/constants/firestore_constants.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/chat_message.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/message_chat.dart';

class FirebaseChatManager {
  /// Logout User
  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    navigator.pushNamedAndRemoveUntil(RouteName.loginPage);
  }

  /*Future<int?> fetchUserId(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(FirebaseCollection.users.name)
        .orderBy('createdAt', descending: true)
        .limitToLast(1)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isEmpty) {
      debugPrint('ItS EMPTY');
      return 1;
    } else {
      debugPrint('==> Not empty ==> ${documents.last.data()}');
      FirebaseChatUser user = FirebaseChatUser.fromDocument(documents.last);

      if (user.userEmail == email)
        return Future.value((user.userId ?? 0));
      else
        return Future.value((user.userId ?? 0) + 1);
      // return Future.value(documents.last.data())
    }
  }*/

  /*
  * Firebase Login
  * */
  Future<User?> firebaseUserLogin(FirebaseChatUser user) async {
    try {
      User? firebaseUser = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: user.userEmail ?? '', password: user.password ?? 'password'))
          .user;

      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection(FirebaseCollection.users.name)
            .where(userId, isEqualTo: firebaseUser.uid)
            .get();

        final List<DocumentSnapshot> documents = result.docs;

        if (documents.isEmpty) {
          // Update data to server if new user
          user.userId = firebaseUser.uid;
          FirebaseFirestore.instance.collection(FirebaseCollection.users.name).doc(firebaseUser.uid).set(user.toJson());

          return Future.value(firebaseUser);
        } else {
          user.userId = firebaseUser.uid;
          return Future.value(firebaseUser);
        }
      } else {
        debugPrint('User Found Returning user');
        return Future.error('');
      }
    } on Exception catch (e) {
      debugPrint('Firebase No User Found $e');

      throw Exception('$e');

      ///SignUp the user into firebase
      return firebaseUserSignup(user);
    }
  }

  /*
  * Firebase SignUp
  * */
  Future<User?> firebaseUserSignup(FirebaseChatUser user) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: user.userEmail ?? '', password: user.password ?? 'password');

      debugPrint('### - Creating User ${user.toJson()}');

      user.userId = userCredential.user?.uid;

      FirebaseFirestore.instance
          .collection(FirebaseCollection.users.name)
          .doc(userCredential.user?.uid)
          .set(user.toJson());

      return Future.value(userCredential.user);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase No User Found $e');
      throw Exception('Something went wrong, Please try again later');
    }
  }

  /*
  * Get User Listing
  * */
  Stream<QuerySnapshot> getStreamFireStore(String pathCollection, int limit, String? textSearch,
      [List<String>? participantsList]) {
    debugPrint('### - getStreamFireStore $textSearch');
    debugPrint('### - participantsList $participantsList');
    debugPrint('### - _textSearch $textSearch');
    if (textSearch?.isNotEmpty ?? false) {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .where(FirestoreConstants.participants, whereNotIn: participantsList)
          .where(FirestoreConstants.user_name, isEqualTo: textSearch)
          .orderBy(FirestoreConstants.createdAt) // Replace 'fieldName' with the field you want to order by
          .snapshots();
    } else {
      return firebaseFirestore.collection(pathCollection).limit(limit).snapshots();
    }
  }

  Future<FirebaseChatUser>? getUserDetails(String userId) async {
    debugPrint('### - getUserDetails ${userId}');

    final QuerySnapshot result = await firebaseFirestore
        .collection(FirebaseCollection.users.name)
        .limit(1)
        .where(FirestoreConstants.userId, isEqualTo: userId)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isNotEmpty) {
      FirebaseChatUser messageChat = FirebaseChatUser.fromDocument(documents[0]);
      return Future.value(messageChat);
    }
    return Future.error('');
  }

  Future<void>? deleteDocument(String chatId) async {
    debugPrint('### - deleteDocument $chatId');
    final QuerySnapshot result = await firebaseFirestore
        .collection(FirebaseCollection.recent_chat.name)
        .where(FirestoreConstants.chatId, isEqualTo: chatId)
        .limit(1)
        .get();

    debugPrint('### - deleteDocument QuerySnapshot ${result.size}');

    final List<DocumentSnapshot> documents = result.docs;
    await firebaseFirestore.runTransaction((Transaction myTransaction) async {
      myTransaction.delete(documents[0].reference);
    });

    debugPrint('### - deleteDocument Success');
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdate) {
    debugPrint('#### updateDataFirestore ######');
    debugPrint('## collectionPath = $collectionPath');
    debugPrint('## docPath = $docPath');
    debugPrint('##########');

    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
  }

  /*
  * Fetch Chat Stream
  * */
  Stream<QuerySnapshot> getChatStream(String chatId, int limit) {
    debugPrint('#### getChatStream ######');
    debugPrint('## GetChatStream = ${FirebaseCollection.chat.name}');
    debugPrint('## chatId = $chatId');
    debugPrint('##########');
    return firebaseFirestore
        .collection(FirebaseCollection.chat.name)
        .where(FirestoreConstants.chatId, isEqualTo: chatId)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .limit(limit)
        .snapshots();
  }

  /*
  * Fetch Chat Stream
  * */
  Stream<List<FirebaseChatUser>> getUsers(List<String?> participantsList) {
    debugPrint('#### Fetch Users ######');
    debugPrint('## getUsers = ${FirebaseCollection.users.name}');
    debugPrint('## participantsList = $participantsList');
    debugPrint('##########');
    Stream<QuerySnapshot> stream = firebaseFirestore
        .collection(FirebaseCollection.users.name)
        .where(FirestoreConstants.userId, whereIn: participantsList)
        // .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots();

    debugPrint('Stream $stream');
    return stream.map((qShot) => qShot.docs
        .map((document) => FirebaseChatUser(
              userName: document['user_name'],
              userId: document['user_id'],
            ))
        .toList());
  }

  /*
  * Fetch Recent Chat Stream
  * */
  Stream<QuerySnapshot> getRecentChatStream(int limit, String textSearch, bool fetchOnlyGroups) {
    debugPrint('#### getRecentChatStream ######');
    debugPrint('## GetRecentChatStream = ${FirebaseCollection.recent_chat.name} ${appDB.user?.userId}');
    debugPrint('## fetchOnlyGroups = $fetchOnlyGroups');
    debugPrint('## textSearch = $textSearch');
    debugPrint('## fetchOnlyGroups = ${firebaseFirestore
        .collection(FirebaseCollection.recent_chat.name)
        .where(FirestoreConstants.participants, arrayContains: appDB.user?.userId)
        .where(FirestoreConstants.receiver_name, isEqualTo: textSearch)
        .where(FirestoreConstants.group_name, isEqualTo: textSearch)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots().length}');
    debugPrint('##########');
    if (textSearch.isNotEmpty) {
      if (fetchOnlyGroups) {
        return firebaseFirestore
            .collection(FirebaseCollection.recent_chat.name)
            .where(FirestoreConstants.participants, arrayContains: appDB.user?.userId)
            .where(FirestoreConstants.group_name, isEqualTo: textSearch)
            .where(FirestoreConstants.isGroup, isEqualTo: true)
            .orderBy(FirestoreConstants.createdAt, descending: true)
            // .limit(limit)
            .snapshots();
      } else {
        return firebaseFirestore
            .collection(FirebaseCollection.recent_chat.name)
            .where(FirestoreConstants.participants, arrayContains: appDB.user?.userId)
            .where(FirestoreConstants.receiver_name, isEqualTo: textSearch)
            .where(FirestoreConstants.group_name, isEqualTo: textSearch)
            .orderBy(FirestoreConstants.createdAt, descending: true)
            .limit(limit)
            .snapshots();
      }
    } else {
      if (fetchOnlyGroups) {
        debugPrint('EERRRRR [===> ');
        debugPrint(
            '${firebaseFirestore.collection(FirebaseCollection.recent_chat.name).where(FirestoreConstants.participants, arrayContains: appDB.user?.userId).where(FirestoreConstants.isGroup, isEqualTo: true).where(FirestoreConstants.isGroup, isNotEqualTo: null) // Add this line to filter out null values
                .orderBy(FirestoreConstants.createdAt, descending: true) // Order the results by createdAt
                .limit(limit).snapshots().length.then((value) => debugPrint('VALUE ==$value'))}');
        return firebaseFirestore
            .collection(FirebaseCollection.recent_chat.name)
            .where(FirestoreConstants.participants, arrayContains: appDB.user?.userId)
            .where(FirestoreConstants.isGroup, isEqualTo: true)
            .where(FirestoreConstants.isGroup, isNotEqualTo: null) // Add this line to filter out null values
            // .orderBy(FirestoreConstants.createdAt, descending: false) // Order the results by createdAt
            .limit(limit)
            .snapshots();
      } else {
        return firebaseFirestore
            .collection(FirebaseCollection.recent_chat.name)
            .where(FirestoreConstants.participants, arrayContains: appDB.user?.userId)
            .orderBy(FirestoreConstants.createdAt, descending: true)
            .limit(limit)
            .snapshots();
      }
    }
  }

  /*
  * Send Chat Message
  * */
  void sendMessageOld(String content, int type, String groupChatId, String currentUserId, String peerId) {
    debugPrint('#### sendMessage ######');
    debugPrint('## content = $content');
    debugPrint('## type = $type');
    debugPrint('## currentUserId = $currentUserId');
    debugPrint('## peerId = $peerId');
    debugPrint('##########');
    DocumentReference documentReference = firebaseFirestore
        .collection(FirebaseCollection.chat.name)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        transaction.set(
          documentReference,
          messageChat.toJson(),
        );
      },
    );
  }

  Future<void> sendMessage(
    ChatMessage messageChat,
    FirebaseChatUser? receiverUser,
  ) async {
    debugPrint('#### sendMessage ######');
    debugPrint('## content = ${messageChat.message}');
    debugPrint('## type = ${messageChat.messageType}');
    debugPrint('## receiverId = ${messageChat.receiverId}');

    ChatMessage? recentChat = await getRecentChatDetails(messageChat.chatId ?? '');

    messageChat
      ..senderId = appDB.currentUserId
      ..createdAt = generateUTC(DateTime.now().toUtc())
      ..chatId = messageChat.chatId
      ..participants = [appDB.currentUserId, receiverUser?.userId]
      ..receiverProfile = receiverUser?.userImage
      ..receiverName = receiverUser?.userName
      ..receiverId = receiverUser?.userId
      ..senderName = appDB.user?.userName
      ..openChatIds = recentChat?.openChatIds
      ..senderProfile = appDB.user?.userImage;

    ///INITIALLY FILL THE DATA
    if (messageChat.unreadCountList == null) messageChat.unreadCountList = Map();

    messageChat.unreadCountList?[FirestoreConstants.getUnreadCountKey(appDB.user?.userId)] = 0;

    messageChat.participants?.where((element) => element != appDB.user?.userId).forEach((e) {
      messageChat.unreadCountList?[FirestoreConstants.getUnreadCountKey(e)] = 1;
    });

    ///MODIFY UNREAD COUNT IF AVAILABLE
    recentChat?.unreadCountList?.entries
        .where((e) => e.key != FirestoreConstants.getUnreadCountKey(appDB.user?.userId))
        .forEach((element) {
      messageChat.unreadCountList?[element.key] = (element.value) + 1;
    });

    //Add message in chat collection
    await FirebaseFirestore.instance.collection(FirebaseCollection.chat.name).doc().set(messageChat.toJson());

    //Add message in recent chat collection
    await updateRecentChat(messageChat);
  }

  Future<void> sendGroupMessage(
    ChatMessage messageChat,
    FirebaseChatUser? receiverUser,
  ) async {
    debugPrint('#### sendMessage ######');
    debugPrint('## content = ${messageChat.message}');
    debugPrint('## type = ${messageChat.messageType}');
    debugPrint('## receiverId = ${messageChat.receiverId}');
    debugPrint('## SenderName = ${appDB.user?.userName}');

    ChatMessage? recentChat = await getRecentChatDetails(messageChat.chatId ?? '');

    messageChat
      ..senderId = appDB.currentUserId
      ..createdAt = generateUTC(DateTime.now().toUtc())
      ..chatId = messageChat.chatId
      ..participants =
          (messageChat.isGroup ?? false) ? messageChat.participants : [appDB.currentUserId, receiverUser?.userId]
      ..receiverProfile = receiverUser?.userImage
      ..receiverName = receiverUser?.userName
      ..receiverId = receiverUser?.userId
      ..senderName = appDB.user?.userName
      ..openChatIds = recentChat?.openChatIds
      ..senderProfile = appDB.user?.userImage
      ..isGroup = messageChat.isGroup
      ..groupName = messageChat.groupName;

    ///INITIALLY FILL THE DATA
    if (messageChat.unreadCountList == null) messageChat.unreadCountList = Map();

    messageChat.unreadCountList?[FirestoreConstants.getUnreadCountKey(appDB.user?.userId)] = 0;

    messageChat.participants?.where((element) => element != appDB.user?.userId).forEach((e) {
      messageChat.unreadCountList?[FirestoreConstants.getUnreadCountKey(e)] = 1;
    });

    ///MODIFY UNREAD COUNT IF AVAILABLE
    recentChat?.unreadCountList?.entries
        .where((e) => e.key != FirestoreConstants.getUnreadCountKey(appDB.user?.userId))
        .forEach((element) {
      messageChat.unreadCountList?[element.key] = (element.value) + 1;
    });

    //Add message in chat collection
    await FirebaseFirestore.instance.collection(FirebaseCollection.chat.name).doc().set(messageChat.toJson());

    //Add message in recent chat collection
    await updateRecentChat(messageChat);
  }

  ///GET RECENT CHAT LISTING
  Future<ChatMessage?> getRecentChatDetails(String chatId) async {
    try {
      DocumentSnapshot recentChatDetails =
          await FirebaseFirestore.instance.collection(FirebaseCollection.recent_chat.name).doc(chatId).get();

      return Future.value(ChatMessage.toDocumentToClass(recentChatDetails));
    } catch (e) {
      return Future.value(null);
    }
  }

  Future<void> updateRecentChat(ChatMessage recentChat) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection.recent_chat.name)
        .doc(recentChat.chatId)
        .set(recentChat.toJson());
  }

  ///GET RECENT CHAT UNREAD COUNTS
  Stream<QuerySnapshot> getRecentChatUnreadCounts() {
    return firebaseFirestore
        .collection(FirebaseCollection.recent_chat.name)
        .where(FirestoreConstants.participants, arrayContains: appDB.user?.userId)
        .snapshots();
  }

  /*
  * Firebase Update User Details
  * */
  void removeUnreadCount(String chatId) {
    debugPrint('here we are remove unread counts');
    try {
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          FirebaseFirestore.instance.collection(FirebaseCollection.recent_chat.name).doc(chatId).update(
                Map.of(
                  {
                    FirestoreConstants.unreadCountList + '.${FirestoreConstants.getUnreadCountKey(appDB.user?.userId)}':
                        0
                  },
                ),
              );
        },
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase No User Found $e');
      //throw Exception('Something went wrong, Please try again later');
    }
  }

  ///GET RECENT CHAT
  Stream<DocumentSnapshot<Map<String, dynamic>>> getRecentChatDocStream(String chatId) {
    return firebaseFirestore.collection(FirebaseCollection.recent_chat.name).doc(chatId).snapshots();
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  UploadTask uploadFileBytes(Uint8List? image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putData(image!, SettableMetadata(contentType: 'image/jpeg'));
    return uploadTask;
  }

  Future<void> updateDeviceToken(String? docId, [String? token]) async {
    var collection = FirebaseFirestore.instance.collection(FirebaseCollection.users.name);
    collection
        .doc(docId)
        .update({'device_token': token ?? appDB.fcmToken}) // <-- Updated data
        .then((_) => debugPrint('Success'))
        .catchError((error) => debugPrint('Failed: $error'));
  }
}
