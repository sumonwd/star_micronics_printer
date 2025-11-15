import 'interface_type.dart';

class ConnectionSettings {
  final InterfaceType interfaceType;
  final String identifier; // MAC address, IP address, or USB identifier

  const ConnectionSettings({required this.interfaceType, required this.identifier});

  Map<String, dynamic> toMap() {
    return {'interfaceType': interfaceType.toNative(), 'identifier': identifier};
  }

  factory ConnectionSettings.fromMap(Map<String, dynamic> map) {
    return ConnectionSettings(
      interfaceType: InterfaceType.fromString(map['interfaceType'] as String),
      identifier: map['identifier'] as String,
    );
  }
}
