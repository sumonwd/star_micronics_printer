import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'models/enums.dart';

/// Class to build print commands for Star printers using StarXpand SDK
/// This class provides a fluent API to create complex receipt layouts
class PrintCommands {
  final List<Map<String, dynamic>> _commands = [];

  /// Get current list of commands
  List<Map<String, dynamic>> getCommands() => _commands;

  /// Clear all commands
  void clear() => _commands.clear();

  // ==================== TEXT COMMANDS ====================

  /// Print text with optional styling
  ///
  /// ```dart
  /// commands.appendText('Hello World\n');
  /// ```
  PrintCommands appendText(String text) {
    _commands.add({'appendText': text});
    return this;
  }

  /// Print text with magnification (width and height scale)
  ///
  /// ```dart
  /// commands.appendTextMagnified('LARGE TEXT\n', width: 2, height: 2);
  /// ```
  PrintCommands appendTextMagnified(String text, {int width = 1, int height = 1}) {
    _commands.add({'appendTextMagnified': text, 'width': width, 'height': height});
    return this;
  }

  /// Print text with bold style
  PrintCommands appendTextBold(String text) {
    _commands.add({'appendTextBold': text});
    return this;
  }

  /// Print text with underline
  PrintCommands appendTextUnderline(String text) {
    _commands.add({'appendTextUnderline': text});
    return this;
  }

  /// Print text with invert (white on black)
  PrintCommands appendTextInvert(String text) {
    _commands.add({'appendTextInvert': text});
    return this;
  }

  // ==================== ALIGNMENT ====================

  /// Set text alignment
  ///
  /// ```dart
  /// commands.setAlignment(StarAlignmentPosition.Center);
  /// ```
  PrintCommands setAlignment(StarAlignmentPosition alignment) {
    _commands.add({'setAlignment': alignment.text});
    return this;
  }

  // ==================== FONT & ENCODING ====================

  /// Set character encoding
  PrintCommands setEncoding(StarEncoding encoding) {
    _commands.add({'setEncoding': encoding.text});
    return this;
  }

  /// Set code page
  PrintCommands setCodePage(StarCodePageType codePage) {
    _commands.add({'setCodePage': codePage.text});
    return this;
  }

  /// Set international character set
  PrintCommands setInternationalCharacter(StarInternationalType type) {
    _commands.add({'setInternationalCharacter': type.text});
    return this;
  }

  /// Set font style (A or B)
  PrintCommands setFontStyle(StarFontStyleType fontStyle) {
    _commands.add({'setFontStyle': fontStyle.text});
    return this;
  }

  /// Set character spacing (0-255)
  PrintCommands setCharacterSpace(int space) {
    _commands.add({'setCharacterSpace': space});
    return this;
  }

  /// Set line spacing (0-255)
  PrintCommands setLineSpace(int space) {
    _commands.add({'setLineSpace': space});
    return this;
  }

  // ==================== PAPER CONTROL ====================

  /// Cut paper with specified action
  ///
  /// ```dart
  /// commands.appendCutPaper(StarCutPaperAction.PartialCut);
  /// ```
  PrintCommands appendCutPaper(StarCutPaperAction action) {
    _commands.add({'appendCutPaper': action.text});
    return this;
  }

  /// Feed paper by lines
  ///
  /// ```dart
  /// commands.feedLine(3); // Feed 3 lines
  /// ```
  PrintCommands feedLine(int lines) {
    _commands.add({'feedLine': lines});
    return this;
  }

  /// Feed paper by units (dots)
  PrintCommands feedUnit(int units) {
    _commands.add({'feedUnit': units});
    return this;
  }

  // ==================== CASH DRAWER ====================

  /// Open cash drawer
  ///
  /// ```dart
  /// commands.openCashDrawer(1); // Open drawer on channel 1
  /// ```
  PrintCommands openCashDrawer(int channel) {
    _commands.add({'openCashDrawer': channel});
    return this;
  }

  // ==================== BARCODE ====================

  /// Print barcode
  ///
  /// ```dart
  /// commands.appendBarcode(
  ///   data: '1234567890',
  ///   symbology: StarBarcodeSymbology.Code128,
  ///   width: StarBarcodeWidth.Mode2,
  ///   height: 40,
  ///   hri: true,
  /// );
  /// ```
  PrintCommands appendBarcode({
    required String data,
    required StarBarcodeSymbology symbology,
    StarBarcodeWidth width = StarBarcodeWidth.mode2,
    int height = 40,
    bool hri = false,
    StarAlignmentPosition? alignment,
    int? absolutePosition,
  }) {
    final command = <String, dynamic>{
      'appendBarcode': data,
      'symbology': symbology.text,
      'width': width.text,
      'height': height,
      'hri': hri,
    };
    if (alignment != null) command['alignment'] = alignment.text;
    if (absolutePosition != null) command['absolutePosition'] = absolutePosition;
    _commands.add(command);
    return this;
  }

  // ==================== QR CODE ====================

