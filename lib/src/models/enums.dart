/// Enum for Star Port type
enum StarPortType {
  /// checks all ports
  all,

  /// Checks lan or wifi
  lan,

  /// Checks bluetooth port
  bluetooth,

  /// Checks USB port
  usb,
}

extension ExtendedPortype on StarPortType {
  String get text {
    return toString().split('.').last;
  }
}

/// Enum for Emulation
enum StarEmulation {
  starPRNT,
  starPRNTL,
  starLine,
  starGraphic,
  escPos,
  escPosMobile,
  starDotImpact,
}

extension ExtendedEmulation on StarEmulation {
  String get text {
    return toString().split('.').last;
  }
}

/// Enum for Encoding
enum StarEncoding { usAscii, windows1252, shiftJIS, windows1251, gb2312, big5, utf8 }

extension ExtendedEncoding on StarEncoding {
  String? get text => const {
    StarEncoding.usAscii: "US-ASCII",
    StarEncoding.windows1252: "Windows-1252",
    StarEncoding.shiftJIS: "Shift-JIS",
    StarEncoding.windows1251: "Windows-1251",
    StarEncoding.gb2312: "GB2312",
    StarEncoding.big5: "Big5",
    StarEncoding.utf8: "UTF-8",
  }[this];
}

/// Enum for CodePageType
enum StarCodePageType {
  cp737,
  cp772,
  cp774,
  cp851,
  cp852,
  cp855,
  cp857,
  cp858,
  cp860,
  cp861,
  cp862,
  cp863,
  cp864,
  cp865,
  cp869,
  cp874,
  cp928,
  cp932,
  cp999,
  cp1001,
  cp1250,
  cp1251,
  cp1252,
  cp2001,
  cp3001,
  cp3002,
  cp3011,
  cp3012,
  cp3021,
  cp3041,
  cp3840,
  cp3841,
  cp3843,
  cp3845,
  cp3846,
  cp3847,
  cp3848,
  utf8,
  blank,
}

extension ExtendedCodePageType on StarCodePageType {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible International character mode
enum StarInternationalType {
  /// UK character mode
  uk,

  /// USA character mode
  usa,

  /// French character mode
  france,

  /// German character mode
  germany,

  /// Denmark character mode
  denmark,

  /// Sweden character mode
  sweden,

  /// Italy character mode
  italy,

  /// Spain character mode
  spain,

  /// Japan character mode
  japan,

  /// Norway character mode
  norway,

  /// Denmark2 character mode
  denmark2,

  /// Spain2 character mode
  spain2,

  /// LatinAmerica character mode
  latinAmerica,

  /// Korea character mode
  korea,

  /// Ireland character mode
  ireland,

  /// Legal character mode
  legal,
}

extension ExtendedStarInternationalType on StarInternationalType {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible FontStyleType
enum StarFontStyleType {
  /// Font-A (12 x 24 dots) / Specify 7 x 9 font (half dots)
  a,

  /// Font-B (9 x 24 dots) / Specify 5 x 9 font (2P-1)
  b,
}

extension ExtendedStarFontStyleType on StarFontStyleType {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible CutPaperAction
enum StarCutPaperAction {
  /// Full cut
  fullCut,

  /// Full cut with feed
  fullCutWithFeed,

  /// Partial cut
  partialCut,

  /// Partial cut with feed
  partialCutWithFeed,
}

extension ExtendedStarCutPaperAction on StarCutPaperAction {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible BlackMarkType
enum StarBlackMarkType { valid, invalid, validWithDetection }

extension ExtendedStarBlackMarkType on StarBlackMarkType {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible AlignmentPosition
enum StarAlignmentPosition {
  /// Left alignment
  left,

  /// Center alignment
  center,

  /// Right alignment
  right,
}

extension ExtendedStarAlignmentPosition on StarAlignmentPosition {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible LogoSize
enum StarLogoSize { normal, doubleWidth, doubleHeight, doubleWidthDoubleHeight }

extension ExtendedStarLogoSize on StarLogoSize {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible BarcodeSymbology
enum StarBarcodeSymbology { code128, code39, code93, itf, jan8, jan13, nw7, upcA, upcE }

extension ExtendedStarBarcodeSymbology on StarBarcodeSymbology {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible BarcodeWidth
enum StarBarcodeWidth { mode1, mode2, mode3, mode4, mode5, mode6, mode7, mode8, mode9 }

extension ExtendedStarBarcodeWidth on StarBarcodeWidth {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible QrCodeModel
enum StarQrCodeModel { no1, no2 }

extension ExtendedStarQrCodeModel on StarQrCodeModel {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible QrCodeLevel
enum StarQrCodeLevel { h, l, m, q }

extension ExtendedStarQrCodeLevel on StarQrCodeLevel {
  String get text {
    return toString().split('.').last;
  }
}

/// Constant for possible BitmapConverterRotation
enum StarBitmapConverterRotation { normal, left90, right90, rotate180 }

extension ExtendedStarBitmapConverterRotation on StarBitmapConverterRotation {
  String get text {
    return toString().split('.').last;
  }
}
