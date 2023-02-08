

import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

abstract class HasNext<E> {
  /// Find next suitable date
  E next();
}

abstract class HasPrevious<E> {
  /// Find previous suitable date
  E previous();
}

mixin CronIterator<E> on HasPrevious<E>, HasNext<E> {
  E current();
}

abstract class Cron {
  factory Cron() {
    initializeTimeZones();
    return _Cron();
  }

  /// Takes a [cronString], a [locationName] and an optional [startTime].
  /// It returns an iterator [HasNext] which delivers [TZDateTime] events. If no [startTime]
  /// is provided [TZDateTime.now(getLocation(locationName)] is used.
  /// The [locationName] string has to be in the format listed at http://www.iana.org/time-zones.
  CronIterator<TZDateTime> parse(String cronString, String locationName, [TZDateTime? startTime]);
}

const String _regex0to59 = "([1-5]?[0-9])";
const String _regex0to23 = "([1]?[0-9]|[2][0-3])";
const String _regex1to31 = "([1-9]|[12][0-9]|[3][01])";
const String _regex1to12 = "([1-9]|[1][012])";
const String _regex0to7 = "([0-7])";

const String _minutesRegex = "((($_regex0to59[,])+$_regex0to59)|$_regex0to59([-]$_regex0to59)?|[*]([/]$_regex0to59)?)";
const String _hoursRegex = "((($_regex0to23[,])+$_regex0to23)|$_regex0to23([-]($_regex0to23))?|[*]([/]$_regex0to23)?)";
const String _daysRegex = "((($_regex1to31[,])+$_regex1to31)|$_regex1to31([-]$_regex1to31)?|[*]([/]$_regex1to31)?)";
const String _monthRegex = "((($_regex1to12[,])+$_regex1to12)|$_regex1to12([-]$_regex1to12)?|[*]([/]$_regex1to12)?)";
const String _weekdaysRegex = "((($_regex0to7[,])+$_regex0to7)|$_regex0to7([-]$_regex0to7)?|[*]([/]$_regex0to7)?)";
final RegExp _cronRegex = RegExp("^$_minutesRegex\\s+$_hoursRegex\\s+$_daysRegex\\s+$_monthRegex\\s+$_weekdaysRegex\$");

class _Cron implements Cron {
  @override
  CronIterator<TZDateTime> parse(String cronString, String locationName, [TZDateTime? startTime]) {
    assert(cronString.isNotEmpty);
    // assert(_cronRegex.hasMatch(cronString));
    var location = getLocation(locationName);
    startTime ??= TZDateTime.now(location);
    startTime = TZDateTime.from(startTime, location);
    return _CronIterator(_parse(cronString), startTime);
  }

  _Schedule _parse(String cronString) {
    List<List<int>?> p = cronString.split(RegExp('\\s+')).map(parseConstraint).toList();
    _Schedule schedule = _Schedule(minutes: p[0], hours: p[1], days: p[2], months: p[3], weekdays: p[4]);
    return schedule;
  }
}

class _Schedule {
  final List<int>? minutes;
  final List<int>? hours;
  final List<int>? days;
  final List<int>? months;
  final List<int>? weekdays;

  _Schedule._(this.minutes, this.hours, this.days, this.months, this.weekdays);

  factory _Schedule({dynamic minutes, dynamic hours, dynamic days, dynamic months, dynamic weekdays}) {
    List<int>? parsedMinutes = parseConstraint(minutes)?.where((x) => x >= 0 && x <= 59).toList();
    List<int>? parsedHours = parseConstraint(hours)?.where((x) => x >= 0 && x <= 23).toList();
    List<int>? parsedDays = parseConstraint(days)?.where((x) => x >= 1 && x <= 31).toList();
    List<int>? parsedMonths = parseConstraint(months)?.where((x) => x >= 1 && x <= 12).toList();
    List<int>? parsedWeekdays = parseConstraint(weekdays)?.where((x) => x >= 0 && x <= 7).map((x) => x == 0 ? 7 : x).toSet().toList();
    return _Schedule._(parsedMinutes, parsedHours, parsedDays, parsedMonths, parsedWeekdays);
  }
}

