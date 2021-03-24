#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint google_ml_kit.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'google_ml_kit'
  s.version          = '0.0.1'
  s.summary          = 'flutter plugin for google ml kit'
  s.description      = <<-DESC
flutter plugin for google ml kit
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'GoogleMLKit/BarcodeScanning'
  s.dependency 'GoogleMLKit/FaceDetection'
  s.dependency 'GoogleMLKit/ImageLabeling'
  s.dependency 'GoogleMLKit/ImageLabelingCustom'
  s.dependency 'GoogleMLKit/ObjectDetection'
  s.dependency 'GoogleMLKit/ObjectDetectionCustom'
  s.dependency 'GoogleMLKit/PoseDetection'
  s.dependency 'GoogleMLKit/PoseDetectionAccurate'
  s.dependency 'GoogleMLKit/SegmentationSelfie'
  s.dependency 'GoogleMLKit/TextRecognition'
  s.ios.deployment_target = '10.0'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
