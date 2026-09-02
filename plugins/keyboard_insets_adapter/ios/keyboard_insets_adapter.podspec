Pod::Spec.new do |s|
  s.name             = 'keyboard_insets_adapter'
  s.version          = '0.1.0'
  s.summary          = 'Thin native keyboard inset data source for Flutter.'
  s.description      = <<-DESC
    Local Flutter plugin that emits native keyboard overlap height, progress,
    and visibility without shipping higher-level keyboard-aware widgets.
  DESC
  s.homepage         = 'https://example.invalid/learn-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tuan Nguyen Cong' => 'nguyencongtuan.devmobile@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
