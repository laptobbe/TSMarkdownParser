//
//  TSBaseParser.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 24/01/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSBaseParser.h"
#import <UIKit/UIKit.h>

@interface TSExpressionBlockPair : NSObject

@property (nonatomic, strong) NSRegularExpression *regularExpression;
@property (nonatomic, strong) TSMarkdownParserMatchBlock block;

+ (TSExpressionBlockPair *)pairWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSMarkdownParserMatchBlock)block;

@end

@implementation TSExpressionBlockPair

+ (TSExpressionBlockPair *)pairWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSMarkdownParserMatchBlock)block {
    TSExpressionBlockPair *pair = [TSExpressionBlockPair new];
    pair.regularExpression = regularExpression;
    pair.block = block;
    return pair;
}

@end

@interface TSBaseParser ()

@property (nonatomic, strong) NSMutableArray *parsingPairs;

@end

@implementation TSBaseParser

- (instancetype)init {
    self = [super init];
    if(self) {
        _parsingPairs = [NSMutableArray array];
    }
    return self;
}

static NSString *const TSMarkdownEscapingRegex  = @"\\\\.";
static NSString *const TSMarkdownUnescapingRegex    = @"\\\\[0-9a-z]{4}";

#pragma mark -

- (void)addParsingRuleWithRegularExpression:(NSRegularExpression *)regularExpression withBlock:(TSMarkdownParserMatchBlock)block {
    @synchronized (self) {
        [self.parsingPairs addObject:[TSExpressionBlockPair pairWithRegularExpression:regularExpression block:block]];
    }
}

- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown {
    return [self attributedStringFromMarkdown:markdown attributes:self.defaultAttributes];
}

- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    NSAttributedString *attributedString;
    if (! attributes) {
        attributedString = [[NSAttributedString alloc] initWithString:markdown];
    } else {
        attributedString = [[NSAttributedString alloc] initWithString:markdown attributes:attributes];
    }
    
    return [self attributedStringFromAttributedMarkdownString:attributedString];
}

- (NSAttributedString *)attributedStringFromAttributedMarkdownString:(NSAttributedString *)attributedString {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    @synchronized (self) {
        if (self.escapingSupport) {
            NSRegularExpression *escapingParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownEscapingRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
            NSArray *matches = [escapingParsing matchesInString:mutableAttributedString.string options:0 range:NSMakeRange(0, mutableAttributedString.length)];
            [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
                NSRange range = NSMakeRange(match.range.location+1, 1);
                NSString *matchString = [mutableAttributedString attributedSubstringFromRange:range].string;
                NSString *escapedString = [NSString stringWithFormat:@"%04x", [matchString characterAtIndex:0]];
                [mutableAttributedString replaceCharactersInRange:range withString:escapedString];
            }];
        }
        
        for (TSExpressionBlockPair *expressionBlockPair in self.parsingPairs) {
            NSTextCheckingResult *match;
            while((match = [expressionBlockPair.regularExpression firstMatchInString:mutableAttributedString.string options:0 range:NSMakeRange(0, mutableAttributedString.string.length)])){
                expressionBlockPair.block(match, mutableAttributedString);
            }
        }
        
        if (self.escapingSupport) {
            NSRegularExpression *unescapingParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkdownUnescapingRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
            NSArray *matches = [unescapingParsing matchesInString:mutableAttributedString.string options:0 range:NSMakeRange(0, mutableAttributedString.length)];
            [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
                NSRange range = NSMakeRange(match.range.location+1, 4);
                NSString *matchString = [mutableAttributedString attributedSubstringFromRange:range].string;
                char byte_chars[5] = {'\0','\0','\0','\0','\0'};
                byte_chars[0] = [matchString characterAtIndex:0];
                byte_chars[1] = [matchString characterAtIndex:1];
                byte_chars[2] = [matchString characterAtIndex:2];
                byte_chars[3] = [matchString characterAtIndex:3];
                unichar whole_char = strtol(byte_chars, NULL, 16);
                NSString *unescapedString = [NSString stringWithCharacters:&whole_char length:1];
                [mutableAttributedString replaceCharactersInRange:match.range withString:unescapedString];
            }];
        }
        
        if (self.linkDetection) {
            NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
            NSArray *results = [dataDetector matchesInString:mutableAttributedString.string options:0 range:NSMakeRange(0, mutableAttributedString.length)];
            for (NSTextCheckingResult *result in results) {
                NSString *linkURLString = [mutableAttributedString.string substringWithRange:result.range];
                [mutableAttributedString addAttribute:NSLinkAttributeName
                                                value:[NSURL URLWithString:linkURLString]
                                                range:result.range];
            }
            mutableAttributedString = mutableAttributedString;
        }
    }
    return mutableAttributedString;
}

@end
