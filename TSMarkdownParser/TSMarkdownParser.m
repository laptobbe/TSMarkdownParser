//
//  TSMarkdownParser.m
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSMarkdownParser.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@implementation UIColor (ts)
/// code compatibility layer for macOS 10.7 and 10.8
+ (UIColor *)colorWithSRGBRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end
#else
#import <AppKit/AppKit.h>
typedef NSColor UIColor;
typedef NSImage UIImage;
typedef NSFont UIFont;
#endif
#ifndef NSFoundationVersionNumber10_10_Max
// macOS 10.11+ test compatible with Xcode 7
#define NSFoundationVersionNumber10_10_Max 1199
#endif

@implementation TSMarkdownParser

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;
    
#if TARGET_OS_TV
    NSUInteger defaultSize = 29;
#else
    NSUInteger defaultSize = 12;
#endif
    
    self.defaultAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:defaultSize] };
    
#if TARGET_OS_TV
    _headerAttributes = @[ @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:76] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:57] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:48] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:40] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:36] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:32] } ];
#else
    _headerAttributes = @[ @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:23] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:21] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:19] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:17] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:15] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } ];
#endif
    
#if TARGET_OS_IPHONE
    _emphasisAttributes = @{ NSFontAttributeName: [UIFont italicSystemFontOfSize:defaultSize] };
#else
    _emphasisAttributes = @{ NSFontAttributeName: [[NSFontManager sharedFontManager] convertFont:[UIFont systemFontOfSize:defaultSize] toHaveTrait:NSItalicFontMask] };
#endif
    
    _listAttributes = @[];
    // #69: avoiding crash if font is missing
    _quoteAttributes = @[@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:defaultSize] ?: [_emphasisAttributes objectForKey:NSFontAttributeName]}];
    
    _imageAttributes = @{};
    _linkAttributes = @{ NSForegroundColorAttributeName: [UIColor blueColor],
                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
    
    // Courier New and Courier are the only monospace fonts compatible with watchOS 2
    // #69: avoiding crash if font is missing
    _monospaceAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Courier New" size:defaultSize] ?: [UIFont fontWithName:@"Courier" size:defaultSize] ?: [UIFont systemFontOfSize:defaultSize],
                              NSForegroundColorAttributeName: [UIColor colorWithSRGBRed:0.95 green:0.54 blue:0.55 alpha:1] };
    _strongAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:defaultSize] };
    
    return self;
}

