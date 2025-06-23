class AbsenException implements Exception {
  final String message;

  AbsenException(this.message);

  @override
  String toString() => "AbsenException: $message";
}
