#
#  Be sure to run `pod spec lint YYLoginHelper.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "YYLoginHelper"
  s.version      = "0.0.1"
  s.summary      = "LC登录小助手."
  s.description  = "LC登录小助手."
  s.homepage     = "https://github.com/lingaoo/YYLoginHelper"
  s.author       = { "lingaoo" => "lingaooli@gmail.com" }
  s.platform     = :ios
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/lingaoo/YYLoginHelper.git", :tag => "#{s.version}" }
  s.source_files  = "Loginhelper", "Loginhelper/**/*.{h,m}"
  s.frameworks = "Foundation", "CoreGraphics", "UIKit"
  s.requires_arc = true
  # s.exclude_files = "YJ_Helper/Loginhelper"
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "SVProgressHUD"

end
