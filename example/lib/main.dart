import 'package:flutter/material.dart';
import 'package:star_micronics_printer/star_micronics_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Micronics Printer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PrinterDemo(),
    );
  }
}

class PrinterDemo extends StatefulWidget {
  const PrinterDemo({super.key});

  @override
  State<PrinterDemo> createState() => _PrinterDemoState();
}

class _PrinterDemoState extends State<PrinterDemo> {
  List<PrinterInfo> _printers = [];
  PrinterInfo? _selectedPrinter;
  PrinterStatus? _printerStatus;
  bool _isSearching = false;

  Future<void> _searchPrinters() async {
    setState(() => _isSearching = true);

    final printers = await StarMicronicsPrinter.searchPrinters(
      timeout: const Duration(seconds: 10),
    );

    setState(() {
      _printers = printers;
      _isSearching = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Found ${printers.length} printers')));
    }
  }

  Future<void> _getStatus() async {
    if (_selectedPrinter == null) {
      _showError('Please select a printer first');
      return;
    }

    final settings = ConnectionSettings(
      interfaceType: _selectedPrinter!.interfaceType,
      identifier: _selectedPrinter!.identifier,
    );

    final status = await StarMicronicsPrinter.getStatus(settings);
    setState(() => _printerStatus = status);
  }

  Future<void> _printSimpleReceipt() async {
    if (_selectedPrinter == null) {
      _showError('Please select a printer first');
      return;
    }

    final settings = ConnectionSettings(
      interfaceType: _selectedPrinter!.interfaceType,
      identifier: _selectedPrinter!.identifier,
    );

    // Create print commands
    final commands = PrintCommands()
      ..addReceiptHeader(
        storeName: 'Star Boutique',
        address: '123 Star Road, City',
        phone: 'Tel: (123) 456-7890',
      )
      ..addSeparator()
      ..appendText('Date: ${DateTime.now().toString().split('.')[0]}\n')
      ..appendText('Receipt #: 00123\n\n')
      ..addSeparator()
      ..addItemLine(name: 'T-Shirt', quantity: 2, price: 19.99)
      ..addItemLine(name: 'Jeans', quantity: 1, price: 49.99)
      ..addItemLine(name: 'Socks', quantity: 3, price: 5.99)
      ..addSeparator()
      ..addTotalLine('Subtotal', 95.96)
      ..addTotalLine('Tax (10%)', 9.60)
      ..setBold(true)
      ..setMagnification(width: 2, height: 2)
      ..addTotalLine('TOTAL', 105.56)
      ..resetStyles()
      ..appendText('\n')
      ..setAlignment(StarAlignmentPosition.center)
      ..appendText('Thank you for your purchase!\n')
      ..appendText('Visit us at www.starboutique.com\n\n')
      ..appendCutPaper(StarCutPaperAction.partialCut);

    final success = await StarMicronicsPrinter.printCommands(
      settings: settings,
      commands: commands,
    );

    _showMessage(success ? 'Print successful!' : 'Print failed');
  }

  Future<void> _printWithBarcode() async {
    if (_selectedPrinter == null) {
      _showError('Please select a printer first');
      return;
    }

    final settings = ConnectionSettings(
      interfaceType: _selectedPrinter!.interfaceType,
      identifier: _selectedPrinter!.identifier,
    );

    final commands = PrintCommands()
      ..setAlignment(StarAlignmentPosition.center)
      ..setMagnification(width: 2, height: 2)
      ..appendText('ORDER #12345\n')
      ..resetStyles()
      ..appendText('\n')
      ..setAlignment(StarAlignmentPosition.center)
      ..appendBarcode(
        data: '123456789012',
        symbology: StarBarcodeSymbology.code128,
        width: StarBarcodeWidth.mode2,
        height: 50,
        hri: true,
      )
      ..appendText('\n')
      ..appendText('Scan for order details\n\n')
      ..appendCutPaper(StarCutPaperAction.partialCut);

    final success = await StarMicronicsPrinter.printCommands(
      settings: settings,
      commands: commands,
    );

    _showMessage(success ? 'Barcode printed!' : 'Print failed');
  }

  Future<void> _printWithQrCode() async {
    if (_selectedPrinter == null) {
      _showError('Please select a printer first');
      return;
    }

    final settings = ConnectionSettings(
      interfaceType: _selectedPrinter!.interfaceType,
      identifier: _selectedPrinter!.identifier,
    );

    final commands = PrintCommands()
      ..setAlignment(StarAlignmentPosition.center)
      ..appendText('Scan to visit our website\n\n')
      ..appendQrCode(
        data: 'https://www.starmicronics.com',
        model: StarQrCodeModel.no2,
        level: StarQrCodeLevel.l,
        cellSize: 8,
      )
      ..appendText('\n')
      ..appendText('www.starmicronics.com\n\n')
      ..appendCutPaper(StarCutPaperAction.partialCut);

    final success = await StarMicronicsPrinter.printCommands(
      settings: settings,
      commands: commands,
    );

    _showMessage(success ? 'QR code printed!' : 'Print failed');
  }

  Future<void> _printStyledText() async {
    if (_selectedPrinter == null) {
      _showError('Please select a printer first');
      return;
    }

    final settings = ConnectionSettings(
      interfaceType: _selectedPrinter!.interfaceType,
      identifier: _selectedPrinter!.identifier,
    );

    final commands = PrintCommands()
      ..setAlignment(StarAlignmentPosition.center)
      ..setMagnification(width: 3, height: 3)
      ..appendText('SALE!\n')
      ..resetStyles()
      ..appendText('\n')
      ..setBold(true)
      ..appendText('50% OFF ALL ITEMS\n')
      ..setBold(false)
      ..appendText('\n')
      ..setAlignment(StarAlignmentPosition.left)
      ..appendText('Regular text\n')
      ..appendTextBold('Bold text\n')
      ..appendTextUnderline('Underlined text\n')
      ..appendTextInvert('Inverted text\n')
      ..appendText('\n')
      ..setMagnification(width: 2, height: 2)
      ..appendText('Large Text\n')
      ..resetStyles()
      ..appendText('\n')
      ..appendCutPaper(StarCutPaperAction.partialCut);

    final success = await StarMicronicsPrinter.printCommands(
      settings: settings,
      commands: commands,
    );

    _showMessage(success ? 'Styled text printed!' : 'Print failed');
  }

  Future<void> _openDrawer() async {
    if (_selectedPrinter == null) {
      _showError('Please select a printer first');
      return;
    }

    final settings = ConnectionSettings(
      interfaceType: _selectedPrinter!.interfaceType,
      identifier: _selectedPrinter!.identifier,
    );

    final success = await StarMicronicsPrinter.openCashDrawer(settings);
    _showMessage(success ? 'Drawer opened!' : 'Failed to open drawer');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Star Micronics Printer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isSearching ? null : _searchPrinters,
              icon: _isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isSearching ? 'Searching...' : 'Search Printers'),
            ),
            const SizedBox(height: 16),

