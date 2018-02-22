
Pod::Spec.new do |s|

  s.name         = "WKFullScreenPopGesture"
  s.version      = "0.1" 
  s.summary      = "A PopGesture with Swift"
  s.homepage     = "https://github.com/weaken000/WKFullScreenPopGesture"
  s.license      = "MIT"
  s.author       = { "weaken" => "845188093@qq.com" }
  s.source       = { :git => "https://github.com/weaken000/WKFullScreenPopGesture.git", :tag => "#{s.version}" }
  s.source_files  = "WKNavigationControllerPopGesture/*.swift"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
end
