//
//  TSMarkdownParser.m
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMarkdownParser.h"

@interface TSExpressionBlockPair : NSObject

@property (nonatomic, strong) NSRegularExpression *regularExpression;
@property (nonatomic, strong) TSMarkdownParserBlock block;

+ (TSExpressionBlockPair *)pairWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSMarkdownParserBlock)block;

@end

@implementation TSExpressionBlockPair

+ (TSExpressionBlockPair *)pairWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSMarkdownParserBlock)block {
    TSExpressionBlockPair *pair = [TSExpressionBlockPair new];
    pair.regularExpression = regularExpression;
    pair.block = block;
    return pair;
}

@end

@interface TSMarkdownParser ()

@property (nonatomic, strong) NSMutableArray *parsingPairs;

@end

@implementation TSMarkdownParser

- (instancetype)init {
    self = [super init];
    if(self) {
        _parsingPairs = [NSMutableArray array];
        _paragraphFont = [UIFont systemFontOfSize:12];
        _boldFont = [UIFont boldSystemFontOfSize:12];
        _italicFont = [UIFont italicSystemFontOfSize:12];
        _h1Font = [UIFont boldSystemFontOfSize:20];
        _h2Font = [UIFont boldSystemFontOfSize:19];
    }
    return self;
}

+ (TSMarkdownParser *)defaultParser {

    static TSMarkdownParser *defaultParser;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        defaultParser = [TSMarkdownParser new];
        [defaultParser addStrongParsing];
        [defaultParser addEmParsing];
        [defaultParser addListParsing];
        [defaultParser addLinkParsing];
        [defaultParser addH1Parsing];
        [defaultParser addH2Parsing];
    });
    return defaultParser;
}

static NSString *const TSMarkdownBoldRegex      = @"\\*{2}.*\\*{2}";
static NSString *const TSMarkdownEmRegex        = @"\\*.*\\*";
static NSString *const TSMarkdownListRegex      = @"^(\\*|\\+).+$";
static NSString *const TSMarkdownLinkRegex      = @"\\[.*\\]\\(.*\\)";
static NSString *const TSMarkdownHeaderRegex    = @"^#{%i}[^#]+$";

- (void)addStrongParsing {
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownBoldRegex options:NSRegularExpressionCaseInsensitive error:nil];
    UIFont *font = self.boldFont;
    [self addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 2)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-4, 2)];

    }];
}

- (void)addEmParsing {
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownEmRegex options:NSRegularExpressionCaseInsensitive error:nil];
    UIFont *font = self.italicFont;
    [self addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-2, 1)];

    }];
}

- (void)addListParsing {
    NSRegularExpression *listParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownListRegex options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:nil];
    [self addParsingRuleWithRegularExpression:listParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        [attributedString replaceCharactersInRange:NSMakeRange(match.range.location, 1) withString:@"•\\t"];
    }];

}

- (void)addLinkParsing {
    NSRegularExpression *linkParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownLinkRegex options:NSRegularExpressionCaseInsensitive error:nil];
    [self addParsingRuleWithRegularExpression:linkParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        NSUInteger linkStartInResult = [attributedString.string rangeOfString:@"(" options:0 range:match.range].location;
        NSRange linkRange = NSMakeRange(linkStartInResult, match.range.length+match.range.location-linkStartInResult-1);
        NSString *link = [attributedString.string substringWithRange:NSMakeRange(linkRange.location+1, linkRange.length-1)];

        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
        NSUInteger linkTextEndLocation = [attributedString.string rangeOfString:@"]" options:0 range:match.range].location;
        NSRange linkTextRange = NSMakeRange(match.range.location, linkTextEndLocation-match.range.location);

        [attributedString deleteCharactersInRange:NSMakeRange(linkRange.location-2, linkRange.length+2)];
        [attributedString addAttribute:NSLinkAttributeName
                                 value:link
                                 range:linkTextRange];
    }];
}

- (void)addH1Parsing {
   [self addHeaderParsingWithInt:1 font:self.h1Font];
}

- (void)addH2Parsing {
    [self addHeaderParsingWithInt:2 font:self.h2Font];
}

- (void)addHeaderParsingWithInt:(NSUInteger)header font:(UIFont *)font {
    NSString *headerRegex = [NSString stringWithFormat:TSMarkdownHeaderRegex, header];
    NSRegularExpression *headerExpression = [NSRegularExpression regularExpressionWithPattern:headerRegex options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines error:nil];
    [self addParsingRuleWithRegularExpression:headerExpression withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, header)];

    }];
}

- (void)addParsingRuleWithRegularExpression:(NSRegularExpression *)regularExpression withBlock:(TSMarkdownParserBlock)block {
    @synchronized (self) {
        [self.parsingPairs addObject:[TSExpressionBlockPair pairWithRegularExpression:regularExpression block:block]];
    }
}

- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:markdown];

    [mutableAttributedString addAttribute:NSFontAttributeName
                                    value:self.paragraphFont
                                    range:NSMakeRange(0, mutableAttributedString.length)];

    @synchronized (self) {
        for (TSExpressionBlockPair *expressionBlockPair in self.parsingPairs) {
            NSString *currentString = mutableAttributedString.string;
            NSArray *matches = [expressionBlockPair.regularExpression matchesInString:currentString options:0 range:NSMakeRange(0, currentString.length)];
            for(NSTextCheckingResult *match in matches) {
                expressionBlockPair.block(match, mutableAttributedString);
            }
        }
    }
    return mutableAttributedString;
}


@end
