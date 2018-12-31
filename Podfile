# include public/private pods
source 'git@github.com:cocoapods/Specs.git'

platform :ios, '11.0'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# setup
workspace './Poly.xcworkspace'
swift_version = '4.2'
use_frameworks!

def shared_pods
  pod 'Alamofire', '~> 4.8'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.3'
  pod 'PromiseKit', '~> 6.7'
  pod 'Cache', '~> 5.2'
  pod 'Disk', '~> 0.4'
  pod 'ObjectMapper', '~> 3.4'
end

target 'Poly' do
  shared_pods
end

target 'Poly_iOS' do
  pod 'IGListKit', '3.4.0'
  shared_pods
end
