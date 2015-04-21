Pod::Spec.new do |s|
  s.name         = "THCCoreData"
  s.version      = "0.0.2"
  s.summary      = "A Core Data wrapper"
  s.homepage     = 'https://github.com/webair/thinc.THCCoreData'
  s.license      = 'MIT'
  s.author         = { 'Weber Christopher' => 'chrisr.weber@gmail.com' }
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://code.sbb.ch/scm/kd_cp/sbbmapperlib-ios.git", :branch => 'develop' }
  s.source_files  = "THCCoreData/**/*.swift"
  s.requires_arc = true
end
