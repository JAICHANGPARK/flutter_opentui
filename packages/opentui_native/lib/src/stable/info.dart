import 'package:meta/meta.dart';

@immutable
final class OpenTuiNativeInfo {
  const OpenTuiNativeInfo({
    required this.os,
    required this.arch,
    required this.upstreamTag,
    required this.upstreamCommit,
    required this.libraryPath,
    required this.loadedSymbols,
  });

  final String os;
  final String arch;
  final String upstreamTag;
  final String upstreamCommit;
  final String? libraryPath;
  final Set<String> loadedSymbols;

  bool get isLoaded => libraryPath != null;
}
