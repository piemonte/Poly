Pod::Spec.new do |s|
  s.name     = 'Poly'
  s.version  = '0.3.0'
  s.license  = 'MIT'
  s.summary  = 'Unofficial Google Poly SDK'
  s.authors  = { "patrick piemonte" => "patrick.piemonte@gmail.com" }
  s.homepage = 'https://github.com/piemonte/Poly'
  s.source   = { :git => 'https://github.com/piemonte/Poly.git', :tag => s.version }
  s.documentation_url = 'https://piemonte.github.io/Poly/'
  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/*.swift'
  s.requires_arc = true
  s.swift_version = '5.0'
  s.dependency 'Alamofire', '~> 4.9'
  s.dependency 'AlamofireNetworkActivityIndicator', '~> 2.4'
  s.dependency 'PromiseKit', '~> 6.11'
  s.dependency 'Disk', '~> 0.6'
  s.dependency 'ObjectMapper', '~> 3.5'
  s.dependency 'Cache', '~> 5.2'
end
