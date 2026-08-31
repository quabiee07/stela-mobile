class HealthStatus {
  final String status;
  final String service;
  final String version;

  const HealthStatus({
    required this.status,
    required this.service,
    required this.version,
  });
}