+ (instancetype)standardParser {
    TSMarkdownParser *defaultParser = [self new];
    
    __weak TSMarkdownParser *weakParser = defaultParser;
    
    /* escaping parsing */
    
    [defaultParser addCodeEscapingParsing];
    
    [defaultParser addEscapingParsing];
    
    /* block parsing */
    
    [defaultParser addHeaderParsingWithMaxLevel:0 leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, __unused NSUInteger level) {
        [attributedString deleteCharactersInRange:range];
    } textFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        [TSMarkdownParser addAttributes:weakParser.headerAttributes atIndex:level - 1 toString:attributedString range:range];
    }];
    
    [defaultParser addListParsingWithMaxLevel:0 leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        NSMutableString *listString = [NSMutableString string];
        while (--level)
            [listString appendString:@"\t"];
        [listString appendString:@"•\t"];
        [attributedString replaceCharactersInRange:range withString:listString];
    } textFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        [TSMarkdownParser addAttributes:weakParser.listAttributes atIndex:level - 1 toString:attributedString range:range];
    }];
    
    [defaultParser addQuoteParsingWithMaxLevel:0 leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        NSMutableString *quoteString = [NSMutableString string];
        while (level--)
            [quoteString appendString:@"\t"];
        [attributedString replaceCharactersInRange:range withString:quoteString];
    } textFormattingBlock:^(NSMutableAttributedString * attributedString, NSRange range, NSUInteger level) {
        [TSMarkdownParser addAttributes:weakParser.quoteAttributes atIndex:level - 1 toString:attributedString range:range];
    }];
    
    /* bracket parsing */
    
    [defaultParser addImageParsingWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * _Nullable link) {
#if !TARGET_OS_IPHONE
#if defined(__MAC_10_13)
        // macOS 10.11+ test compatible with Xcode 9+
        // NSTextAttachment works on macOS 10.10 but is tricky for image support
        if (@available(macOS 10.11, iOS 7.0, watchOS 2.0, tvOS 9.0, *)) {
#else
        // macOS 10.11+ test compatible with Xcode 8-
        // NSTextAttachment works on macOS 10.10 but is tricky for image support
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_10_Max) {
#endif
#else
        {
#endif
            UIImage *image = [UIImage imageNamed:link];
            if (image) {
                NSTextAttachment *imageAttachment = [NSTextAttachment new];
                imageAttachment.image = image;
                imageAttachment.bounds = CGRectMake(0, -5, image.size.width, image.size.height);
                NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:imageAttachment];
                [attributedString replaceCharactersInRange:range withAttributedString:imgStr];
                return;
            }
        }
        if (!weakParser.skipLinkAttribute) {
            NSURL *url = [NSURL URLWithString:link] ?: [NSURL URLWithString:
                                                        [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if (url.scheme) {
                [attributedString addAttribute:NSLinkAttributeName
                                         value:url
                                         range:range];
            }
        }
        [attributedString addAttributes:weakParser.imageAttributes range:range];
    }];
    
    [defaultParser addLinkParsingWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * _Nullable link) {
        if (!weakParser.skipLinkAttribute) {
            NSURL *url = [NSURL URLWithString:link] ?: [NSURL URLWithString:
                                                        [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if (url) {
                [attributedString addAttribute:NSLinkAttributeName
                                         value:url
                                         range:range];
            }
        }
        [attributedString addAttributes:weakParser.linkAttributes range:range];
    }];
    
    /* autodetection */
    
    [defaultParser addLinkDetectionWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * _Nullable link) {
        if (!weakParser.skipLinkAttribute) {
            __block BOOL alreadyLinked = NO;
            [attributedString enumerateAttribute:NSLinkAttributeName
                                         inRange:range
                                         options:0
                                      usingBlock:^(id _Nullable value, __unused NSRange range, BOOL * _Nonnull stop)
             {
                 if (value) {
                     // this range has a link that overlaps with the autodetect range, so skip
                     alreadyLinked = YES;
                     *stop = YES;
                 }
             }];
            if (alreadyLinked) {
                return;
            }
            NSURL *url = [NSURL URLWithString:link] ?: [NSURL URLWithString:
                                                        [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            [attributedString addAttribute:NSLinkAttributeName
                                     value:url
                                     range:range];
        }
        [attributedString addAttributes:weakParser.linkAttributes range:range];
    }];
    
    /* inline parsing */
    
    [defaultParser addStrongParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString addAttributes:weakParser.strongAttributes range:range];
    }];
    
    [defaultParser addEmphasisParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString addAttributes:weakParser.emphasisAttributes range:range];
    }];
    
    /* unescaping parsing */
    
    [defaultParser addCodeUnescapingParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString addAttributes:weakParser.monospaceAttributes range:range];
    }];
    
    [defaultParser addUnescapingParsing];
    
    return defaultParser;
}

+ (void)addAttributes:(NSArray<NSDictionary<NSString *, id> *> *)attributesArray atIndex:(NSUInteger)level toString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    if (!attributesArray.count)
        return;
    // 'objectAtIndexedSubscript:' is only available on macOS 10.8 or newer
    NSDictionary<NSString *, id> *attributes = level < attributesArray.count ? [attributesArray objectAtIndex:level] : attributesArray.lastObject;
    [attributedString addAttributes:attributes range:range];
}

// inline escaping regex
static NSString *const TSMarkdownCodeEscapingRegex  = @"(?<!\\\\)(?:\\\\\\\\)*+(`+)(.*?[^`].*?)(\\1)(?!`)";
static NSString *const TSMarkdownEscapingRegex      = @"\\\\.";
static NSString *const TSMarkdownUnescapingRegex    = @"\\\\[0-9a-z]{4}";

// lead regex
static NSString *const TSMarkdownHeaderRegex        = @"^(#{1,%@})\\s+(.+)$";
static NSString *const TSMarkdownShortHeaderRegex   = @"^(#{1,%@})\\s*([^#].*)$";
static NSString *const TSMarkdownListRegex          = @"^([\\*\\+\\-]{1,%@})\\s+(.+)$";
static NSString *const TSMarkdownShortListRegex     = @"^([\\*\\+\\-]{1,%@})\\s*([^\\*\\+\\-].*)$";
static NSString *const TSMarkdownQuoteRegex         = @"^(\\>{1,%@})\\s+(.+)$";
static NSString *const TSMarkdownShortQuoteRegex    = @"^(\\>{1,%@})\\s*([^\\>].*)$";

