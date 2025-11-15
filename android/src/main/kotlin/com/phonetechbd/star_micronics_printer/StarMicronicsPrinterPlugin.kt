package com.phonetechbd.star_micronics_printer

import android.content.Context
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import com.starmicronics.stario10.*
import com.starmicronics.stario10.starxpandcommand.*
import com.starmicronics.stario10.starxpandcommand.printer.Printer
import com.starmicronics.stario10.starxpandcommand.drawer.Drawer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

class StarMicronicsPrinterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "star_micronics_printer")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "searchPrinters" -> searchPrinters(call, result)
            "getStatus" -> getStatus(call, result)
            "print" -> print(call, result)
            "printCommands" -> printCommands(call, result)
            "openCashDrawer" -> openCashDrawer(call, result)
            else -> result.notImplemented()
        }
    }

    private fun searchPrinters(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val timeout = call.argument<Int>("timeout") ?: 10000
                val printers = mutableListOf<Map<String, Any>>()

                val manager = StarDeviceDiscoveryManagerFactory.create(
                    listOf(InterfaceType.Lan, InterfaceType.Bluetooth, InterfaceType.Usb),
                    context
                )

                manager.discoveryTime = timeout
                manager.callback = object : StarDeviceDiscoveryManager.Callback {
                    override fun onPrinterFound(printer: StarPrinter) {
                        printers.add(
                            mapOf(
                                "model" to (printer.information?.model ?: "Unknown"),
                                "identifier" to printer.connectionSettings.identifier,
                                "interfaceType" to printer.connectionSettings.interfaceType.name.lowercase(),
                                "emulation" to (printer.information?.emulation?.name ?: "")
                            )
                        )
                    }

                    override fun onDiscoveryFinished() {
                        result.success(printers)
                    }
                }

                manager.startDiscovery()
            } catch (e: Exception) {
                result.error("SEARCH_ERROR", e.message, null)
            }
        }
    }

    private fun getStatus(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val settings = createConnectionSettings(call)
                val printer = StarPrinter(settings, context)

                withContext(Dispatchers.IO) {
                    printer.openAsync().await()
                    val status = printer.getStatusAsync().await()
                    printer.closeAsync().await()

                    val statusMap = mapOf(
                        "online" to (status.coverOpen == false && status.paperEmpty == false),
                        "coverOpen" to (status.coverOpen == true),
                        "paperEmpty" to (status.paperEmpty == true),
                        "paperNearEmpty" to (status.paperNearEmpty == true),
                        "drawerOpen" to (status.drawerOpenCloseSignal == true)
                    )

                    withContext(Dispatchers.Main) {
                        result.success(statusMap)
                    }
                }
            } catch (e: Exception) {
                result.error("STATUS_ERROR", e.message, null)
            }
        }
    }

    private fun print(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val settings = createConnectionSettings(call)
                val commandString = call.argument<String>("command") ?: ""
                val printer = StarPrinter(settings, context)

                withContext(Dispatchers.IO) {
                    printer.openAsync().await()
                    
                    val job = StarXpandCommandBuilder()
                    job.addDocument(
                        DocumentBuilder().addPrinter(
                            PrinterBuilder()
                                .actionPrintText(commandString)
                                .actionCut(Printer.CutType.Partial)
                        )
                    )

                    val command = job.getCommands()
                    printer.printAsync(command).await()
                    printer.closeAsync().await()

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                }
            } catch (e: Exception) {
                result.error("PRINT_ERROR", e.message, null)
            }
        }
    }

    private fun printCommands(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val settings = createConnectionSettings(call)
                @Suppress("UNCHECKED_CAST")
                val commandsList = call.argument<List<Map<String, Any>>>("commands") ?: emptyList()
                val printer = StarPrinter(settings, context)

                withContext(Dispatchers.IO) {
                    printer.openAsync().await()
                    
                    val builder = StarXpandCommandBuilder()
                    val printerBuilder = PrinterBuilder()
                    
                    // Process commands
                    processCommands(printerBuilder, commandsList)
                    
                    builder.addDocument(DocumentBuilder().addPrinter(printerBuilder))
                    val commands = builder.getCommands()
                    
                    printer.printAsync(commands).await()
                    printer.closeAsync().await()

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                }
            } catch (e: Exception) {
                result.error("PRINT_COMMANDS_ERROR", e.message, null)
            }
        }
    }

    private fun processCommands(builder: PrinterBuilder, commandsList: List<Map<String, Any>>) {
        for (cmd in commandsList) {
            when {
                // Text commands
                cmd.containsKey("appendText") -> {
                    builder.actionPrintText(cmd["appendText"] as String)
                }
                cmd.containsKey("appendTextMagnified") -> {
                    val text = cmd["appendTextMagnified"] as String
                    val width = (cmd["width"] as? Int) ?: 1
                    val height = (cmd["height"] as? Int) ?: 1
                    builder.styleMagnification(MagnificationParameter(width, height))
                        .actionPrintText(text)
                        .styleMagnification(MagnificationParameter(1, 1))
                }
                cmd.containsKey("appendTextBold") -> {
                    builder.styleBold(true)
                        .actionPrintText(cmd["appendTextBold"] as String)
                        .styleBold(false)
                }
                
                // Alignment
                cmd.containsKey("setAlignment") -> {
                    val alignment = when(cmd["setAlignment"] as String) {
                        "center" -> Printer.Alignment.Center
                        "right" -> Printer.Alignment.Right
                        else -> Printer.Alignment.Left
                    }
                    builder.styleAlignment(alignment)
                }
                
                // Styles
                cmd.containsKey("setBold") -> {
                    builder.styleBold(cmd["setBold"] as Boolean)
                }
                cmd.containsKey("setMagnification") -> {
                    val width = (cmd["width"] as? Int) ?: 1
                    val height = (cmd["height"] as? Int) ?: 1
                    builder.styleMagnification(MagnificationParameter(width, height))
                }
                
                // Paper control
                cmd.containsKey("appendCutPaper") -> {
                    val cutType = when(cmd["appendCutPaper"] as String) {
                        "fullCut" -> Printer.CutType.Full
                        "partialCutWithFeed" -> Printer.CutType.PartialWithFeed
                        else -> Printer.CutType.Partial
                    }
                    builder.actionCut(cutType)
                }
                cmd.containsKey("feedLine") -> {
                    builder.actionFeedLine(cmd["feedLine"] as Int)
                }
                
                // Barcode
                cmd.containsKey("appendBarcode") -> {
                    val data = cmd["appendBarcode"] as String
                    val symbology = parseBarcodeSymbology(cmd["symbology"] as? String)
                    val height = ((cmd["height"] as? Int) ?: 40).toDouble()
                    val hri = cmd["hri"] as? Boolean ?: false
                    
                    val parameter = Printer.BarcodeParameter(data, symbology)
                        .setHeight(height)
                        .setPrintHRI(hri)
                    
                    builder.actionPrintBarcode(parameter)
                }
                
                // QR Code
                cmd.containsKey("appendQrCode") -> {
                    val data = cmd["appendQrCode"] as String
                    val level = parseQrCodeLevel(cmd["level"] as? String)
                    val cellSize = (cmd["cellSize"] as? Int) ?: 8
                    
                    val parameter = Printer.QRCodeParameter(data)
                        .setLevel(level)
                        .setCellSize(cellSize)
                    
                    builder.actionPrintQRCode(parameter)
                }
                
                // Image
                cmd.containsKey("appendBitmapByteArray") -> {
                    val byteArray = cmd["appendBitmapByteArray"] as ByteArray
                    val width = (cmd["width"] as? Int) ?: 576
                    
                    try {
                        val bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
                        if (bitmap != null) {
                            builder.actionPrintImage(Printer.ImageParameter(bitmap, width))
                        }
                    } catch (e: Exception) {
                        // Handle error
                    }
                }
            }
        }
    }

    private fun parseBarcodeSymbology(symbology: String?): Printer.BarcodeSymbology {
        return when(symbology?.lowercase()) {
            "code39" -> Printer.BarcodeSymbology.Code39
            "code93" -> Printer.BarcodeSymbology.Code93
            "jan8" -> Printer.BarcodeSymbology.Jan8
            "jan13" -> Printer.BarcodeSymbology.Jan13
            else -> Printer.BarcodeSymbology.Code128
        }
    }

    private fun parseQrCodeLevel(level: String?): Printer.QRCodeLevel {
        return when(level?.lowercase()) {
            "h" -> Printer.QRCodeLevel.H
            "m" -> Printer.QRCodeLevel.M
            "q" -> Printer.QRCodeLevel.Q
            else -> Printer.QRCodeLevel.L
        }
    }

    private fun openCashDrawer(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val settings = createConnectionSettings(call)
                val printer = StarPrinter(settings, context)

                withContext(Dispatchers.IO) {
                    printer.openAsync().await()
                    
                    val job = StarXpandCommandBuilder()
                    job.addDocument(
                        DocumentBuilder().addDrawer(
                            DrawerBuilder().actionOpen(Drawer.Channel.No1)
                        )
                    )

                    val command = job.getCommands()
                    printer.printAsync(command).await()
                    printer.closeAsync().await()

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                }
            } catch (e: Exception) {
                result.error("DRAWER_ERROR", e.message, null)
            }
        }
    }

    private fun createConnectionSettings(call: MethodCall): StarConnectionSettings {
        val interfaceTypeStr = call.argument<String>("interfaceType") ?: "lan"
        val identifier = call.argument<String>("identifier") ?: ""

        val interfaceType = when (interfaceTypeStr.lowercase()) {
            "lan" -> InterfaceType.Lan
            "bluetooth" -> InterfaceType.Bluetooth
            "bluetoothle" -> InterfaceType.BluetoothLE
            "usb" -> InterfaceType.Usb
            else -> InterfaceType.Lan
        }

        return StarConnectionSettings(interfaceType, identifier)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }
}