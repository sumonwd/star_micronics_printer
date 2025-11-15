import Flutter
import UIKit
import StarIO10

public class StarMicronicsPrinterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "star_micronics_printer", binaryMessenger: registrar.messenger())
        let instance = StarMicronicsPrinterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "searchPrinters":
            searchPrinters(call: call, result: result)
        case "getStatus":
            getStatus(call: call, result: result)
        case "print":
            print(call: call, result: result)
        case "printCommands":
            printCommands(call: call, result: result)
        case "openCashDrawer":
            openCashDrawer(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Search Printers

    private func searchPrinters(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let timeout = args["timeout"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid timeout", details: nil))
            return
        }

        var printers: [[String: Any]] = []
        let manager = StarDeviceDiscoveryManagerFactory.create(interfaceTypes: [.lan, .bluetooth, .usb])

        manager.discoveryTime = TimeInterval(timeout) / 1000.0

        manager.callback = { (printer: StarPrinter) in
            let printerInfo: [String: Any] = [
                "model": printer.information?.model ?? "Unknown",
                "identifier": printer.connectionSettings.identifier,
                "interfaceType": self.interfaceTypeToString(printer.connectionSettings.interfaceType),
                "emulation": printer.information?.emulation.rawValue ?? ""
            ]
            printers.append(printerInfo)
        }

        manager.startDiscovery { error in
            if let error = error {
                result(FlutterError(code: "SEARCH_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(printers)
            }
        }
    }

    // MARK: - Get Status

    private func getStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let settings = createConnectionSettings(from: args) else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid connection settings", details: nil))
            return
        }

        let printer = StarPrinter(settings)

        Task {
            do {
                try await printer.open()
                let status = try await printer.getStatus()
                try await printer.close()

                let statusMap: [String: Any] = [
                    "online": !(status.coverOpen == .open || status.paper == .empty),
                    "coverOpen": status.coverOpen == .open,
                    "paperEmpty": status.paper == .empty,
                    "paperNearEmpty": status.paper == .nearEmpty,
                    "drawerOpen": status.drawer == .open
                ]

                await MainActor.run {
                    result(statusMap)
                }
            } catch {
                await MainActor.run {
                    result(FlutterError(code: "STATUS_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    // MARK: - Print

    private func print(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let settings = createConnectionSettings(from: args),
              let commandString = args["command"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }

        let printer = StarPrinter(settings)

        Task {
            do {
                try await printer.open()

                let builder = StarXpandCommand.StarXpandCommandBuilder()
                builder.addDocument(StarXpandCommand.DocumentBuilder()
                    .addPrinter(StarXpandCommand.PrinterBuilder()
                        .actionPrintText(commandString)
                        .actionCut(.partial)
                    )
                )

                let command = builder.getCommands()
                try await printer.print(command: command)
                try await printer.close()

                await MainActor.run {
                    result(true)
                }
            } catch {
                await MainActor.run {
                    result(FlutterError(code: "PRINT_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    // MARK: - Print Commands

    private func printCommands(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let settings = createConnectionSettings(from: args),
              let commands = args["commands"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }

        let printer = StarPrinter(settings)

        Task {
            do {
                try await printer.open()

                let builder = StarXpandCommand.StarXpandCommandBuilder()
                let printerBuilder = StarXpandCommand.PrinterBuilder()

                processCommands(printerBuilder: printerBuilder, commands: commands)

                builder.addDocument(StarXpandCommand.DocumentBuilder().addPrinter(printerBuilder))
                let command = builder.getCommands()

                try await printer.print(command: command)
                try await printer.close()

                await MainActor.run {
                    result(true)
                }
            } catch {
                await MainActor.run {
                    result(FlutterError(code: "PRINT_COMMANDS_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    // MARK: - Process Commands

    private func processCommands(printerBuilder: StarXpandCommand.PrinterBuilder, commands: [[String: Any]]) {
        for cmd in commands {
            // Text commands
            if let text = cmd["appendText"] as? String {
                printerBuilder.actionPrintText(text)
            }
            else if let text = cmd["appendTextMagnified"] as? String {
                let width = cmd["width"] as? Int ?? 1
                let height = cmd["height"] as? Int ?? 1
                printerBuilder
                    .styleMagnification(StarXpandCommand.MagnificationParameter(width: width, height: height))
                    .actionPrintText(text)
                    .styleMagnification(StarXpandCommand.MagnificationParameter(width: 1, height: 1))
            }
            else if let text = cmd["appendTextBold"] as? String {
                printerBuilder
                    .styleBold(true)
                    .actionPrintText(text)
                    .styleBold(false)
            }
            else if let text = cmd["appendTextUnderline"] as? String {
                printerBuilder
                    .styleUnderLine(true)
                    .actionPrintText(text)
                    .styleUnderLine(false)
            }
            else if let text = cmd["appendTextInvert"] as? String {
                printerBuilder
                    .styleInvert(true)
                    .actionPrintText(text)
                    .styleInvert(false)
            }

            // Alignment
            else if let alignment = cmd["setAlignment"] as? String {
                printerBuilder.styleAlignment(parseAlignment(alignment))
            }

            // Styles
            else if let bold = cmd["setBold"] as? Bool {
                printerBuilder.styleBold(bold)
            }
            else if let underline = cmd["setUnderline"] as? Bool {
                printerBuilder.styleUnderLine(underline)
            }
            else if let invert = cmd["setInvert"] as? Bool {
                printerBuilder.styleInvert(invert)
            }
            else if cmd["setMagnification"] != nil {
                let width = cmd["width"] as? Int ?? 1
                let height = cmd["height"] as? Int ?? 1
                printerBuilder.styleMagnification(StarXpandCommand.MagnificationParameter(width: width, height: height))
            }
            else if cmd["resetStyles"] != nil {
                printerBuilder
                    .styleBold(false)
                    .styleUnderLine(false)
                    .styleInvert(false)
                    .styleMagnification(StarXpandCommand.MagnificationParameter(width: 1, height: 1))
            }

            // Paper control
            else if let cutType = cmd["appendCutPaper"] as? String {
                printerBuilder.actionCut(parseCutType(cutType))
            }
            else if let lines = cmd["feedLine"] as? Int {
                printerBuilder.actionFeedLine(lines)
            }
            else if let units = cmd["feedUnit"] as? Int {
                printerBuilder.actionFeed(Double(units))
            }

            // Barcode
            else if let data = cmd["appendBarcode"] as? String {
                let symbology = parseBarcodeSymbology(cmd["symbology"] as? String)
                let height = cmd["height"] as? Double ?? 40.0
                let hri = cmd["hri"] as? Bool ?? false

                let parameter = StarXpandCommand.Printer.BarcodeParameter(content: data, symbology: symbology)
                    .setHeight(height)
                    .setPrintHRI(hri)

                printerBuilder.actionPrintBarcode(parameter)
            }

            // QR Code
            else if let data = cmd["appendQrCode"] as? String {
                let level = parseQrCodeLevel(cmd["level"] as? String)
                let cellSize = cmd["cellSize"] as? Int ?? 8

                let parameter = StarXpandCommand.Printer.QRCodeParameter(content: data)
                    .setLevel(level)
                    .setCellSize(cellSize)

                printerBuilder.actionPrintQRCode(parameter)
            }

            // PDF417
            else if let data = cmd["appendPdf417"] as? String {
                let column = cmd["column"] as? Int ?? 0
                let line = cmd["line"] as? Int ?? 0
                let module = cmd["module"] as? Int ?? 2
                let aspect = cmd["aspect"] as? Int ?? 3

                let parameter = StarXpandCommand.Printer.PDF417Parameter(content: data)
                    .setColumn(column)
                    .setLine(line)
                    .setModule(module)
                    .setAspect(aspect)

                printerBuilder.actionPrintPDF417(parameter)
            }

            // Image from byte array
            else if let byteArray = cmd["appendBitmapByteArray"] as? FlutterStandardTypedData {
                if let image = UIImage(data: byteArray.data) {
                    let width = cmd["width"] as? Int ?? 576
                    let parameter = StarXpandCommand.Printer.ImageParameter(image: image, width: width)
                    printerBuilder.actionPrintImage(parameter)
                }
            }

            // Encoding
            else if let encoding = cmd["setEncoding"] as? String {
                printerBuilder.styleCharacterEncoding(parseEncoding(encoding))
            }

            // Font style
            else if let fontStyle = cmd["setFontStyle"] as? String {
                printerBuilder.styleFont(parseFontStyle(fontStyle))
            }

            // Character space
            else if let space = cmd["setCharacterSpace"] as? Double {
                printerBuilder.styleCharacterSpace(space)
            }

            // Line space
            else if let space = cmd["setLineSpace"] as? Double {
                printerBuilder.styleLineSpace(space)
            }

            // Position
            else if let position = cmd["setAbsolutePosition"] as? Double {
                printerBuilder.styleHorizontalPositionTo(position)
            }
            else if let position = cmd["setRelativePosition"] as? Double {
                printerBuilder.styleHorizontalPositionBy(position)
            }

            // Logo
            else if let logoKey = cmd["appendLogo"] as? Int {
                let size = cmd["size"] as? String ?? "normal"
                let logoParameter = StarXpandCommand.Printer.LogoParameter(keyCode: logoKey)
                printerBuilder.actionPrintLogo(logoParameter)
            }
        }
    }

    // MARK: - Open Cash Drawer

    private func openCashDrawer(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let settings = createConnectionSettings(from: args) else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid connection settings", details: nil))
            return
        }

        let printer = StarPrinter(settings)

        Task {
            do {
                try await printer.open()

                let builder = StarXpandCommand.StarXpandCommandBuilder()
                builder.addDocument(StarXpandCommand.DocumentBuilder()
                    .addDrawer(StarXpandCommand.DrawerBuilder()
                        .actionOpen(StarXpandCommand.Drawer.Channel.no1)
                    )
                )

                let command = builder.getCommands()
                try await printer.print(command: command)
                try await printer.close()

                await MainActor.run {
                    result(true)
                }
            } catch {
                await MainActor.run {
                    result(FlutterError(code: "DRAWER_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func createConnectionSettings(from args: [String: Any]) -> StarConnectionSettings? {
        guard let interfaceTypeStr = args["interfaceType"] as? String,
              let identifier = args["identifier"] as? String else {
            return nil
        }

        let interfaceType = stringToInterfaceType(interfaceTypeStr)
        return StarConnectionSettings(interfaceType: interfaceType, identifier: identifier)
    }

    private func stringToInterfaceType(_ str: String) -> InterfaceType {
        switch str.lowercased() {
        case "lan":
            return .lan
        case "bluetooth":
            return .bluetooth
        case "bluetoothle":
            return .bluetoothLE
        case "usb":
            return .usb
        default:
            return .lan
        }
    }

    private func interfaceTypeToString(_ type: InterfaceType) -> String {
        switch type {
        case .lan:
            return "lan"
        case .bluetooth:
            return "bluetooth"
        case .bluetoothLE:
            return "bluetoothLE"
        case .usb:
            return "usb"
        @unknown default:
            return "lan"
        }
    }

    private func parseAlignment(_ alignment: String) -> StarXpandCommand.Printer.Alignment {
        switch alignment.lowercased() {
        case "center":
            return .center
        case "right":
            return .right
        default:
            return .left
        }
    }

    private func parseCutType(_ cutType: String) -> StarXpandCommand.Printer.CutType {
        switch cutType.lowercased() {
        case "fullcut":
            return .full
        case "partialcutwithfeed":
            return .partialWithFeed
        case "fullcutwithfeed":
            return .fullWithFeed
        default:
            return .partial
        }
    }

    private func parseBarcodeSymbology(_ symbology: String?) -> StarXpandCommand.Printer.BarcodeSymbology {
        guard let symbology = symbology else { return .code128 }

        switch symbology.lowercased() {
        case "code39":
            return .code39
        case "code93":
            return .code93
        case "itf":
            return .itf
        case "jan8":
            return .jan8
        case "jan13":
            return .jan13
        case "nw7":
            return .nw7
        case "upca":
            return .upcA
        case "upce":
            return .upcE
        default:
            return .code128
        }
    }

    private func parseQrCodeLevel(_ level: String?) -> StarXpandCommand.Printer.QRCodeLevel {
        guard let level = level else { return .l }

        switch level.lowercased() {
        case "h":
            return .h
        case "m":
            return .m
        case "q":
            return .q
        default:
            return .l
        }
    }

    private func parseEncoding(_ encoding: String) -> StarXpandCommand.Printer.CharacterEncodingType {
        switch encoding.uppercased() {
        case "US-ASCII":
            return .usAscii
        case "WINDOWS-1252":
            return .windows1252
        case "SHIFT-JIS":
            return .shiftJIS
        case "WINDOWS-1251":
            return .windows1251
        case "GB2312":
            return .gb2312
        case "BIG5":
            return .big5
        case "UTF-8":
            return .utf8
        default:
            return .utf8
        }
    }

    private func parseFontStyle(_ fontStyle: String) -> StarXpandCommand.Printer.FontType {
        switch fontStyle.lowercased() {
        case "a":
            return .a
        case "b":
            return .b
        default:
            return .a
        }
    }
}
