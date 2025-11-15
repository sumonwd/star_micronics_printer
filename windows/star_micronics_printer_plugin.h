#ifndef FLUTTER_PLUGIN_STAR_MICRONICS_PRINTER_PLUGIN_H_
#define FLUTTER_PLUGIN_STAR_MICRONICS_PRINTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace star_micronics_printer {

class StarMicronicsPrinterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  StarMicronicsPrinterPlugin();

  virtual ~StarMicronicsPrinterPlugin();

  // Disallow copy and assign.
  StarMicronicsPrinterPlugin(const StarMicronicsPrinterPlugin&) = delete;
  StarMicronicsPrinterPlugin& operator=(const StarMicronicsPrinterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace star_micronics_printer

#endif  // FLUTTER_PLUGIN_STAR_MICRONICS_PRINTER_PLUGIN_H_
