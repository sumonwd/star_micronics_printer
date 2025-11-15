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
#include <map>
#include <string>

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
  const std::string& method_name = method_call.method_name();

  if (method_name == "getPlatformVersion") {
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
  else if (method_name == "searchPrinters") {
    result->Error(
      "PLATFORM_NOT_SUPPORTED",
      "Windows platform is not currently supported. StarIO10 SDK is only available for Android and iOS. "
      "For Windows support, consider using the StarPRNT SDK for Windows Desktop (C#). "
      "See the Windows README for more information.",
      flutter::EncodableValue()
    );
  }
  else if (method_name == "getStatus") {
    result->Error(
      "PLATFORM_NOT_SUPPORTED",
      "Windows platform is not currently supported. StarIO10 SDK is only available for Android and iOS. "
      "For Windows support, consider using the StarPRNT SDK for Windows Desktop (C#). "
      "See the Windows README for more information.",
      flutter::EncodableValue()
    );
  }
  else if (method_name == "print") {
    result->Error(
      "PLATFORM_NOT_SUPPORTED",
      "Windows platform is not currently supported. StarIO10 SDK is only available for Android and iOS. "
      "For Windows support, consider using the StarPRNT SDK for Windows Desktop (C#). "
      "See the Windows README for more information.",
      flutter::EncodableValue()
    );
  }
  else if (method_name == "printCommands") {
    result->Error(
      "PLATFORM_NOT_SUPPORTED",
      "Windows platform is not currently supported. StarIO10 SDK is only available for Android and iOS. "
      "For Windows support, consider using the StarPRNT SDK for Windows Desktop (C#). "
      "See the Windows README for more information.",
      flutter::EncodableValue()
    );
  }
  else if (method_name == "openCashDrawer") {
    result->Error(
      "PLATFORM_NOT_SUPPORTED",
      "Windows platform is not currently supported. StarIO10 SDK is only available for Android and iOS. "
      "For Windows support, consider using the StarPRNT SDK for Windows Desktop (C#). "
      "See the Windows README for more information.",
      flutter::EncodableValue()
    );
  }
  else {
    result->NotImplemented();
  }
}

}  // namespace star_micronics_printer
