import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

class NotificationsBloc {
  NotificationsBloc._internal();

  static final NotificationsBloc instance = NotificationsBloc._internal();

  final StreamController<LocalNotification> _notificationsStreamController =
      StreamController<LocalNotification>();

  Stream<LocalNotification> get notificationsStream {
    return _notificationsStreamController.stream;
  }

  void newNotification(LocalNotification notification) {
    debugPrint(jsonEncode(notification.data));
    _notificationsStreamController.sink.add(notification);
  }

  void dispose() {
    _notificationsStreamController?.close();
  }
}

class LocalNotification {
  final String type;
  final Map data;

  LocalNotification(this.type, this.data);
}