List<int>? parseConstraint(dynamic constraint) {
  if (constraint == null) return null;
  if (constraint is int) return [constraint];
  if (constraint is List<int>) return constraint;
  if (constraint is String) {
    if (constraint == '*') return null;
    final parts = constraint.split(',');
    if (parts.length > 1) {
      final items = parts.map(parseConstraint).expand((list) => list!).toSet().toList();
      items.sort();
      return items;
    }

    int? singleValue = int.tryParse(constraint);
    if (singleValue != null) return [singleValue];

    if (constraint.startsWith('*/')) {
      int period = int.tryParse(constraint.substring(2)) ?? -1;
      if (period > 0) {
        return List.generate(120 ~/ period, (i) => i * period);
      }
    }

    if (!constraint.startsWith("/") && !constraint.endsWith("/") && constraint.contains("/")) {
      List<dynamic> duration = constraint.split("/");

      String first = duration.first.toString();
      if (first.contains("-")) {
        List<dynamic> head = first.split("-");

        int l = int.tryParse(head.last) ?? 0;
        int f = int.tryParse(head.first) ?? 0;

        List<int> result = [];
        while (f <= l) {
          result.add(f);
          f += (int.tryParse(duration.last) ?? 10);
        }
        return result;
      }
    }
    if (constraint.contains('-')) {
      List<String> ranges = constraint.split('-');
      if (ranges.length == 2) {
        int lower = int.tryParse(ranges.first) ?? -1;
        int higher = int.tryParse(ranges.last) ?? -1;
        if (lower <= higher) {
          return List.generate(higher - lower + 1, (i) => i + lower);
        }
      }
    }
  }
  throw 'Unable to parse: $constraint';
}

class _CronIterator implements CronIterator<TZDateTime> {
  _Schedule _schedule;
  TZDateTime _currentDate;
  bool _nextCalled = false;
  bool _previousCalled = false;

  _CronIterator(this._schedule, this._currentDate) {
    _currentDate = TZDateTime.fromMillisecondsSinceEpoch(_currentDate.location, this._currentDate.millisecondsSinceEpoch ~/ 60000 * 60000);
  }

  @override
  TZDateTime next() {
    _nextCalled = true;
    _currentDate = _currentDate.add(Duration(minutes: 1));
    while (true) {
      if (_schedule.months?.contains(_currentDate.month) == false) {
        _currentDate = TZDateTime(_currentDate.location, _currentDate.year, _currentDate.month + 1, 1);
        continue;
      }
      if (_schedule.weekdays?.contains(_currentDate.weekday) == false) {
        _currentDate = TZDateTime(_currentDate.location, _currentDate.year, _currentDate.month, _currentDate.day + 1);
        continue;
      }
      if (_schedule.days?.contains(_currentDate.day) == false) {
        _currentDate = TZDateTime(_currentDate.location, _currentDate.year, _currentDate.month, _currentDate.day + 1);
        continue;
      }
      if (_schedule.hours?.contains(_currentDate.hour) == false) {
        _currentDate = _currentDate.add(Duration(hours: 1));
        _currentDate = _currentDate.subtract(Duration(minutes: _currentDate.minute));
        continue;
      }
      if (_schedule.minutes?.contains(_currentDate.minute) == false) {
        _currentDate = _currentDate.add(Duration(minutes: 1));
        continue;
      }
      return _currentDate;
    }
  }

  @override
  TZDateTime previous() {
    _previousCalled = true;
    _currentDate = _currentDate.subtract(Duration(minutes: 1));
    while (true) {
      if (_schedule.minutes?.contains(_currentDate.minute) == false) {
        _currentDate = _currentDate.subtract(Duration(minutes: 1));
        continue;
      }
      if (_schedule.hours?.contains(_currentDate.hour) == false) {
        _currentDate = _currentDate.subtract(Duration(hours: 1));
        continue;
      }
      if (_schedule.days?.contains(_currentDate.day) == false) {
        _currentDate = _currentDate.subtract(Duration(days: 1));
        continue;
      }
      if (_schedule.weekdays?.contains(_currentDate.weekday) == false) {
        _currentDate = TZDateTime(
          _currentDate.location,
          _currentDate.year,
          _currentDate.month,
          _currentDate.day - 1,
          _currentDate.hour,
          _currentDate.minute,
        );
        continue;
      }
      if (_schedule.months?.contains(_currentDate.month) == false) {
        _currentDate = TZDateTime(
          _currentDate.location,
          _currentDate.year,
          _currentDate.month - 1,
          _currentDate.day,
          _currentDate.hour,
          _currentDate.minute,
        );
        continue;
      }
      return _currentDate;
    }
  }

  @override
  TZDateTime current() {
    assert(_nextCalled || _previousCalled);
    return _currentDate;
  }
}
