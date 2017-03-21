Pod::Spec.new do |s|
  s.name     = 'CYCocoaPodsTest'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'just for test.'
  s.homepage = 'https://github.com/Ebbbb/CYCocoaPodsTest'
  s.author   = 'Ebbbb'
  s.source   = { :git => 'https://github.com/Ebbbb/CYCocoaPodsTest.git', :commit => 'a201138e90f2e1b7320ac110d866d78b34370f3f' }
  s.platform = :ios  
  s.source_files = 'CYCocoaPodsTest/TestClass/*.{h,m}'
  s.framework = 'UIKit'
  s.requires_arc = true  
end