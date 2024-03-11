build_src = true if ENV.fetch("BUILD_SRC", "true") == "true"

Pod::Spec.new do |s|
  s.name = 'VepaySDK'
  s.version = "0.1.3"
  s.summary = 'Cross-border transfers'
  s.homepage = 'https://github.com/vepayteam/processing-sdk-swift'
  s.author = {
    'Богдан Грозян' => 'bgrozyan@vepay.online'
  }

  s.license = {
    :type => 'MIT',
    :file => "#{__dir__}/LICENSE"
  }

  s.resources = [
    "VepaySDK/**/*.{storyboard,xib,xcassets,ttf}"
  ]

  if build_src
    src_dir = ENV.fetch("DRONE_WORKSPACE", __dir__)
    zipfile = "#{src_dir}/VepaySDK.zip"
    File.delete(zipfile) if File.exist?(zipfile)

    system("zip -r #{zipfile} #{__dir__} > /dev/null")
    s.source = { :http => "file://#{zipfile}" }
  else
    s.source = {
      :git => 'https://github.com/vepayteam/processing-sdk-swift.git',
      :tag => ENV["DRONE_TAG"] || s.version
    }
  end

  s.source_files = 'VepaySDK/Sources/**/*.swift', 'VepaySDK/Resources/Support.swift', 'VepaySDK/README.md'
  s.requires_arc = build_src
  s.ios.deployment_target = '12.0'
  s.swift_versions = '5.0'
end