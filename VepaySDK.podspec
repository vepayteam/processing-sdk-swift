Pod::Spec.new do |s|
  s.name             = 'VepaySDK'
  s.version          = '0.1.3'
  s.summary          = 'Cross-border transfers'
  s.homepage         = 'https://github.com/vepayteam/processing-sdk-swift'
  s.author           = { 
    'Bogdan' => 'bgrozyan@vepay.online' 
  }

  s.license          = { 
    :type => 'MIT', 
    :file => 'LICENSE' 
  }

  s.resources = [
    'VepaySDK/**/*.{storyboard,xcassets,ttf}
    'VepaySDK/Resources/Assets.xcassets', 
    'VepaySDK/Resources/Fonts/Inter Appeer/InterAppeer-SemiBoldItalic.ttf',
    'VepaySDK/Resources/Fonts/Inter Appeer/InterAppeer-SemiBold.ttf',
    'VepaySDK/Resources/Fonts/Inter/Inter-Regular.ttf',
    'VepaySDK/Resources/Fonts/Inter/Inter-SemiBold.ttf'
  ]

  s.source           = { 
    :git => 'https://github.com/vepayteam/processing-sdk-swift.git',
    :tag => s.version.to_s
  }
  s.source_files = 'VepaySDK/Sources/**/*.swift', '*.swift', 'VepaySDK/README.md'
  s.ios.deployment_target = '12.0'
  s.swift_versions = '5.0'
end