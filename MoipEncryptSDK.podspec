Pod::Spec.new do |s|

  s.name         = "MoipEncryptSDK"
  s.version      = "1.0.0"
  s.summary      = "Cliente iOS para integração com as APIs v2 Moip, possibilita a criptografia de dados sensíveis de cartão de crédito."
  s.description  = <<-DESC
                   Cliente iOS para integração com as APIs v2 Moip, possibilita a criptografia de
                   dados sensíveis de cartão de crédito.
                   DESC
  s.homepage     = "https://github.com/moip/ios-sdk"
  s.license      = "MIT"
  s.author             = { "Fernando Nazario" => "fnazarios@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://github.com/moip/ios-sdk.git", :tag => s.version }
  s.source_files  = "MoipSDK", "MoipSDK/**/*.{h,m}"
  s.public_header_files = "MoipSDK/**/*.h"
  s.requires_arc = true
end
