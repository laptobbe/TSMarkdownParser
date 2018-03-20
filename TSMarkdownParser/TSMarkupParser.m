//
//  TSMarkupParser.m
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSMarkupParser.h"
#import "TSHelper.h"


@implementation TSMarkupParser

// inline escaping regex
static NSString *const TSMarkupNonEscapedRegex    = @"(?<!\\\\)(?:\\\\\\\\)*+";
static NSString *const TSMarkupEscapingRegex      = @"\\\\.";
static NSString *const TSMarkupUnescapingRegex    = @"\\\\[0-9a-z]{4}";

// lead start regex (with a max level)
// TODO: compare perf with @"^([%@]{1,%@})"
static NSString *const TSMarkupStartLineLevelRegex    = @"^((?:%@){1,%@})";

// lead end regex
// TODO: compare perf with @"%@\\s*(.+)$"
// TODO: compare perf with @"\\s+(.+)$" when separator is space
static NSString *const TSMarkupEndLineMandatorySeparatorRegex = @"%@\\s*(.+?)$";
// TODO: compare perf with @"\\s*([^%@].*)$"
static NSString *const TSMarkupEndLineOptionalSpaceRegex      = @"\\s*([^%@].*?)$";

// subline regex (with a min level)
static NSString *const TSMarkupSubLineRegex       = @"^(.*)\n((?:%@){%@,})$";

// inline bracket regex
// TODO: compare perf between \\(.*?\\) and \\([^\\)]*\\)
/// Image could accept nested brackets inside, but it's not possible: https://stackoverflow.com/q/33096411/1033581
static NSString *const TSMarkupImageRegex         = @"\\!\\[.*?\\]\\(.*?\\)";
/// Link must accept balanced brackets inside for images.
/// Link could accept nested brackets inside, but it's not possible: https://stackoverflow.com/q/33096411/1033581
static NSString *const TSMarkupLinkRegex          = @"\\[(?:[^\\[\\]]|\\[.*?\\])*?\\]\\([^\\)]*\\)";

// inline enclosed regex
static NSString *const TSMarkupEnclosedRegex          = @"(%@)(.+?)(\\1)";
static NSString *const TSMarkupVariableEnclosedRegex  = @"(%@+)(.*?[^%@].*?)(\\1)(?!%@)";
static inline NSString *TSMarkupVariableEnclosedRegexWithSymbol(NSString *symbol) {
    return [NSString stringWithFormat:TSMarkupVariableEnclosedRegex, symbol, symbol, symbol];
}

#pragma mark escaping parsing

- (void)addCodeEscapingParsing {
    NSRegularExpression *parsing = [NSRegularExpression regularExpressionWithPattern:[TSMarkupNonEscapedRegex stringByAppendingString:TSMarkupVariableEnclosedRegexWithSymbol(@"`")] options:NSRegularExpressionDotMatchesLineSeparators error:nil];
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
    NSRegularExpression *escapingParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkupEscapingRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    [self addParsingRuleWithRegularExpression:escapingParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSRange range = NSMakeRange(match.range.location + 1, 1);
        // escaping one character
        NSString *matchString = [attributedString attributedSubstringFromRange:range].string;
        NSString *escapedString = [NSString stringWithFormat:@"%04x", [matchString characterAtIndex:0]];
        [attributedString replaceCharactersInRange:range withString:escapedString];
    }];
}

#pragma mark block parsing

// pattern matching should be two parts: (leadingMarkup)spaces(string)
- (void)addLeadParsingWithPattern:(NSString *)markupPattern
                  formattingBlock:(TSFullFormattingBlock)leadFormattingBlock {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:markupPattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    [self addParsingRuleWithRegularExpression:expression block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSRange textRange = [match rangeAtIndex:2];
        NSRange leadingRange = [match rangeAtIndex:1];
        NSRange fullRange = match.range;
        //NSRange separatorRange = NSMakeRange(leadingRange.location + leadingRange.length, textRange.location - leadingRange.location - leadingRange.length);
        // formatting string (may alter the length)
        leadFormattingBlock(attributedString, textRange, leadingRange, fullRange);
    }];
}

