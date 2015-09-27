TSMarkdownParser
================

[![Build Status](https://travis-ci.org/laptobbe/TSMarkdownParser.svg)](https://travis-ci.org/laptobbe/TSMarkdownParser)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/TSMarkdownParser.svg)](http://cocoadocs.org/docsets/TSMarkdownParser)
[![Platform](https://img.shields.io/cocoapods/p/TSMarkdownParser.svg)](http://cocoadocs.org/docsets/TSMarkdownParser)
[![Licence](https://img.shields.io/cocoapods/l/TSMarkdownParser.svg)](http://cocoadocs.org/docsets/TSMarkdownParser)


TSMarkdownParser is a markdown to NSAttributedString parser for iOS implemented using NSRegularExpressions. It supports many of the standard tags layed out by John Gruber on his site [Daring Fireball](http://daringfireball.net/projects/markdown/syntax). It is also very extendable via Regular Expressions making it easy to add your own custom tags or a totally different parsing syntax if you like.

#Supported tags
Below is a list of tags supported by the parser out of the box, to add your own tags see "Adding custom parsing"

````
Headings
# H1
## H2
### H3
#### H4
##### H5
###### H5

Lists
* item
+ item
- item

Images
![Alternative text](image.png)

URL
[Link text](https://www.example.net)

Emphasis
`code`
*Em*
_Em_
**Strong**
__Strong__


````

#Installation
TSMarkdownParser is distributed via CocoaPods

````
pod 'TSMarkdownParser'

````

alternativly you can clone the project and build the static library setup in the project, or drag the source files into you project.


#Usage
The standardParser class method provides a new instance of the parser configured to parse the tags listed above. You can also just create a new instance of TSMarkdownParser and add your own parsing. See "Adding custom parsing" for information on how to do this.

````
NSAttributedString *string = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:markdown];

````

#Customizing appearance
You can configure how the markdown is to be displayed by changing the different properties on a TSMarkdownParser instance. Alternatively you could implement the parsing yourself and add custom attributes to the attributed string. You can also alter the attributed string returned from the parser. 

#Adding custom parsing
Below is an example of how parsing of the bold tag is implemented. You can add your own parsing using the same addParsingRuleWithRegularExpression:withBlock: method. You can add a parsing rule to the standardParser or to your own instance of the parser. If you want to use any of the configuration properties within makesure you use a weak reference to the parser so you don't create a retain cycle.

````
NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"(\\*|_){2}.*(\\*|_){2}" options:NSRegularExpressionCaseInsensitive error:nil];
__weak TSMarkdownParser *weakSelf = self;
[self addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
	[attributedString addAttribute:NSFontAttributeName
                             value:weakSelf.strongFont
                             range:match.range];
    [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 2)];
    [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-4, 2)];
}];
````

#License
TSMarkdownParser is distributed under a MIT licence, see the licence file for more info.