// inline bracket regex
static NSString *const TSMarkdownImageRegex         = @"\\!\\[[^\\[]*?\\]\\(\\S*\\)";
static NSString *const TSMarkdownLinkRegex          = @"\\[[^\\[]*?\\]\\([^\\)]*\\)";

// inline enclosed regex
static NSString *const TSMarkdownMonospaceRegex     = @"(`+)(\\s*.*?[^`]\\s*)(\\1)(?!`)";
static NSString *const TSMarkdownStrongRegex        = @"(\\*\\*|__)(.+?)(\\1)";
static NSString *const TSMarkdownEmRegex            = @"(\\*|_)(.+?)(\\1)";

#pragma mark escaping parsing

- (void)addCodeEscapingParsing {
    NSRegularExpression *parsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownCodeEscapingRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    [self addParsingRuleWithRegularExpression:parsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSRange range = [match rangeAtIndex:2];
        // escaping all characters
        NSString *matchString = [attributedString attributedSubstringFromRange:range].string;
        NSUInteger i = 0;
        NSMutableString *escapedString = [NSMutableString string];
        while (i < range.length)
            [escapedString appendFormat:@"%04x", [matchString characterAtIndex:i++]];
        [attributedString replaceCharactersInRange:range withString:escapedString];
    }];
}

- (void)addEscapingParsing {
    NSRegularExpression *escapingParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownEscapingRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    [self addParsingRuleWithRegularExpression:escapingParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSRange range = NSMakeRange(match.range.location + 1, 1);
        // escaping one character
        NSString *matchString = [attributedString attributedSubstringFromRange:range].string;
        NSString *escapedString = [NSString stringWithFormat:@"%04x", [matchString characterAtIndex:0]];
        [attributedString replaceCharactersInRange:range withString:escapedString];
    }];
}

#pragma mark block parsing

// pattern matching should be two parts: (leadingMD{1,%@})spaces(string)
- (void)addLeadParsingWithPattern:(NSString *)pattern maxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock formattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock {
    NSString *regex = [NSString stringWithFormat:pattern, maxLevel ? @(maxLevel) : @""];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionAnchorsMatchLines error:nil];
    [self addParsingRuleWithRegularExpression:expression block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger level = [match rangeAtIndex:1].length;
        // formatting string (may alter the length)
        if (formattingBlock)
            formattingBlock(attributedString, [match rangeAtIndex:2], level);
        // formatting leading markdown (may alter the length)
        leadFormattingBlock(attributedString, NSMakeRange([match rangeAtIndex:1].location, [match rangeAtIndex:2].location - [match rangeAtIndex:1].location), level);
    }];
}

- (void)addHeaderParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock {
    [self addLeadParsingWithPattern:TSMarkdownHeaderRegex maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock formattingBlock:formattingBlock];
}

- (void)addShortHeaderParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock {
    [self addLeadParsingWithPattern:TSMarkdownShortHeaderRegex maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock formattingBlock:formattingBlock];
}

- (void)addListParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock {
    [self addLeadParsingWithPattern:TSMarkdownListRegex maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock formattingBlock:formattingBlock];
}

- (void)addShortListParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock {
    [self addLeadParsingWithPattern:TSMarkdownShortListRegex maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock formattingBlock:formattingBlock];
}

- (void)addQuoteParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock {
    [self addLeadParsingWithPattern:TSMarkdownQuoteRegex maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock formattingBlock:formattingBlock];
}

- (void)addShortQuoteParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock {
    [self addLeadParsingWithPattern:TSMarkdownShortQuoteRegex maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock formattingBlock:formattingBlock];
}

#pragma mark bracket parsing

