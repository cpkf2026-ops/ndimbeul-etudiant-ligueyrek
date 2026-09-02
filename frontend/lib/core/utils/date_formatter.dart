import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final DateFormat _shortDate = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final DateFormat _longDate = DateFormat('d MMMM yyyy', 'fr_FR');
  static final DateFormat _time = DateFormat('HH:mm', 'fr_FR');

  static String short(DateTime date) => _shortDate.format(date);
  static String long(DateTime date) => _longDate.format(date);
  static String time(DateTime date) => _time.format(date);

  /// "il y a 3h", "il y a 2j", "à l'instant" — utilisé pour actualités,
  /// conversations IA et badges de traçabilité de source.
  static String relative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return short(date);
  }
}
