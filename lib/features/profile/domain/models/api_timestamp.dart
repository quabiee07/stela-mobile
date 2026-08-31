class ApiTimestamp {
  final int seconds;
  final int nanoseconds;

  const ApiTimestamp({
    required this.seconds,
    required this.nanoseconds,
  });

  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
