Pod::Spec.new do |spec|
  spec.name         = "KeyboardGuide"
  spec.version      = "0.2.0"
  spec.summary      = "A modern, real iOS keyboard system notifications handler framework that Just Works."
  spec.description  = <<-DESC
  A modern, real iOS keyboard system notifications handler framework that Just Works.
  Based on years experience of iOS application development and various tests on each iOS version and device, it supports both Swift and Objective-C and works mostly reasonably on the latest 3 versions of iOS, which is iOS 11, 12 and iOS 13 now, and covers almost all iOS users.
                   DESC

  spec.homepage     = "https://github.com/niw/KeyboardGuide"
  spec.license      = "MIT"
  spec.author       = { "Yoshimasa Niwa" => "email@address.com" }

  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/niw/KeyboardGuide.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources", "Sources/**/*.{h,m,swift}"
  spec.exclude_files = "Sources/Exclude"

  spec.swift_version = '4.2'
end
