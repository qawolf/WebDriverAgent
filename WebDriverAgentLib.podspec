libFolder = 'WebDriverAgentLib'

public_headers = [
  "#{libFolder}/Routing/FBWebServer.h",
  "#{libFolder}/Utilities/FBConfiguration.h",
  "#{libFolder}/Utilities/FBDebugLogDelegateDecorator.h",
  "PrivateHeaders/XCTest/XCDebugLogDelegate-Protocol.h"
]

project_headers = Dir.glob("#{libFolder}/**/*.h") + Dir.glob("PrivateHeaders/**/*.h") - public_headers

source_files = "#{libFolder}/**/*.{h,m}", "PrivateHeaders/**/*.h"

xcconfig_path = "Configurations/IOSSettings.xcconfig"

Pod::Spec.new do |s|
    s.name         = 'WebDriverAgentLib'
    s.version      = '1.0.0'
    s.summary      = 'A brief description of WebDriverAgent.'
    s.license      = { :type => 'BSD', :file => "LICENSE" }
    s.description  = <<-DESC
                     A more detailed description of WebDriverAgent.
                     DESC
    s.homepage     = 'https://example.com/WebDriverAgent'
    s.author       = { 'Author' => 'author@example.com' }
    s.source       = { :git => 'https://github.com/appium/WebDriverAgent.git', :tag => s.version.to_s }
    s.platform     = :ios, '12.0'
    s.frameworks   = 'XCTest'
    s.public_header_files = public_headers
    s.project_header_files = project_headers
    s.source_files = source_files
    s.pod_target_xcconfig = File.open(File.join(Dir.pwd, xcconfig_path)) do |file|
      Hash[file.each_line.map { |line| line.strip.empty? ? next : line.split("=", 2) }.compact]
    end
    s.user_target_xcconfig = File.open(File.join(Dir.pwd, xcconfig_path)) do |file|
      Hash[file.each_line.map { |line| line.strip.empty? ? next : line.split("=", 2) }.compact]
    end
  end
