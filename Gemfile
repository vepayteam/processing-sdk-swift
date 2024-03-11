# frozen_string_literal: true

source "https://rubygems.org"

gem "fastlane", "~> 2.219"
gem "cocoapods"
gem "cocoapods-packager-next"
gem 'slather'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
