#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_opentui.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_opentui'
  s.version          = '0.1.0'
  s.summary          = 'Canonical Flutter plugin for OpenTUI.'
  s.description      = <<-DESC
Canonical Flutter plugin for rendering OpenTUI frames.
                       DESC
  s.homepage         = 'https://github.com/jaichang/flutter_opentui'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'OpenTUI Dart Contributors' => 'opensource@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_opentui_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
