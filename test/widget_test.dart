// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:qinglong_app/base/cron_parse.dart';
import 'package:timezone/standalone.dart';

void main() {
  String time = "5 0-23/6 * * *";

  String cronTime;
  List<dynamic> timeList = time.split(" ");
  Duration duration;
  if (timeList.length > 5) {
    var first = timeList.first;
    var list = parseConstraint(first)?.first;
    duration = Duration(seconds: list ?? 0);

    cronTime = timeList.sublist(1, timeList.length).join(" ");
  } else {
    cronTime = time;
    duration = const Duration(seconds: 0);
  }

  var cronIterator = Cron().parse(cronTime, "Asia/Shanghai");
  TZDateTime nextDate = cronIterator.next();
  var result = nextDate.add(duration);
  print(result.toIso8601String());
}