- (void)addStartLineParsingWithSymbols:(NSString *)symbolPattern
                              maxLevel:(unsigned int)maxLevel
                            separators:(NSString *)separatorPattern
                       formattingBlock:(TSFullFormattingBlock)leadFormattingBlock {
    NSObject *maxLevelPattern = maxLevel ? @(maxLevel) : @"";
    NSString *startPattern = [NSString stringWithFormat:TSMarkupStartLineLevelRegex, symbolPattern, maxLevelPattern];
    NSString *markupPattern = separatorPattern.length
    ? [startPattern stringByAppendingFormat:TSMarkupEndLineMandatorySeparatorRegex, separatorPattern]
    : [startPattern stringByAppendingFormat:TSMarkupEndLineOptionalSpaceRegex, symbolPattern];
    [self addLeadParsingWithPattern:markupPattern formattingBlock:leadFormattingBlock];
}

// pattern matching should be two parts: (string)separators(trailingMarkup)
- (void)addTrailParsingWithPattern:(NSString *)markupPattern
                   formattingBlock:(TSFullFormattingBlock)trailFormattingBlock {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:markupPattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    [self addParsingRuleWithRegularExpression:expression block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSRange textRange = [match rangeAtIndex:1];
        NSRange trailingRange = [match rangeAtIndex:2];
        NSRange fullRange = match.range;
        // formatting string (may alter the length)
        trailFormattingBlock(attributedString, textRange, trailingRange, fullRange);
    }];
}

- (void)addSubLineParsingWithSymbols:(NSString *)symbolPattern
                            minLevel:(unsigned int)minLevel
                     formattingBlock:(TSFullFormattingBlock)formattingBlock {
    NSObject *minLevelPattern = minLevel ? @(minLevel) : @"";
    NSString *markupPattern = [NSString stringWithFormat:TSMarkupSubLineRegex, symbolPattern, minLevelPattern];
    [self addTrailParsingWithPattern:markupPattern formattingBlock:formattingBlock];
}

#pragma mark bracket parsing

- (void)addImageParsingWithLinkFormattingBlock:(TSMarkupStringFormattingBlock)formattingBlock {
    NSRegularExpression *headerExpression = [NSRegularExpression regularExpressionWithPattern:TSMarkupImageRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    [self addParsingRuleWithRegularExpression:headerExpression block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger imagePathStart = [attributedString.string rangeOfString:@"(" options:(NSStringCompareOptions)0 range:match.range].location;
        NSRange linkRange = NSMakeRange(imagePathStart, match.range.length + match.range.location - imagePathStart - 1);
        NSString *imagePath = [attributedString.string substringWithRange:NSMakeRange(linkRange.location + 1, linkRange.length - 1)];
        
        // deleting trailing markup
        // needs to be called before formattingBlock to support modification of length
        [attributedString deleteCharactersInRange:NSMakeRange(linkRange.location - 1, linkRange.length + 2)];
        // deleting leading markup
        // needs to be called before formattingBlock to provide a stable range
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 2)];
        // formatting link
        // needs to be called last (may alter the length and needs range to be stable)
        formattingBlock(attributedString, NSMakeRange(match.range.location, imagePathStart - match.range.location - 3), imagePath);
    }];
}

- (void)addLinkParsingWithLinkFormattingBlock:(TSMarkupStringFormattingBlock)formattingBlock {
    NSRegularExpression *linkParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkupLinkRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    [self addParsingRuleWithRegularExpression:linkParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger linkStartInResult = [attributedString.string rangeOfString:@"(" options:NSBackwardsSearch range:match.range].location;
        NSRange linkRange = NSMakeRange(linkStartInResult, match.range.length + match.range.location - linkStartInResult - 1);
        NSString *linkURLString = [attributedString.string substringWithRange:NSMakeRange(linkRange.location + 1, linkRange.length - 1)];
        
        // deleting trailing markup
        // needs to be called before formattingBlock to support modification of length
        [attributedString deleteCharactersInRange:NSMakeRange(linkRange.location - 1, linkRange.length + 2)];
        // deleting leading markup
        // needs to be called before formattingBlock to provide a stable range
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
        // formatting link
        // needs to be called last (may alter the length and needs range to be stable)
        formattingBlock(attributedString, NSMakeRange(match.range.location, linkStartInResult - match.range.location - 2), linkURLString);
    }];
}

#pragma mark inline parsing

