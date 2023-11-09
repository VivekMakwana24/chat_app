import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:gotms_chat/main.dart';

class AlgoliaService {
  final StreamController<AlgoliaQuerySnapshot> _controller = StreamController<AlgoliaQuerySnapshot>.broadcast();

  Stream<AlgoliaQuerySnapshot> get algoliaStream => _controller.stream;

  final StreamController<AlgoliaQuerySnapshot> _recentChatcontroller =
      StreamController<AlgoliaQuerySnapshot>.broadcast();

  Stream<AlgoliaQuerySnapshot> get recentChatControllerAlgoliaStream => _recentChatcontroller.stream;

  // Function to update the stream with new AlgoliaQuerySnapshot
  void updateAlgoliaSnapshot(AlgoliaQuerySnapshot snapshot) {
    _controller.add(snapshot);
  }

  // Function to update the stream with new AlgoliaQuerySnapshot
  void updateAlgoliaSnapshotRecentChat(AlgoliaQuerySnapshot snapshot) {
    _recentChatcontroller.add(snapshot);
  }

  // Close the stream controller when it's no longer needed
  void dispose() {
    _controller.close();
    _recentChatcontroller.close();
  }

  /*Future<void> uploadUserDataToAlgolia(Map<String, dynamic> userData) async {
    final index = algolia.instance.index('users');
    await index.addObject(userData);
  }*/

  Future<void> uploadChatDataToAlgolia(Map<String, dynamic> chatData) async {
    final index = algolia.instance.index('recent_chat');
    await index.addObject(chatData);
  }
}
