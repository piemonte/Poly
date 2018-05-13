Pod::Spec.new do |s|
  s.name     = 'Poly'
  s.version  = '0.0.1'
  s.license = 'MIT'
  s.summary  = 'Unofficial Google Poly SDK'
  s.authors  = { "patrick piemonte" => "patrick.piemonte@gmail.com" }
  s.homepage = 'https://github.com/piemonte/Poly'
  s.source   = { :git => 'git@github.com:piemonte/Poly.git', :tag => s.version }
  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/*.swift'
  s.requires_arc = true
  s.swift_version = '4.0'
  s.dependency 'Alamofire', '4.7.2'
  s.dependency 'AlamofireNetworkActivityIndicator', '2.2.0'
  s.dependency 'Cache', '4.2.0'
  s.dependency 'ObjectMapper', '3.1.0'
  s.dependency 'PromiseKit', '6.2.5'
  s.dependency 'Disk', '0.3.3'
end
