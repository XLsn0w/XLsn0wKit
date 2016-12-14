
Pod::Spec.new do |s|

  s.version               = "3.8.8"

  s.summary               = 'An iOS Components Framework Born Of XLsn0wKit'

  s.author                = { "XLsn0w" => "xlsn0w@qq.com" }

  s.requires_arc          = true
  s.ios.deployment_target = '7.0'
  s.platform              = :ios, '7.0'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }

  s.name                  = "XLsn0wKit"
  s.homepage              = "https://github.com/XLsn0w/XLsn0wKit"
  s.source                = { :git => "https://github.com/XLsn0w/XLsn0wKit.git", :tag => s.version.to_s }

  s.source_files          = "XLsn0w/**/*.{h,m}"

  s.resources             = "XLsn0w/Resources/XLsn0wKit.bundle"

  s.libraries             = 'z', 'sqlite3'

  s.frameworks            = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore', 'ImageIO', 'AssetsLibrary', 'Accelerate', 'MobileCoreServices', 'SystemConfiguration', 'AVFoundation'

  s.dependency "AFNetworking"
  s.dependency 'SDWebImage'
  s.dependency 'Masonry'
  s.dependency 'MBProgressHUD'

end