  /// Print QR code
  ///
  /// ```dart
  /// commands.appendQrCode(
  ///   data: 'https://example.com',
  ///   model: StarQrCodeModel.No2,
  ///   level: StarQrCodeLevel.L,
  ///   cellSize: 8,
  /// );
  /// ```
  PrintCommands appendQrCode({
    required String data,
    StarQrCodeModel model = StarQrCodeModel.no1,
    StarQrCodeLevel level = StarQrCodeLevel.l,
    int cellSize = 8,
    StarAlignmentPosition? alignment,
    int? absolutePosition,
  }) {
    final command = <String, dynamic>{
      'appendQrCode': data,
      'model': model.text,
      'level': level.text,
      'cellSize': cellSize,
    };
    if (alignment != null) command['alignment'] = alignment.text;
    if (absolutePosition != null) command['absolutePosition'] = absolutePosition;
    _commands.add(command);
    return this;
  }

  // ==================== PDF417 ====================

  /// Print PDF417 barcode
  PrintCommands appendPdf417({
    required String data,
    int column = 0,
    int line = 0,
    int module = 2,
    int aspect = 3,
    StarAlignmentPosition? alignment,
  }) {
    final command = <String, dynamic>{
      'appendPdf417': data,
      'column': column,
      'line': line,
      'module': module,
      'aspect': aspect,
    };
    if (alignment != null) command['alignment'] = alignment.text;
    _commands.add(command);
    return this;
  }

  // ==================== IMAGE PRINTING ====================