- (void)addImageParsingWithImageFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock alternativeTextFormattingBlock:(TSMarkdownParserFormattingBlock)alternativeFormattingBlock {
    NSRegularExpression *headerExpression = [NSRegularExpression regularExpressionWithPattern:TSMarkdownImageRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    [self addParsingRuleWithRegularExpression:headerExpression block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger imagePathStart = [attributedString.string rangeOfString:@"(" options:(NSStringCompareOptions)0 range:match.range].location;
        NSRange linkRange = NSMakeRange(imagePathStart, match.range.length + match.range.location - imagePathStart - 1);
        NSString *imagePath = [attributedString.string substringWithRange:NSMakeRange(linkRange.location + 1, linkRange.length - 1)];
#if !TARGET_OS_IPHONE
#if defined(__MAC_10_13)
        // macOS 10.11+ test compatible with Xcode 9+
        // NSTextAttachment works on macOS 10.10 but is tricky for image support
        if (@available(macOS 10.11, iOS 7.0, watchOS 2.0, tvOS 9.0, *)) {
#else
        // macOS 10.11+ test compatible with Xcode 8-
        // NSTextAttachment works on macOS 10.10 but is tricky for image support
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_10_Max) {
#endif
#else
        {
#endif
            UIImage *image = [UIImage imageNamed:imagePath];
            if (image) {
                NSTextAttachment *imageAttachment = [NSTextAttachment new];
                imageAttachment.image = image;
                imageAttachment.bounds = CGRectMake(0, -5, image.size.width, image.size.height);
                NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:imageAttachment];
                [attributedString replaceCharactersInRange:match.range withAttributedString:imgStr];
                if (formattingBlock) {
                    formattingBlock(attributedString, NSMakeRange(match.range.location, imgStr.length));
                }
                return;
            }
        }
        NSUInteger linkTextEndLocation = [attributedString.string rangeOfString:@"]" options:(NSStringCompareOptions)0 range:match.range].location;
        NSRange linkTextRange = NSMakeRange(match.range.location + 2, linkTextEndLocation - match.range.location - 2);
        NSString *alternativeText = [attributedString.string substringWithRange:linkTextRange];
        [attributedString replaceCharactersInRange:match.range withString:alternativeText];
        if (alternativeFormattingBlock) {
            alternativeFormattingBlock(attributedString, NSMakeRange(match.range.location, alternativeText.length));
        }
    }];
}

- (void)addImageParsingWithLinkFormattingBlock:(TSMarkdownParserLinkFormattingBlock)formattingBlock {
    NSRegularExpression *headerExpression = [NSRegularExpression regularExpressionWithPattern:TSMarkdownImageRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    [self addParsingRuleWithRegularExpression:headerExpression block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger imagePathStart = [attributedString.string rangeOfString:@"(" options:(NSStringCompareOptions)0 range:match.range].location;
        NSRange linkRange = NSMakeRange(imagePathStart, match.range.length + match.range.location - imagePathStart - 1);
        NSString *imagePath = [attributedString.string substringWithRange:NSMakeRange(linkRange.location + 1, linkRange.length - 1)];
        
        // deleting trailing markdown
        // needs to be called before formattingBlock to support modification of length
        [attributedString deleteCharactersInRange:NSMakeRange(linkRange.location - 1, linkRange.length + 2)];
        // deleting leading markdown
        // needs to be called before formattingBlock to provide a stable range
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 2)];
        // formatting link
        // needs to be called last (may alter the length and needs range to be stable)
        formattingBlock(attributedString, NSMakeRange(match.range.location, imagePathStart - match.range.location - 3), imagePath);
    }];
}

- (void)addLinkParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock __attribute__((deprecated("use addLinkParsingWithLinkFormattingBlock: instead"))) {
    NSRegularExpression *linkParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownLinkRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    [self addParsingRuleWithRegularExpression:linkParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger linkStartInResult = [attributedString.string rangeOfString:@"(" options:NSBackwardsSearch range:match.range].location;
        NSRange linkRange = NSMakeRange(linkStartInResult, match.range.length + match.range.location - linkStartInResult - 1);
        NSString *linkURLString = [attributedString.string substringWithRange:NSMakeRange(linkRange.location + 1, linkRange.length - 1)];
        NSURL *url = [NSURL URLWithString:linkURLString] ?: [NSURL URLWithString:
                                                             [linkURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSRange linkTextRange = NSMakeRange(match.range.location + 1, linkStartInResult - match.range.location - 2);
      
        // deleting trailing markdown
        [attributedString deleteCharactersInRange:NSMakeRange(linkRange.location - 1, linkRange.length + 2)];
        // formatting link (may alter the length)
        if (url) {
            [attributedString addAttribute:NSLinkAttributeName
                                     value:url
                                     range:linkTextRange];
        }
        formattingBlock(attributedString, linkTextRange);
        // deleting leading markdown
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
    }];
}

- (void)addLinkParsingWithLinkFormattingBlock:(TSMarkdownParserLinkFormattingBlock)formattingBlock {
    NSRegularExpression *linkParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownLinkRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    [self addParsingRuleWithRegularExpression:linkParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger linkStartInResult = [attributedString.string rangeOfString:@"(" options:NSBackwardsSearch range:match.range].location;
        NSRange linkRange = NSMakeRange(linkStartInResult, match.range.length + match.range.location - linkStartInResult - 1);
        NSString *linkURLString = [attributedString.string substringWithRange:NSMakeRange(linkRange.location + 1, linkRange.length - 1)];
        
        // deleting trailing markdown
        // needs to be called before formattingBlock to support modification of length
        [attributedString deleteCharactersInRange:NSMakeRange(linkRange.location - 1, linkRange.length + 2)];
        // deleting leading markdown
        // needs to be called before formattingBlock to provide a stable range
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
        // formatting link
        // needs to be called last (may alter the length and needs range to be stable)
        formattingBlock(attributedString, NSMakeRange(match.range.location, linkStartInResult - match.range.location - 2), linkURLString);
    }];
}

