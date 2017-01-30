//
//  TSMarkupParserTests.m
//  TSMarkdownParserTests
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TSMarkdownStandardParser.h>
#import <TSMarkupParser+FormatExamples.h>
#import "NSMutableAttributedString+TSTraits.h"


@interface TSMarkupParserTests : XCTestCase

/// [TSMarkupParser new] version
@property (nonatomic) TSMarkupParser *parser;

@end


@implementation TSMarkupParserTests

- (void)setUp
{
    [super setUp];
    
    self.parser = [TSMarkupParser new];
    self.parser.resourceBundle = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown
{
    self.parser = nil;
    
    [super tearDown];
}

- (void)testBasicBoldParsing {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    NSError *error;
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"\\*{2}.*\\*{2}" options:NSRegularExpressionCaseInsensitive error:&error];
    [self.parser addParsingRuleWithRegularExpression:boldParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 2)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location + match.range.length-4, 2)];
    }];

    NSAttributedString *attributedString = [self.parser attributedStringFromMarkup:@"Hello\nI go to **café** everyday"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:15 effectiveRange:NULL], font);
    XCTAssertTrue([attributedString.string rangeOfString:@"*"].location == NSNotFound);
}

- (void)testBasicEmParsing {
#if TARGET_OS_IPHONE
    UIFont *font = [UIFont italicSystemFontOfSize:12];
#else
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12];
#endif
    NSError *error;
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"\\*{1}.*\\*{1}" options:NSRegularExpressionCaseInsensitive error:&error];
    [self.parser addParsingRuleWithRegularExpression:boldParsing block:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-2, 1)];
    }];

    NSAttributedString *attributedString = [self.parser attributedStringFromMarkup:@"Hello\nI go to *café* everyday"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:15 effectiveRange:NULL], font);
    XCTAssertTrue([attributedString.string rangeOfString:@"*"].location == NSNotFound);
}

- (void)testCustomListWithAsterisksParsingWithStrongText {
    UIFont *strongFont = [UIFont boldSystemFontOfSize:12];

    [self.parser addListParsingWithMaxLevel:1 separator:@" " leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, __unused NSUInteger level) {
        [attributedString replaceCharactersInRange:range withString:@"    • "];
    } textFormattingBlock:nil];
    [self.parser addStrongParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString addAttribute:NSFontAttributeName
                                 value:strongFont
                                 range:range];
    }];

    NSUInteger expectedNumberOfStrongBlocks = 1;
    __block NSUInteger actualNumberOfStrongBlocks = 0;
    NSMutableArray *strongSnippets = @[@"Strong Text:"].mutableCopy;

    NSString *expectedRawString = @"Strong Text: Some Subtitle.\n\n    • List Item One\n    • List Item Two";
    NSAttributedString *attributedString = [self.parser attributedStringFromMarkup:@"**Strong Text:** Some Subtitle.\n\n* List Item One\n* List Item Two"];
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(NSDictionary *attributes, NSRange range, __unused BOOL *stop) {
                                          UIFont *font = attributes[NSFontAttributeName];
                                          if ([strongFont isEqual:font]) {
                                              actualNumberOfStrongBlocks++;

                                              NSString *snippet = [attributedString.string substringWithRange:range];
                                              [strongSnippets removeObject:snippet];
                                          }
                                      }];

    XCTAssertEqual(actualNumberOfStrongBlocks, expectedNumberOfStrongBlocks);
    XCTAssertEqual(strongSnippets.count, 0);

    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testSubLineHeaderParsing {
    NSArray *headerAttributes = @[ @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:23] },
                                   @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:21] }];
    __block NSString *trail = nil;
    [self.parser addSubLineHeaderParsingWithMinLevel:1 trailFormattingBlock:^(NSMutableAttributedString * _Nonnull attributedString, NSRange range, __unused NSUInteger markupLength) {
        trail = [attributedString.string substringWithRange:NSMakeRange(range.location + 1, 1)];
        [attributedString deleteCharactersInRange:range];
    } textFormattingBlock:^(NSMutableAttributedString * _Nonnull attributedString, NSRange range, __unused NSUInteger markupLength) {
        if ([trail isEqualToString:@"="])
            [attributedString ts_addAttributes:headerAttributes atIndex:0 range:range];
        else if ([trail isEqualToString:@"-"])
            [attributedString ts_addAttributes:headerAttributes atIndex:1 range:range];
    }];
    NSString *expectedRawString = @"Header1\nHeader2";
    NSAttributedString *attributedString = [self.parser attributedStringFromMarkup:@"Header1\n==\nHeader2\n-"];
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

@end