- (void)addEnclosedParsingWithSymbol:(NSString *)symbol formattingBlock:(TSSimpleFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithPattern:[NSString stringWithFormat:TSMarkupEnclosedRegex, symbol] formattingBlock:formattingBlock];
}

- (void)addVariableEnclosedParsingWithSymbol:(NSString *)symbol formattingBlock:(TSSimpleFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithPattern:[NSString stringWithFormat:TSMarkupVariableEnclosedRegex, symbol, symbol, symbol] formattingBlock:formattingBlock];
}

// pattern matching should be three parts: (leadingMarkup)(string)(trailingMarkup)
- (void)addEnclosedParsingWithPattern:(NSString *)pattern formattingBlock:(TSSimpleFormattingBlock)formattingBlock {
    NSRegularExpression *parsing = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionOptions)0 error:nil];
    [self addParsingRuleWithRegularExpression:parsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        // deleting trailing markup
        [attributedString deleteCharactersInRange:[match rangeAtIndex:3]];
        // formatting string (may alter the length)
        formattingBlock(attributedString, [match rangeAtIndex:2]);
        // deleting leading markup
        [attributedString deleteCharactersInRange:[match rangeAtIndex:1]];
    }];
}

#pragma mark link detection

- (void)addLinkDetectionWithLinkFormattingBlock:(TSMarkupStringFormattingBlock)formattingBlock {
    NSDataDetector *linkDataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    [self addParsingRuleWithRegularExpression:linkDataDetector block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSString *linkURLString = [attributedString.string substringWithRange:match.range];
        formattingBlock(attributedString, match.range, linkURLString);
    }];
}

#pragma mark unescaping parsing

/// it is assumed the hexaString is valid
static inline NSString *TSMarkupStringWithHexaStringAndIndex(NSString *hexaString, NSUInteger i) {
    char byte_chars[5] = {'\0','\0','\0','\0','\0'};
    byte_chars[0] = [hexaString characterAtIndex:i];
    byte_chars[1] = [hexaString characterAtIndex:i + 1];
    byte_chars[2] = [hexaString characterAtIndex:i + 2];
    byte_chars[3] = [hexaString characterAtIndex:i + 3];
    unichar whole_char = strtol(byte_chars, NULL, 16);
    return [NSString stringWithCharacters:&whole_char length:1];
}

- (void)addCodeUnescapingParsingWithFormattingBlock:(TSSimpleFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithPattern:[TSMarkupNonEscapedRegex stringByAppendingString:TSMarkupVariableEnclosedRegexWithSymbol(@"`")] formattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        NSUInteger i = 0;
        NSString *matchString = [attributedString attributedSubstringFromRange:range].string;
        NSMutableString *unescapedString = [NSMutableString string];
        while (i < range.length) {
            [unescapedString appendString:TSMarkupStringWithHexaStringAndIndex(matchString, i)];
            i += 4;
        }
        [attributedString replaceCharactersInRange:range withString:unescapedString];
        
        // formatting string (may alter the length)
        formattingBlock(attributedString, NSMakeRange(range.location, unescapedString.length));
    }];
}

- (void)addUnescapingParsing {
    NSRegularExpression *unescapingParsing = [NSRegularExpression regularExpressionWithPattern:TSMarkupUnescapingRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    [self addParsingRuleWithRegularExpression:unescapingParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSRange range = NSMakeRange(match.range.location + 1, 4);
        NSString *matchString = [attributedString attributedSubstringFromRange:range].string;
        NSString *unescapedString = TSMarkupStringWithHexaStringAndIndex(matchString, 0);
        [attributedString replaceCharactersInRange:match.range withString:unescapedString];
    }];
}

#if !TARGET_OS_WATCH

#pragma mark - imageAttachment for resource bundle

- (nullable UIImage *)imageForResource:(NSString *)name NS_AVAILABLE(10_7, 7_0) {
#if !TARGET_OS_IPHONE
    {
#elif __clang_major__ >= 9
    if (@available(macOS 10.10, iOS 8.0, tvOS 9.0, *)) {
#else
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
#endif
        return [TSHelper imageForResource:name bundle:self.resourceBundle];
    }
    // iOS 7
    return [TSHelper imageForResource:name bundle:nil];
}
#endif// !TARGET_OS_WATCH

@end
