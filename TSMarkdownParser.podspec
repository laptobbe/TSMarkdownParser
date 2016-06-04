Pod::Spec.new do |s|
  s.name         = "TSMarkdownParser"
  s.version      = "2.1.1"
  s.summary      = "A markdown to NSAttributedString parser for iOS and OSX"

  s.description  = <<-DESC
		TSMarkdownParser is a markdown to NSAttributedString parser for iOS, TVOS and OSX implemented using NSRegularExpressions. 
		It supports many of the standard tags layed out by John Gruber on his site [Daring Fireball](http://daringfireball.net/projects/markdown/syntax). 
		It is also very extendable via Regular Expressions making it easy to add your own custom tags or a totally different parsing syntax if you like.
                DESC

  s.homepage     = "https://github.com/laptobbe/TSMarkdownParser"
  s.license      = "MIT" 
  s.author             = { "Tobias Sundstrand" => "tobias.sundstrand@gmail.com" }
  s.social_media_url   = "http://twitter.com/laptobbe"
  s.ios.deployment_target = "6.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.7"
  s.source       = { :git => "https://github.com/laptobbe/TSMarkdownParser.git", :tag => s.version.to_s }
  s.source_files  = "TSMarkdownParser/**/*.{h,m}"
  s.requires_arc = true
  s.ios.framework = 'UIKit'
  s.tvos.framework = 'UIKit'
end
