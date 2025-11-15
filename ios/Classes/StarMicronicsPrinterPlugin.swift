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
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
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
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }

    let timeout = args["timeout"] as? Int ?? 10000
    var printers: [[String: Any]] = []

    let manager = StarDeviceDiscoveryManagerFactory.create(interfaceTypes: [.lan, .bluetooth, .bluetoothLE, .usb])

    manager.discoveryTime = TimeInterval(timeout) / 1000.0

    manager.onPrinterFound = { printer in
      printers.append([
        "model": printer.information?.model.rawValue ?? "Unknown",
        "identifier": printer.connectionSettings.identifier,
        "interfaceType": self.interfaceTypeToString(printer.connectionSettings.interfaceType),
        "emulation": printer.information?.emulation.rawValue ?? ""
      ])
    }

    manager.onDiscoveryFinished = {
      result(printers)
    }

    do {
      try manager.startDiscovery()
    } catch {
      result(FlutterError(code: "SEARCH_ERROR", message: error.localizedDescription, details: nil))
    }
  }

  // MARK: - Get Status

  private func getStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let settings = createConnectionSettings(call: call) else {
      result(FlutterError(code: "INVALID_SETTINGS", message: "Invalid connection settings", details: nil))
      return
    }

    let printer = StarPrinter(settings)

    Task {
      do {
        try await printer.open()
        defer {
          Task {
            await printer.close()
          }
        }

        let status = try await printer.getStatus()

        let statusMap: [String: Any] = [
          "online": !(status.coverOpen || status.paperEmpty),
          "coverOpen": status.coverOpen,
          "paperEmpty": status.paperEmpty,
          "paperNearEmpty": status.paperNearEmpty,
          "drawerOpen": status.drawerOpenCloseSignal
        ]

        DispatchQueue.main.async {
          result(statusMap)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "STATUS_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  // MARK: - Print

  private func print(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let settings = createConnectionSettings(call: call),
          let commandString = args["command"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }

    let printer = StarPrinter(settings)

    Task {
      do {
        try await printer.open()
        defer {
          Task {
            await printer.close()
          }
        }

        let builder = StarXpandCommand.StarXpandCommandBuilder()
        _ = builder.addDocument(StarXpandCommand.DocumentBuilder()
          .addPrinter(StarXpandCommand.PrinterBuilder()
            .actionPrintText(commandString)
            .actionCut(.partial)
          )
        )

        let commands = try builder.getCommands()
        try await printer.print(command: commands)

        DispatchQueue.main.async {
          result(true)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "PRINT_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  // MARK: - Print Commands

  private func printCommands(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let settings = createConnectionSettings(call: call),
          let commandsList = args["commands"] as? [[String: Any]] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }

    let printer = StarPrinter(settings)

    Task {
      do {
        try await printer.open()
        defer {
          Task {
            await printer.close()
          }
        }

        let builder = StarXpandCommand.StarXpandCommandBuilder()
        let printerBuilder = StarXpandCommand.PrinterBuilder()

        // Process commands
        processCommands(printerBuilder: printerBuilder, commandsList: commandsList)

        _ = builder.addDocument(StarXpandCommand.DocumentBuilder().addPrinter(printerBuilder))
        let commands = try builder.getCommands()

        try await printer.print(command: commands)

        DispatchQueue.main.async {
          result(true)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "PRINT_COMMANDS_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  // MARK: - Process Commands

  private func processCommands(printerBuilder: StarXpandCommand.PrinterBuilder, commandsList: [[String: Any]]) {
    for cmd in commandsList {
      // Text commands
      if let text = cmd["appendText"] as? String {
        _ = printerBuilder.actionPrintText(text)
      }
      else if let text = cmd["appendTextMagnified"] as? String {
        let width = cmd["width"] as? Int ?? 1
        let height = cmd["height"] as? Int ?? 1
        _ = printerBuilder
          .styleMagnification(StarXpandCommand.MagnificationParameter(width: width, height: height))
          .actionPrintText(text)
          .styleMagnification(StarXpandCommand.MagnificationParameter(width: 1, height: 1))
      }
      else if let text = cmd["appendTextBold"] as? String {
        _ = printerBuilder
          .styleBold(true)
          .actionPrintText(text)
          .styleBold(false)
      }
      // Alignment
      else if let alignment = cmd["setAlignment"] as? String {
        _ = printerBuilder.styleAlignment(parseAlignment(alignment))
      }
      // Styles
      else if let bold = cmd["setBold"] as? Bool {
        _ = printerBuilder.styleBold(bold)
      }
      else if cmd.keys.contains("setMagnification") {
        let width = cmd["width"] as? Int ?? 1
        let height = cmd["height"] as? Int ?? 1
        _ = printerBuilder.styleMagnification(StarXpandCommand.MagnificationParameter(width: width, height: height))
      }
      // Paper control
      else if let cutType = cmd["appendCutPaper"] as? String {
        _ = printerBuilder.actionCut(parseCutType(cutType))
      }
      else if let lines = cmd["feedLine"] as? Int {
        _ = printerBuilder.actionFeedLine(lines)
      }
      // Barcode
      else if let data = cmd["appendBarcode"] as? String {
        let symbology = parseBarcodeSymbology(cmd["symbology"] as? String)
        let height = cmd["height"] as? Int ?? 40

        let parameter = StarXpandCommand.Printer.BarcodeParameter(content: data, symbology: symbology)
          .setHeight(Double(height))

        _ = printerBuilder.actionPrintBarcode(parameter: parameter)
      }
      // QR Code
      else if let data = cmd["appendQrCode"] as? String {
        let level = parseQRCodeLevel(cmd["level"] as? String)
        let cellSize = cmd["cellSize"] as? Int ?? 8

        let parameter = StarXpandCommand.Printer.QRCodeParameter(content: data)
          .setLevel(level)
          .setCellSize(cellSize)

        _ = printerBuilder.actionPrintQRCode(parameter: parameter)
      }
      // Image
      else if let imageData = cmd["appendBitmapByteArray"] as? FlutterStandardTypedData {
        let width = cmd["width"] as? Int ?? 576

        if let image = UIImage(data: imageData.data) {
          let parameter = StarXpandCommand.Printer.ImageParameter(image: image, width: width)
          _ = printerBuilder.actionPrintImage(parameter: parameter)
        }
      }
    }
  }

  // MARK: - Open Cash Drawer

  private func openCashDrawer(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let settings = createConnectionSettings(call: call) else {
      result(FlutterError(code: "INVALID_SETTINGS", message: "Invalid connection settings", details: nil))
      return
    }

    let printer = StarPrinter(settings)

    Task {
      do {
        try await printer.open()
        defer {
          Task {
            await printer.close()
          }
        }

        let builder = StarXpandCommand.StarXpandCommandBuilder()
        _ = builder.addDocument(StarXpandCommand.DocumentBuilder()
          .addDrawer(StarXpandCommand.DrawerBuilder()
            .actionOpen(StarXpandCommand.Drawer.OpenParameter())
          )
        )

        let commands = try builder.getCommands()
        try await printer.print(command: commands)

        DispatchQueue.main.async {
          result(true)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "DRAWER_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  // MARK: - Helper Methods

  private func createConnectionSettings(call: FlutterMethodCall) -> StarConnectionSettings? {
    guard let args = call.arguments as? [String: Any],
          let interfaceTypeStr = args["interfaceType"] as? String,
          let identifier = args["identifier"] as? String else {
      return nil
    }

    let interfaceType = parseInterfaceType(interfaceTypeStr)
    return StarConnectionSettings(interfaceType: interfaceType, identifier: identifier)
  }

  private func parseInterfaceType(_ type: String) -> InterfaceType {
    switch type.lowercased() {
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
      return "bluetoothle"
    case .usb:
      return "usb"
    default:
      return "unknown"
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
      return .partial
    default:
      return .partial
    }
  }

  private func parseBarcodeSymbology(_ symbology: String?) -> StarXpandCommand.Printer.BarcodeSymbology {
    guard let symbology = symbology?.lowercased() else {
      return .code128
    }

    switch symbology {
    case "code39":
      return .code39
    case "code93":
      return .code93
    case "jan8":
      return .jan8
    case "jan13":
      return .jan13
    default:
      return .code128
    }
  }

  private func parseQRCodeLevel(_ level: String?) -> StarXpandCommand.Printer.QRCodeLevel {
    guard let level = level?.lowercased() else {
      return .l
    }

    switch level {
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
}