            if (_printers.isNotEmpty) ...[
              const Text('Available Printers:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _printers.length,
                  itemBuilder: (context, index) {
                    final printer = _printers[index];
                    return Card(
                      child: ListTile(
                        title: Text(printer.model),
                        subtitle: Text('${printer.interfaceType.name}: ${printer.identifier}'),
                        trailing: _selectedPrinter == printer
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () => setState(() => _selectedPrinter = printer),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (_selectedPrinter != null) ...[
              const SizedBox(height: 16),
              const Text('Print Options:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(onPressed: _getStatus, child: const Text('Get Status')),
                  ElevatedButton(
                    onPressed: _printSimpleReceipt,
                    child: const Text('Print Receipt'),
                  ),
                  ElevatedButton(onPressed: _printWithBarcode, child: const Text('Print Barcode')),
                  ElevatedButton(onPressed: _printWithQrCode, child: const Text('Print QR Code')),
                  ElevatedButton(
                    onPressed: _printStyledText,
                    child: const Text('Print Styled Text'),
                  ),
                  ElevatedButton(onPressed: _openDrawer, child: const Text('Open Drawer')),
                ],
              ),
            ],

            if (_printerStatus != null) ...[
              const SizedBox(height: 16),
              Card(
                color: _printerStatus!.hasError ? Colors.red.shade50 : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Printer Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Online: ${_printerStatus!.online}'),
                      Text('Cover Open: ${_printerStatus!.coverOpen}'),
                      Text('Paper Empty: ${_printerStatus!.paperEmpty}'),
                      Text('Paper Near Empty: ${_printerStatus!.paperNearEmpty}'),
                      Text('Drawer Open: ${_printerStatus!.drawerOpen}'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
