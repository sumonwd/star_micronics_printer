#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint star_micronics_printer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'star_micronics_printer'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for integrating Star Micronics printers.'
  s.description      = <<-DESC
A Flutter plugin for integrating Star Micronics printers with Flutter applications.
Provides comprehensive printing functionality including receipt printing, barcode/QR code generation, and cash drawer control.

IMPORTANT: This plugin requires the StarIO10 SDK (StarXpand SDK) to be added manually via Swift Package Manager.
After running pod install, you must:
1. Open the iOS project in Xcode (ios/Runner.xcworkspace)
2. Select File > Add Packages...
3. Enter: https://github.com/star-micronics/StarXpand-SDK-iOS
4. Select the latest version and add to your project

Minimum iOS version: 14.0
                       DESC
  s.homepage         = 'https://github.com/phonetechbd/star_micronics_printer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'PhoneTech BD' => 'contact@phonetechbd.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'

  # Note: StarIO10 SDK must be added via Swift Package Manager
  # The SDK does not support CocoaPods integration
  # See installation instructions in the description above
end
