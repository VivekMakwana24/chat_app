import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getVerboseDateTimeRepresentation(String dateTimes) {
  DateFormat dateFormat = DateFormat("dd MMM, yyyy · hh:mm a");
  DateTime dateTime = dateFormat.parse(dateTimes);
  DateTime now = DateTime.now();
  DateTime justNow = now.subtract(Duration(minutes: 1));
  DateTime localDateTime = dateTime.toLocal();

  if (!localDateTime.difference(justNow).isNegative) {
    return 'Just now';
  }

  String roughTimeString = DateFormat('jm').format(dateTime);

  if (localDateTime.day == now.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return roughTimeString;
  }

  DateTime yesterday = now.subtract(Duration(days: 1));

  if (localDateTime.day == yesterday.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return 'Yesterday, ' + roughTimeString;
  }

  if (now.difference(localDateTime).inDays < 4) {
    String weekday = DateFormat('EEEE').format(localDateTime);

    return '$weekday, $roughTimeString';
  }

  return '${DateFormat('yMd').format(dateTime)}, $roughTimeString';
}

extension StringX on String {
  String? getTime(String outFormat) {
    var dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(this, true);
    var dateLocal = dateTime.toLocal();
  }

  String? timeFromStamp({String outFormat = "hh:mm a"}) {
    try {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(this) * 1000);

      return DateFormat(outFormat).format(dateTime);
    } catch (error) {
      debugPrint("DateTimeHelper_timeFromStamp");
      debugPrint(error.toString());
    }
  }

  String timeAgoFromStamp() {
    DateTime timeStamp = DateTime.fromMillisecondsSinceEpoch(int.parse(this) * 1000);
    return '${DateFormat('dd MMM yyyy').format(timeStamp)}';

    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = timeStamp.toLocal();

    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }

    String roughTimeString = DateFormat('jm').format(timeStamp);

    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(Duration(days: 1));

    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'Yesterday, ' + roughTimeString;
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);

      return '$weekday, $roughTimeString';
    }

    return '${DateFormat('dd MMM yyyy').format(timeStamp)}';
  }
  DateTime? formatDateTimeToLocalDate(
      {String inFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS", String outFormat = 'MM/dd/yy HH:mm'}) {
    try {
      var dateTime = DateFormat(inFormat).parse(this, true);
      return dateTime.toLocal();
    } catch (error) {
      debugPrint('DateTimeHelper_timeFromStamp');
      debugPrint(error.toString());
    }
    return null;
  }

  String? formatDateTime(
      {String inFormat = "yyyy-MM-dd hh:mm:ss", String outFormat = "dd MMM, yyyy"}) {
    try {
      var dateTime = DateFormat(inFormat).parse(this);
      return DateFormat(outFormat).format(dateTime);
    } catch (error) {
      debugPrint("DateTimeHelper_timeFromStamp");
      debugPrint(error.toString());
    }
  }

  String? convertToAgoWithTimeStamp({String? text = ''}) {
    DateTime input = DateTime.fromMillisecondsSinceEpoch(
      int.parse(this),
    );

    Duration diff = DateTime.now().difference(input);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y${diff.inDays == 1 ? '' : ''} $text';
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()}w${diff.inDays == 1 ? '' : ''} $text';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d${diff.inDays == 1 ? '' : ''} $text';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h${diff.inHours == 1 ? '' : ''} $text';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}min${diff.inMinutes == 1 ? '' : ''} $text';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds}sec${diff.inSeconds == 1 ? '' : ''} $text';
    } else {
      return 'Just now';
    }
  }

  String? convertToAgo({String inFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS", String text = ''}) {
    try {
      DateTime input = DateFormat(inFormat).parse(this, true);
      Duration diff = DateTime.now().difference(input);
      if (diff.inDays > 365) {
        return '${(diff.inDays / 365).floor()}y${diff.inDays == 1 ? '' : ''} $text';
      } else if (diff.inDays > 7) {
        return '${(diff.inDays / 7).floor()}w${diff.inDays == 1 ? '' : ''} $text';
      } else if (diff.inDays >= 1) {
        return '${diff.inDays}d${diff.inDays == 1 ? '' : ''} $text';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours}h${diff.inHours == 1 ? '' : ''} $text';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes}min${diff.inMinutes == 1 ? '' : ''} $text';
      } else if (diff.inSeconds >= 1) {
        return '${diff.inSeconds}sec${diff.inSeconds == 1 ? '' : ''} $text';
      } else {
        return 'Just now';
      }
    } catch (e) {
      debugPrint('error while parsing $e');
      return null;
    }
  }
}

String generateUTC(DateTime date) {
  final duration = date.timeZoneOffset;
  if (duration.isNegative) {
    return "${DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(date)}-${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}";
  } else {
    return "${DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(date)}+${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}";
  }
}

extension DateHelper on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}