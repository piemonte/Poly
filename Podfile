source 'https://cdn.cocoapods.org/'

platform :ios, '11.0'

# setup
workspace './Poly.xcworkspace'
swift_version = '5.0'
use_frameworks!

install! 'cocoapods', :disable_input_output_paths => true

def shared_pods
  pod 'Alamofire', '~> 4.9'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.4'
  pod 'PromiseKit', '~> 6.13'
  pod 'Cache', '~> 5.3'
  pod 'Disk', '~> 0.6'
  pod 'ObjectMapper', '~> 4.2'
end

target 'Poly' do
  shared_pods
end

target 'Poly_iOS' do
  pod 'IGListKit', '4.0.0'
  shared_pods
end
