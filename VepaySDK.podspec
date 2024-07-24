src_dir = ENV.fetch("GITHUB_WORKSPACE", __dir__)
local_run = true if ENV.fetch("GITEA_ACTIONS", "false") == "true"

Pod::Spec.new do |s|
  s.name = 'VepaySDK'
  s.summary = 'Cross-border transfers'
  s.homepage = 'https://github.com/vepayteam/processing-sdk-swift'
  s.author = {
    'Богдан Грозян' => 'bgrozyan@vepay.online'
  }

  begin
    s.version = Gem::Version.new(ENV["GITHUB_REF_NAME"]).release.to_s
  rescue
    s.version = "0.1.4"
  end

  s.license = {
    :type => 'MIT',
    :file => "LICENSE"
  }

  s.ios.deployment_target = '12.0'
  s.swift_versions = '5.0'

  s.resources = [
    "VepaySDK/**/*.{storyboard,xib,xcassets,ttf}"
  ]

  if local_run
    zipfile = File.join(ENV.fetch("RUNNER_TEMP", Dir.tmpdir), "#{s.name}.zip")
    File.delete(zipfile) if File.exist?(zipfile)

    system("zip -r #{zipfile} #{src_dir} > /dev/null")
    s.source = { :http => "file://#{zipfile}" }
  else
    s.source = {
      :git => 'https://github.com/vepayteam/processing-sdk-swift.git',
      :tag => ENV["GITHUB_REF_NAME"] || s.version
    }
  end

  s.requires_arc = local_run
  s.source_files = 'VepaySDK/**/*.{h,m,swift}', 'VepaySDK/README.md'
  s.public_header_files = "VepaySDK/**/*.h"
end