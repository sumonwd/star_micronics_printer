#include "star_micronics_printer_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace star_micronics_printer {

// static
void StarMicronicsPrinterPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "star_micronics_printer",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<StarMicronicsPrinterPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

StarMicronicsPrinterPlugin::StarMicronicsPrinterPlugin() {}

StarMicronicsPrinterPlugin::~StarMicronicsPrinterPlugin() {}

void StarMicronicsPrinterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method == "getPlatformVersion") {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  }
  else if (method == "searchPrinters") {
    result->Error("PLATFORM_NOT_SUPPORTED",
                  "Star Micronics printer plugin is not yet implemented for Windows. "
                  "Please use Android or iOS platforms.",
                  flutter::EncodableValue());
  }
  else if (method == "getStatus") {
    result->Error("PLATFORM_NOT_SUPPORTED",
                  "Star Micronics printer plugin is not yet implemented for Windows. "
                  "Please use Android or iOS platforms.",
                  flutter::EncodableValue());
  }
  else if (method == "print") {
    result->Error("PLATFORM_NOT_SUPPORTED",
                  "Star Micronics printer plugin is not yet implemented for Windows. "
                  "Please use Android or iOS platforms.",
                  flutter::EncodableValue());
  }
  else if (method == "printCommands") {
    result->Error("PLATFORM_NOT_SUPPORTED",
                  "Star Micronics printer plugin is not yet implemented for Windows. "
                  "Please use Android or iOS platforms.",
                  flutter::EncodableValue());
  }
  else if (method == "openCashDrawer") {
    result->Error("PLATFORM_NOT_SUPPORTED",
                  "Star Micronics printer plugin is not yet implemented for Windows. "
                  "Please use Android or iOS platforms.",
                  flutter::EncodableValue());
  }
  else {
    result->NotImplemented();
  }
}

}  // namespace star_micronics_printer
