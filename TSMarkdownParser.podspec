Pod::Spec.new do |s|
  s.name         = 'TSMarkdownParser'
  s.version      = '3.0.0-beta'
  s.summary      = 'A markdown to NSAttributedString parser for iOS, watchOS, tvOS and OSX'
  s.description  = <<-DESC
		TSMarkdownParser is a markdown to NSAttributedString parser for iOS, watchOS, tvOS and OSX implemented using NSRegularExpressions.
		It supports many of the standard tags layed out by John Gruber on his site [Daring Fireball](http://daringfireball.net/projects/markdown/syntax). 
		It is also very extendable via Regular Expressions making it easy to add your own custom tags or a totally different parsing syntax if you like.
                DESC

  s.homepage     = 'https://github.com/laptobbe/TSMarkdownParser'
  s.license      = 'MIT'
  s.authors      = { 'Tobias Sundstrand' => 'tobias.sundstrand@gmail.com',
                     'Antoine Cœur' => 'coeur@gmx.fr' }
  s.social_media_url   = 'http://twitter.com/laptobbe'
  s.source       = { :git => 'https://github.com/laptobbe/TSMarkdownParser.git', :tag => s.version.to_s }

#s.prefix_header_file = 'TSMarkdownParser/TSMarkdownParser-prefix.pch'
  s.source_files = 'TSMarkdownParser/**/*.{h,m}'
  s.ios.deployment_target = '6.0'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.7'
  s.ios.framework = 'UIKit', 'CoreText'
  s.watchos.framework = 'UIKit'
  s.tvos.framework = 'UIKit'
  s.osx.framework = 'AppKit'
end
