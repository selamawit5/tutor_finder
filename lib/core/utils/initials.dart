/// Up to two upper-case initials for an avatar, e.g. "Abebe Kebede" -> "AK".
/// Returns "?" for an empty or blank name instead of throwing.
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) {
    return '?';
  }
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}
