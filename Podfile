# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/vibes/pod_specs.git'

target 'ios-sdk-example-app' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # >> I use RxSwift for this example app but you're free not to.
  pod 'RxSwift', '~> 3.0'
  pod 'RxCocoa'
  # <<

  pod 'VibesPush', '2.0.0.sw4'
  
  target "unit-tests" do
    inherit! :search_paths
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
  end
end
