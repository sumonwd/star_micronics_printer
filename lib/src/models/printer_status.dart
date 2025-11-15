class PrinterStatus {
  final bool online;
  final bool coverOpen;
  final bool paperEmpty;
  final bool paperNearEmpty;
  final bool drawerOpen;

  const PrinterStatus({
    required this.online,
    required this.coverOpen,
    required this.paperEmpty,
    required this.paperNearEmpty,
    required this.drawerOpen,
  });

  factory PrinterStatus.fromMap(Map<String, dynamic> map) {
    return PrinterStatus(
      online: map['online'] as bool? ?? false,
      coverOpen: map['coverOpen'] as bool? ?? false,
      paperEmpty: map['paperEmpty'] as bool? ?? false,
      paperNearEmpty: map['paperNearEmpty'] as bool? ?? false,
      drawerOpen: map['drawerOpen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'online': online,
      'coverOpen': coverOpen,
      'paperEmpty': paperEmpty,
      'paperNearEmpty': paperNearEmpty,
      'drawerOpen': drawerOpen,
    };
  }

  bool get hasError => !online || coverOpen || paperEmpty;

  @override
  String toString() {
    return 'PrinterStatus(online: $online, coverOpen: $coverOpen, paperEmpty: $paperEmpty)';
  }
}