#pragma mark inline parsing

// pattern matching should be three parts: (leadingMD)(string)(trailingMD)
- (void)addEnclosedParsingWithPattern:(NSString *)pattern formattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock {
    NSRegularExpression *parsing = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionOptions)0 error:nil];
    [self addParsingRuleWithRegularExpression:parsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        // deleting trailing markdown
        [attributedString deleteCharactersInRange:[match rangeAtIndex:3]];
        // formatting string (may alter the length)
        formattingBlock(attributedString, [match rangeAtIndex:2]);
        // deleting leading markdown
        [attributedString deleteCharactersInRange:[match rangeAtIndex:1]];
    }];
}

- (void)addMonospacedParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithPattern:TSMarkdownMonospaceRegex formattingBlock:formattingBlock];
}

- (void)addStrongParsingWithFormattingBlock:(void(^)(NSMutableAttributedString *attributedString, NSRange range))formattingBlock {
    [self addEnclosedParsingWithPattern:TSMarkdownStrongRegex formattingBlock:formattingBlock];
}

- (void)addEmphasisParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithPattern:TSMarkdownEmRegex formattingBlock:formattingBlock];
}

#pragma mark link detection

- (void)addLinkDetectionWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock __attribute__((deprecated("use addLinkDetectionWithLinkFormattingBlock: instead"))) {
    NSDataDetector *linkDataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    [self addParsingRuleWithRegularExpression:linkDataDetector block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSString *linkURLString = [attributedString.string substringWithRange:match.range];
        [attributedString addAttribute:NSLinkAttributeName
                                        value:[NSURL URLWithString:linkURLString]
                                        range:match.range];
        formattingBlock(attributedString, match.range);
    }];
}

- (void)addLinkDetectionWithLinkFormattingBlock:(TSMarkdownParserLinkFormattingBlock)formattingBlock {
    NSDataDetector *linkDataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    [self addParsingRuleWithRegularExpression:linkDataDetector block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSString *linkURLString = [attributedString.string substringWithRange:match.range];
        formattingBlock(attributedString, match.range, linkURLString);
    }];
}

#pragma mark unescaping parsing

+ (NSString *)stringWithHexaString:(NSString *)hexaString atIndex:(NSUInteger)i {
    char byte_chars[5] = {'\0','\0','\0','\0','\0'};
    byte_chars[0] = [hexaString characterAtIndex:i];
    byte_chars[1] = [hexaString characterAtIndex:i + 1];
    byte_chars[2] = [hexaString characterAtIndex:i + 2];
    byte_chars[3] = [hexaString characterAtIndex:i + 3];
    unichar whole_char = strtol(byte_chars, NULL, 16);
    return [NSString stringWithCharacters:&whole_char length:1];
}

- (void)addCodeUnescapingParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithPattern:TSMarkdownCodeEscapingRegex formattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        NSUInteger i = 0;
        NSString *matchString = [attributedString attributedSubstringFromRange:range].string;
        NSMutableString *unescapedString = [NSMutableString string];
        while (i < range.length) {
            [unescapedString appendString:[TSMarkdownParser stringWithHexaString:matchString atIndex:i]];
            i += 4;
        }
        [attributedString replaceCharactersInRange:range withString:unescapedString];
        
        // formatting string (may alter the length)
        formattingBlock(attributedString, NSMakeRange(range.location, unescapedString.length));
    }];
}

- (void)addUnescapingParsing {
    NSRegularExpression *unescapingParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownUnescapingRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    [self addParsingRuleWithRegularExpression:unescapingParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSRange range = NSMakeRange(match.range.location + 1, 4);
        NSString *matchString = [attributedString attributedSubstringFromRange:range].string;
        NSString *unescapedString = [TSMarkdownParser stringWithHexaString:matchString atIndex:0];
        [attributedString replaceCharactersInRange:match.range withString:unescapedString];
    }];
}

@end
