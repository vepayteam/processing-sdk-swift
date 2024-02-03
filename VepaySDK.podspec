Pod::Spec.new do |s|
  s.name             = 'VepaySDK'
  s.version          = '0.1.0'
  s.summary          = 'Cross-border transfers'
  s.homepage         = 'https://github.com/vepayteam/processing-sdk-swift'
  s.author           = { 
    'Bogdan' => 'bgrozyan@vepay.online' 
  }

  s.license          = { 
    :type => 'MIT', 
    :file => 'LICENSE' 
  }

  s.source           = { 
    :git => 'https://github.com/vepayteam/processing-sdk-swift.git', 
    :tag => s.version.to_s 
  }
  s.source_files = '**/*.swift', '*.swift'
  s.ios.deployment_target = '13.0'
  s.swift_versions = '5.0'
end