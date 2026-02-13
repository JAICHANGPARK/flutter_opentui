#include "include/opentui_flutter/opentui_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "opentui_flutter_plugin.h"

void OpenTuiFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  opentui_flutter::OpenTuiFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
