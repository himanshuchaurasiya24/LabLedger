
/// Returns initials from a name (1 or 2 words).
///
/// If [lastName] is provided, returns the first letter of each.
/// If only [firstName] is provided, returns the first letters of the first two words,
/// or the first two characters if it's a single word.
/// Returns '??' if all inputs are empty/null.
String getInitials(String? firstName, [String? lastName]) {
  if (lastName != null) {
    final first =
        firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final result = '$first$last';
    return result.isEmpty ? '??' : result;
  }

  if (firstName == null || firstName.isEmpty) return '??';

  final parts = firstName.trim().split(RegExp(r'\s+'));
  if (parts.length > 1) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  } else {
    return firstName
        .substring(0, firstName.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
}
