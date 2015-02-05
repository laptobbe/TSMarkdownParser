Pod::Spec.new do |s|
  s.name         = "TSMarkdownParser"
  s.version      = "1.0.12"
  s.summary      = "A markdown to NSAttributedString parser for iOS"

  s.description  = <<-DESC
		TSMarkdownParser is a markdown to NSAttributedString parser for iOS implemented using NSRegularExpressions. 
		It supports many of the standard tags layed out by John Gruber on his site [Daring Fireball](http://daringfireball.net/projects/markdown/syntax). 
		It is also very extendable via Regular Expressions making it easy to add your own custom tags or a totally different parsing syntax if you like.
                DESC

  s.homepage     = "https://github.com/laptobbe/TSMarkdownParser"
  s.license      = "MIT" 
  s.author             = { "Tobias Sundstrand" => "tobias.sundstrand@gmail.com" }
  s.social_media_url   = "http://twitter.com/laptobbe"
  s.platform     = :ios, 6.0
  s.source       = { :git => "https://github.com/laptobbe/TSMarkdownParser.git", :tag => s.version.to_s }
  s.source_files  = "TSMarkdownParser/**/*.{h,m}"
  s.requires_arc = true
end
