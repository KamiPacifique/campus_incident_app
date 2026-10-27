import 'package:intl/intl.dart';

String _plural(int n, String unit) => '$n $unit${n == 1 ? '' : 's'} ago';

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return _plural(diff.inMinutes, 'min');
  if (diff.inHours < 24) return _plural(diff.inHours, 'hour');
  if (diff.inDays < 30) return _plural(diff.inDays, 'day');
  return DateFormat.yMMMd().format(date);
}

String fullDate(DateTime date) =>
    DateFormat("MMM d, y 'at' h:mm a").format(date);

String shortDate(DateTime date) => DateFormat('MMM d, h:mm a').format(date);

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}