  /// Print image from file path or URL
  ///
  /// ```dart
  /// commands.appendBitmap(
  ///   path: 'assets/logo.png',
  ///   width: 576,
  ///   bothScale: true,
  ///   alignment: StarAlignmentPosition.Center,
  /// );
  /// ```
  PrintCommands appendBitmap({
    required String path,
    bool diffusion = true,
    int width = 576,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    final command = <String, dynamic>{
      'appendBitmap': path,
      'diffusion': diffusion,
      'width': width,
      'bothScale': bothScale,
    };
    if (absolutePosition != null) command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;
    _commands.add(command);
    return this;
  }

  /// Print image from byte array
  ///
  /// ```dart
  /// commands.appendBitmapByte(
  ///   byteData: imageBytes,
  ///   width: 576,
  /// );
  /// ```
  PrintCommands appendBitmapByte({
    required Uint8List byteData,
    bool diffusion = true,
    int width = 576,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    final command = <String, dynamic>{
      'appendBitmapByteArray': byteData,
      'diffusion': diffusion,
      'width': width,
      'bothScale': bothScale,
    };
    if (absolutePosition != null) command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;
    _commands.add(command);
    return this;
  }

  /// Print image generated from Flutter widget
  ///
  /// ```dart
  /// await commands.appendBitmapWidget(
  ///   context: context,
  ///   widget: MyReceiptWidget(),
  ///   width: 576,
  /// );
  /// ```
  Future<PrintCommands> appendBitmapWidget({
    required BuildContext context,
    required Widget widget,
    bool diffusion = true,
    int width = 576,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
    Duration? wait,
    Size? logicalSize,
    Size? imageSize,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final byte = await createImageFromWidget(
      context,
      widget,
      wait: wait,
      logicalSize: logicalSize,
      imageSize: imageSize,
      textDirection: textDirection,
    );

    if (byte != null) {
      appendBitmapByte(
        byteData: byte,
        diffusion: diffusion,
        width: width,
        bothScale: bothScale,
        absolutePosition: absolutePosition,
        alignment: alignment,
        rotation: rotation,
      );
    } else {
      throw Exception('Error generating image from widget');
    }
    return this;
  }

  /// Print text as bitmap (useful for custom fonts)
  ///
  /// ```dart
  /// commands.appendBitmapText(
  ///   text: 'Custom Font Text',
  ///   fontSize: 24,
  /// );
  /// ```
  PrintCommands appendBitmapText({
    required String text,
    int? fontSize,
    bool diffusion = true,
    int? width,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    final command = <String, dynamic>{
      'appendBitmapText': text,
      'bothScale': bothScale,
      'diffusion': diffusion,
    };
    if (fontSize != null) command['fontSize'] = fontSize;
    if (width != null) command['width'] = width;
    if (absolutePosition != null) command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;
    _commands.add(command);
    return this;
  }

  // ==================== LOGO PRINTING ====================

  /// Print uploaded logo (requires logo upload first)
  ///
  /// ```dart
  /// commands.appendLogo(
  ///   logoKey: 1,
  ///   size: StarLogoSize.DoubleWidthDoubleHeight,
  /// );
  /// ```
  PrintCommands appendLogo({
    required int logoKey,
    StarLogoSize size = StarLogoSize.normal,
    StarAlignmentPosition? alignment,
  }) {
    final command = <String, dynamic>{'appendLogo': logoKey, 'size': size.text};
    if (alignment != null) command['alignment'] = alignment.text;
    _commands.add(command);
    return this;
  }

  // ==================== BLACK MARK ====================

  /// Append black mark command (for label printers)
  PrintCommands appendBlackMark(StarBlackMarkType type) {
    _commands.add({'appendBlackMark': type.text});
    return this;
  }

  // ==================== ADVANCED FEATURES ====================

  /// Enable/disable emphasized text
  PrintCommands setEmphasis(bool enable) {
    _commands.add({'setEmphasis': enable});
    return this;
  }

  /// Enable/disable underline
  PrintCommands setUnderline(bool enable) {
    _commands.add({'setUnderline': enable});
    return this;
  }

  /// Enable/disable invert (white on black)
  PrintCommands setInvert(bool enable) {
    _commands.add({'setInvert': enable});
    return this;
  }

  /// Enable/disable bold
  PrintCommands setBold(bool enable) {
    _commands.add({'setBold': enable});
    return this;
  }

  /// Set text magnification
  ///
  /// ```dart
  /// commands.setMagnification(width: 2, height: 2);
  /// ```
  PrintCommands setMagnification({int width = 1, int height = 1}) {
    _commands.add({'setMagnification': true, 'width': width, 'height': height});
    return this;
  }

  /// Reset all text styles to default
  PrintCommands resetStyles() {
    _commands.add({'resetStyles': true});
    return this;
  }

  /// Append absolute position (for precise positioning)
  PrintCommands setAbsolutePosition(int position) {
    _commands.add({'setAbsolutePosition': position});
    return this;
  }

  /// Append relative position
  PrintCommands setRelativePosition(int position) {
    _commands.add({'setRelativePosition': position});
    return this;
  }

  // ==================== RAW COMMAND ====================

  /// Push custom command map
  ///
  /// ```dart
  /// commands.push({'customCommand': 'value'});
  /// ```
  PrintCommands push(Map<String, dynamic> command) {
    _commands.add(command);
    return this;
  }

  // ==================== HELPER METHODS ====================

  /// Generate image from Flutter widget
  ///
  /// This is a utility method that can be used independently
  static Future<Uint8List?> createImageFromWidget(
    BuildContext context,
    Widget widget, {
    Duration? wait,
    Size? logicalSize,
    Size? imageSize,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    logicalSize ??= View.of(context).physicalSize / View.of(context).devicePixelRatio;
    imageSize ??= View.of(context).physicalSize;

    assert(
      (logicalSize.aspectRatio - imageSize.aspectRatio).abs() < 0.01,
      'Logical size and image size must have the same aspect ratio',
    );

    final RenderView renderView = RenderView(
      view: WidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first,
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(logicalSize),
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
          container: repaintBoundary,
          child: Directionality(
            textDirection: textDirection,
            child: IntrinsicHeight(child: IntrinsicWidth(child: widget)),
          ),
        ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (wait != null) {
      await Future.delayed(wait);
    }

    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width,
    );

    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  // ==================== CONVENIENCE METHODS ====================

  /// Create a simple receipt header
  ///
  /// ```dart
  /// commands.addReceiptHeader(
  ///   storeName: 'My Store',
  ///   address: '123 Main St',
  /// );
  /// ```
  PrintCommands addReceiptHeader({required String storeName, String? address, String? phone}) {
    setAlignment(StarAlignmentPosition.center);
    setBold(true);
    setMagnification(width: 2, height: 2);
    appendText('$storeName\n');
    resetStyles();

    if (address != null) {
      appendText('$address\n');
    }
    if (phone != null) {
      appendText('$phone\n');
    }

    appendText('\n');
    setAlignment(StarAlignmentPosition.left);

    return this;
  }

  /// Add separator line
  ///
  /// ```dart
  /// commands.addSeparator(char: '-', length: 32);
  /// ```
  PrintCommands addSeparator({String char = '-', int length = 32}) {
    appendText('${char * length}\n');
    return this;
  }

  /// Add item line (name, quantity, price)
  ///
  /// ```dart
  /// commands.addItemLine(
  ///   name: 'Product Name',
  ///   quantity: 2,
  ///   price: 19.99,
  /// );
  /// ```
  PrintCommands addItemLine({
    required String name,
    int? quantity,
    required double price,
    int lineWidth = 32,
  }) {
    final priceStr = price.toStringAsFixed(2);
    final qtyStr = quantity != null ? 'x$quantity' : '';

    final availableSpace = lineWidth - priceStr.length - qtyStr.length - 1;
    final truncatedName = name.length > availableSpace
        ? name.substring(0, availableSpace)
        : name.padRight(availableSpace);

    appendText('$truncatedName ${qtyStr.padLeft(0)} ${priceStr.padLeft(priceStr.length)}\n');
    return this;
  }

  /// Add total line
  ///
  /// ```dart
  /// commands.addTotalLine('TOTAL', 59.97);
  /// ```
  PrintCommands addTotalLine(String label, double amount, {int lineWidth = 32}) {
    final amountStr = amount.toStringAsFixed(2);
    final spaces = lineWidth - label.length - amountStr.length;
    appendText('$label${' ' * spaces}$amountStr\n');
    return this;
  }
}
