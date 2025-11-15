import 'interface_type.dart';

class PrinterInfo {
  final String model;
  final String identifier;
  final InterfaceType interfaceType;
  final String? emulation;

  const PrinterInfo({
    required this.model,
    required this.identifier,
    required this.interfaceType,
    this.emulation,
  });

  factory PrinterInfo.fromMap(Map<String, dynamic> map) {
    return PrinterInfo(
      model: map['model'] as String,
      identifier: map['identifier'] as String,
      interfaceType: InterfaceType.fromString(map['interfaceType'] as String),
      emulation: map['emulation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'identifier': identifier,
      'interfaceType': interfaceType.toNative(),
      'emulation': emulation,
    };
  }

  @override
  String toString() {
    return 'PrinterInfo(model: $model, identifier: $identifier, interfaceType: $interfaceType)';
  }
}
