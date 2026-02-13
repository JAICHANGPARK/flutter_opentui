import 'package:opentui_native/opentui_native.dart';

void main() {
  final library = OpenTuiNativeLibrary.auto();
  final info = library.info;

  print('opentui_native');
  print('  os: ${info.os}');
  print('  arch: ${info.arch}');
  print('  loaded: ${info.isLoaded}');
  print('  libraryPath: ${info.libraryPath ?? 'not found'}');
  print('  loadedSymbols: ${info.loadedSymbols.length}');
}
