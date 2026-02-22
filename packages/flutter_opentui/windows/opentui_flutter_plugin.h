#ifndef FLUTTER_PLUGIN_OPENTUI_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_OPENTUI_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace opentui_flutter {

class OpenTuiFlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  OpenTuiFlutterPlugin();

  virtual ~OpenTuiFlutterPlugin();

  // Disallow copy and assign.
  OpenTuiFlutterPlugin(const OpenTuiFlutterPlugin&) = delete;
  OpenTuiFlutterPlugin& operator=(const OpenTuiFlutterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace opentui_flutter

#endif  // FLUTTER_PLUGIN_OPENTUI_FLUTTER_PLUGIN_H_
