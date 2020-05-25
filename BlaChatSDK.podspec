
Pod::Spec.new do |spec|

  spec.name             = "BlaChatSDK"
  spec.module_name      = "BlaChatSDK"
  spec.version          = "0.0.3"
  spec.swift_version    = "4.2"
  spec.platform         = :ios, "10.0"
  spec.summary          = "BlaChatSDK for iOS client"

  spec.homepage         = "http://blameo.com/"

  spec.license          = { :type => 'MIT', :file => 'LICENSE' }

  spec.author           = { "Blameo VietNam" => "thuongpv@blameo.com" }

  spec.source           = { :git => 'https://github.com/nhoxkem96/BlaChatSDK.git', :tag => spec.version }


  spec.source_files     = 'BlaChatSDK/*.swift'
  spec.exclude_files    = "Classes/Exclude"

  spec.dependency "Alamofire", "~> 4.7.3"
  spec.dependency "SQLite.swift", "~> 0.12.0"
  spec.dependency "SwiftyJSON"
  spec.dependency 'SwiftProtobuf'
  spec.dependency 'Starscream', '~> 3'

end
