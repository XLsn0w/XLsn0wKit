
Pod::Spec.new do |s|

  s.version      = "2.1.3"

  s.name         = "XLsn0wKit"
  s.summary      = 'A collection of iOS components from XLsn0wKit.'
  s.description  = "Copyright © 2016年 XLsn0w Create A collection of iOS components from XLsn0wKit."
  s.homepage     = "https://github.com/XLsn0w/XLsn0wKit"
  s.author       = { "XLsn0w" => "xlsn0w@qq.com" }
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'

  s.source       = { :git => "https://github.com/XLsn0w/XLsn0wKit.git", :tag => s.version.to_s }
  s.source_files = "XLsn0w/**/*.{h,m}"
  s.public_header_files = 'XLsn0w/**/*.{h}'

  s.requires_arc = true

  non_arc_files = 'XLsn0w/no-arc/NSObject+XLsn0wAddForARC.{h,m}', 'XLsn0w/no-arc/NSThread+XLsn0wAdd.{h,m}'
  s.ios.exclude_files = non_arc_files
  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
  end

  s.libraries = 'z', 'sqlite3'
  s.frameworks = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore', 'ImageIO', 'AssetsLibrary', 'Accelerate', 'MobileCoreServices', 'SystemConfiguration'
  s.ios.vendored_frameworks = 'XLsn0w/Frameworks/WebP.framework'

end
