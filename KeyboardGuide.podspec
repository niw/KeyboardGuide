Pod::Spec.new do |spec|
  spec.name = 'KeyboardGuide'
  spec.version = '0.2.1'
  spec.author = {
    'Yoshimasa Niwa' => 'niw@niw.at'
  }
  spec.summary = 'A modern, real iOS keyboard system notifications handler framework that Just Works.'
  spec.license = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  spec.homepage = 'https://github.com/niw/KeyboardGuide'
  spec.swift_versions = '5.2'
  spec.platform = :ios, '11.0'
  spec.source = {
    :git => 'https://github.com/niw/KeyboardGuide.git',
    :tag => spec.version.to_s
  }
  spec.source_files  = 'Sources/KeyboardGuide/*.swift'
end
