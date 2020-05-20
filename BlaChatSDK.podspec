
Pod::Spec.new do |spec|

  spec.name             = "BlaChatSDK"
  spec.module_name      = "BlaChatSDK"
  spec.version          = "0.0.1"
  spec.swift_version    = "4.2"
  spec.platform         = :ios, "10.0"
  spec.summary          = "BlaChatSDK for iOS client"

  spec.homepage         = "http://blameo.com/"

  spec.license          = { :type => 'MIT', :file => 'LICENSE' }

  spec.author           = { "Phung Van Thuong" => "pvthuong8896@gmail.com" }

  spec.source           = { :path => '.' }


  spec.source_files     = "Classes", "Classes/**/*.{h,m}"
  spec.exclude_files    = "Classes/Exclude"

  spec.dependency "Alamofire", "~> 4.7.3"
  spec.dependency "SQLite.swift", "~> 0.12.0"
  spec.dependency "SwiftCentrifuge", :path => "./"
  spec.dependency "SwiftyJSON"

end
