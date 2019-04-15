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
  pod 'PromiseKit', '~> 6.8'
  pod 'Cache', '~> 5.2'
  pod 'Disk', '~> 0.6'
  pod 'ObjectMapper', '~> 3.4'
end

target 'Poly' do
  shared_pods
end

target 'Poly_iOS' do
  pod 'IGListKit', '3.4.0'
  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Cache'
      target.build_configurations.each do |config|
        level = '-Osize'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = level
        puts "Set #{target.name} #{config.name} to Optimization Level #{level}"
      end
    end
  end
end
