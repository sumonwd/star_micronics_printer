#include "include/star_micronics_printer/star_micronics_printer_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "star_micronics_printer_plugin.h"

void StarMicronicsPrinterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  star_micronics_printer::StarMicronicsPrinterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
