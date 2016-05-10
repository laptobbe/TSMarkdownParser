//
//  TSMarkdownParser.m
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSMarkdownParser.h"


@implementation TSMarkdownParser

// inline escaping regex
static NSString *const TSMarkdownNonEscapedRegex    = @"(?<!\\\\)(?:\\\\\\\\)*+";
static NSString *const TSMarkdownEscapingRegex      = @"\\\\.";
static NSString *const TSMarkdownUnescapingRegex    = @"\\\\[0-9a-z]{4}";

// lead regex (with a max level)
// TODO: compare perf with @"^([%@]{1,%@})\\s+(.+)$"
static NSString *const TSMarkdownLeadRegex          = @"^((?:%@){1,%@})\\s+(.+?)$";
// TODO: compare perf with @"^([%@]{1,%@})\\s*([^%@].*)$"
static NSString *const TSMarkdownShortLeadRegex     = @"^([%@]{1,%@})\\s*([^%@].*?)$";

// subtext regex (with a min level)
static NSString *const TSMarkdownSubtextRegex       = @"^(.*)$(%@{%@,})(?!%@)";

// inline bracket regex
static NSString *const TSMarkdownImageRegex         = @"\\!\\[[^\\[]*?\\]\\(\\S*\\)";
static NSString *const TSMarkdownLinkRegex          = @"\\[[^\\[]*?\\]\\([^\\)]*\\)";

// inline enclosed regex
static NSString *const TSMarkdownEnclosedRegex      = @"(%@)(.+?)(\\1)";
static NSString *const TSMarkdownVariableEnclosedRegex  = @"(%@+)(.*?[^%@].*?)(\\1)(?!%@)";
static inline NSString *TSMarkdownVariableEnclosedRegexWithSymbol(NSString *symbol) {
    return [NSString stringWithFormat:TSMarkdownVariableEnclosedRegex, symbol, symbol, symbol];
}

#pragma mark escaping parsing

- (void)addCodeEscapingParsing {
    NSRegularExpression *parsing = [NSRegularExpression regularExpressionWithPattern:[TSMarkdownNonEscapedRegex stringByAppendingString:TSMarkdownVariableEnclosedRegexWithSymbol(@"`")] options:(NSRegularExpressionOptions)0 error:nil];
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

- (void)addLeadParsingWithSymbol:(NSString *)symbol maxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    [self addLeadParsingWithPattern:[NSString stringWithFormat:TSMarkdownLeadRegex, symbol, maxLevel ? @(maxLevel) : @""] leadFormattingBlock:leadFormattingBlock textFormattingBlock:textFormattingBlock];
}

- (void)addShortLeadParsingWithSymbol:(NSString *)symbol maxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    [self addLeadParsingWithPattern:[NSString stringWithFormat:TSMarkdownShortLeadRegex, symbol, maxLevel ? @(maxLevel) : @"", symbol] leadFormattingBlock:leadFormattingBlock textFormattingBlock:textFormattingBlock];
}

// pattern matching should be two parts: (leadingMD)spaces(string)
- (void)addLeadParsingWithPattern:(NSString *)pattern leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    [self addParsingRuleWithRegularExpression:expression block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger level = [match rangeAtIndex:1].length;
        // formatting string (may alter the length)
        if (textFormattingBlock)
            textFormattingBlock(attributedString, [match rangeAtIndex:2], level);
        // formatting leading markdown (may alter the length)
        NSRange leadingRange = NSMakeRange([match rangeAtIndex:1].location, [match rangeAtIndex:2].location - [match rangeAtIndex:1].location);
        if (leadFormattingBlock)
            leadFormattingBlock(attributedString, leadingRange, level);
        else
            // deleting leading markdown
            [attributedString deleteCharactersInRange:leadingRange];
    }];
}

- (void)addHeaderParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock {
    [self addLeadParsingWithSymbol:@"#" maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock textFormattingBlock:formattingBlock];
}

- (void)addShortHeaderParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    [self addShortLeadParsingWithSymbol:@"#" maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock textFormattingBlock:textFormattingBlock];
}

- (void)addListParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    [self addLeadParsingWithSymbol:@"\\*|\\+|\\-" maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock textFormattingBlock:textFormattingBlock];
}

- (void)addShortListParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    [self addShortLeadParsingWithSymbol:@"\\*\\+\\-" maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock textFormattingBlock:textFormattingBlock];
}

- (void)addQuoteParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    [self addLeadParsingWithSymbol:@"\\>" maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock textFormattingBlock:textFormattingBlock];
}

- (void)addShortQuoteParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    [self addShortLeadParsingWithSymbol:@"\\>" maxLevel:maxLevel leadFormattingBlock:leadFormattingBlock textFormattingBlock:textFormattingBlock];
}

/*
- (void)addSubtextParsingWithSymbol:(NSString *)symbol minLevel:(unsigned int)minLevel subtextFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)subtextFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    [self addTrailingParsingWithPattern:[NSString stringWithFormat:TSMarkdownSubtextRegex, symbol, minLevel ? @(minLevel) : @"", symbol] trailingFormattingBlock:subtextFormattingBlock textFormattingBlock:textFormattingBlock];
}

// pattern matching should be two parts: (string)spaces(trailingMD)
- (void)addTrailingParsingWithPattern:(NSString *)pattern trailingFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)trailingFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)textFormattingBlock {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    [self addParsingRuleWithRegularExpression:expression block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {
        NSUInteger level = [match rangeAtIndex:1].length;
        // formatting trailing markdown (may alter the length)
        NSRange trailingRange = NSMakeRange([match rangeAtIndex:1].location, [match rangeAtIndex:2].location - [match rangeAtIndex:1].location);
        if (trailingFormattingBlock)
            trailingFormattingBlock(attributedString, trailingRange, level);
        else
            // deleting leading markdown
            [attributedString deleteCharactersInRange:trailingRange];
        // formatting string (may alter the length)
        if (textFormattingBlock)
            textFormattingBlock(attributedString, [match rangeAtIndex:2], level);
    }];
}
*/

#pragma mark bracket parsing

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

- (void)addEnclosedParsingWithSymbol:(NSString *)symbol formattingBlock:(void(^)(NSMutableAttributedString *attributedString, NSRange range))formattingBlock {
    [self addEnclosedParsingWithPattern:[NSString stringWithFormat:TSMarkdownEnclosedRegex, symbol] formattingBlock:formattingBlock];
}

- (void)addVariableEnclosedParsingWithSymbol:(NSString *)symbol formattingBlock:(void(^)(NSMutableAttributedString *attributedString, NSRange range))formattingBlock {
    [self addEnclosedParsingWithPattern:[NSString stringWithFormat:TSMarkdownVariableEnclosedRegex, symbol, symbol, symbol] formattingBlock:formattingBlock];
}

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
    [self addVariableEnclosedParsingWithSymbol:@"`" formattingBlock:formattingBlock];
}

- (void)addStrongParsingWithFormattingBlock:(void(^)(NSMutableAttributedString *attributedString, NSRange range))formattingBlock {
    [self addEnclosedParsingWithSymbol:@"\\*\\*|__" formattingBlock:formattingBlock];
}

- (void)addEmphasisParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithSymbol:@"\\*|_" formattingBlock:formattingBlock];
}

#pragma mark link detection

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
    [self addEnclosedParsingWithPattern:[TSMarkdownNonEscapedRegex stringByAppendingString:TSMarkdownVariableEnclosedRegexWithSymbol(@"`")] formattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
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
