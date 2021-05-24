#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint umeng_push_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'umeng_push_sdk'
  s.version          = '0.0.1'
  s.summary          = 'upush sdk plugin.'
  s.description      = <<-DESC
upush sdk plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

    #老版本====begin
    # s.dependency 'UMCCommon','2.1.4'
    # s.dependency 'UMCAnalytics','6.1.0'
    # s.dependency 'UMCCommonLog','1.0.0'
    # s.dependency 'UMCPush','2.1.3'
    #老版本====bend
    #新版本====begin
    s.dependency 'UMCommon'
    s.dependency 'UMDevice'
    s.dependency 'UMPush'
    s.dependency 'UMCCommonLog'

    #新版本====end

    s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
