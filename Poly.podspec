Pod::Spec.new do |s|
  s.name     = 'Poly'
  s.version  = '0.1.2'
  s.license  = 'MIT'
  s.summary  = 'Unofficial Google Poly SDK'
  s.authors  = { "patrick piemonte" => "patrick.piemonte@gmail.com" }
  s.homepage = 'https://github.com/piemonte/Poly'
  s.source   = { :git => 'https://github.com/piemonte/Poly.git', :tag => s.version }
  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/*.swift'
  s.requires_arc = true
  s.swift_version = '4.2'
  s.dependency 'Alamofire', '~> 4.8'
  s.dependency 'AlamofireNetworkActivityIndicator', '~> 2.3'
  s.dependency 'PromiseKit', '~> 6.7'
  s.dependency 'Cache', '~> 5.2'
  s.dependency 'Disk', '~> 0.4'
  s.dependency 'ObjectMapper', '~> 3.4'
end
