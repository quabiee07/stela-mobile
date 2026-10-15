class AgeRange {
  final int min;
  final int max;

  const AgeRange({
    required this.min,
    required this.max,
  });

  /// Full label for chips / body copy (`Ages 5–12`, `All ages`).
  String get label {
    if (min <= 0 && max >= 99) return 'All ages';
    if (min == max) return 'Age $min';
    return 'Ages $min–$max';
  }

  /// Compact value for stats tiles (`5–12`, `All`).
  String get shortLabel {
    if (min <= 0 && max >= 99) return 'All';
    if (min == max) return '$min';
    return '$min–$max';
  }
}
