enum InterfaceType {
  lan,
  bluetooth,
  bluetoothLE,
  usb;

  String toNative() {
    switch (this) {
      case InterfaceType.lan:
        return 'lan';
      case InterfaceType.bluetooth:
        return 'bluetooth';
      case InterfaceType.bluetoothLE:
        return 'bluetoothLE';
      case InterfaceType.usb:
        return 'usb';
    }
  }

  static InterfaceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'lan':
        return InterfaceType.lan;
      case 'bluetooth':
        return InterfaceType.bluetooth;
      case 'bluetoothle':
        return InterfaceType.bluetoothLE;
      case 'usb':
        return InterfaceType.usb;
      default:
        return InterfaceType.lan;
    }
  }
}
