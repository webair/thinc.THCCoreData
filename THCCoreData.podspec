Pod::Spec.new do |s|
  s.name         = "THCCoreData"
  s.version      = "0.0.1"
  s.summary      = "A Core Data wrapper"
  s.homepage     = 'https://github.com/webair/thinc.THCCoreData'
  s.license      = 'MIT'
  s.author         = { 'Weber Christopher' => 'chrisr.weber@gmail.com' }
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/webair/thinc.swift.THCCoreData.git", :tag => 'v0.0.1' }
  s.source_files  = "THCCoreData/**/*.swift"
  s.requires_arc = true
end
