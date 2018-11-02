platform :ios, '10.3'
project 'ProjectTemplate', 'AdHoc' => :release,'AppStore' => :release, 'Development' => :debug

inhibit_all_warnings!
use_frameworks!

target 'ProjectTemplate' do
    pod 'SwiftLint', '~> 0.27'
    
    pod 'ACKLocalization', '~> 0.2'
    pod 'SwiftGen', '~> 6.0'
    pod 'Smartling.i18n', '~> 1.0'

    pod 'Crashlytics', '~> 3.10'
    pod 'Firebase', '~> 5.6', :subspecs => ["RemoteConfig", "Performance", "Analytics", "Messaging"]
    
    target 'UnitTests' do
        inherit! :complete
    end
end
