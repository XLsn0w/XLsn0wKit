
Pod::Spec.new do |s|

  s.version      = "3.2.1"

  s.name         = "XLsn0wKit"
  s.summary      = 'A collection of iOS components from XLsn0wKit'
  s.description  = "XLsn0w Create A collection of iOS components from XLsn0wKit"
  s.homepage     = "https://github.com/XLsn0w/XLsn0wKit"
  s.author       = { "XLsn0w" => "xlsn0w@qq.com" }
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'

  s.source       = { :git => "https://github.com/XLsn0w/XLsn0wKit.git", :tag => s.version.to_s }
  s.source_files = "XLsn0wClass/**/*.{h,m}"
  s.public_header_files = 'XLsn0wClass/**/*.{h}'

  s.requires_arc = true

  s.libraries = 'z', 'sqlite3'
  s.frameworks = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore', 'ImageIO', 'AssetsLibrary', 'Accelerate', 'MobileCoreServices', 'SystemConfiguration'
  s.ios.vendored_frameworks = 'XLsn0wClass/Frameworks/WebP.framework'

end
