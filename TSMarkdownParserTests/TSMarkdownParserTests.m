//
//  TSMarkdownParserTests.m
//  TSMarkdownParserTests
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "TSMarkdownParser.h"

@interface TSMarkdownParserTests : XCTestCase

@end

@implementation TSMarkdownParserTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicBoldParsing {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    NSError *error;
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"\\*{2}.*\\*{2}" options:NSRegularExpressionCaseInsensitive error:&error];
    [parser addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 2)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-4, 2)];

    }];

    NSAttributedString *attributedString = [parser attributedStringFromMarkdown:@"Hello\nMen att **Pär är här** men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertTrue([attributedString.string rangeOfString:@"*"].location == NSNotFound);
}

- (void)testBasicEmParsing {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    NSError *error;
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"\\*{1}.*\\*{1}" options:NSRegularExpressionCaseInsensitive error:&error];
    [parser addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-2, 1)];

    }];

    NSAttributedString *attributedString = [parser attributedStringFromMarkdown:@"Hello\nMen att *Pär är här* men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertTrue([attributedString.string rangeOfString:@"*"].location == NSNotFound);
}

- (void)testStandardFont {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    UIFont *font = [UIFont systemFontOfSize:12];
    XCTAssertEqualObjects(parser.paragraphFont, font);
}

- (void)testBoldFont {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    XCTAssertEqualObjects(parser.strongFont, font);
}

- (void)testItalicFont {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    XCTAssertEqualObjects(parser.emphasisFont, font);
}

- (void)testDefaultBoldParsing {
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att **Pär är här** men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultEmParsing {
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att *Pär är här* men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultBoldParsingUnderscores {
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att __Pär är här__ men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultEmParsingUnderscores {
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att _Pär är här_ men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultListWithAstricsParsing {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n* Men att Pär är här\nmen inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\\t Men att Pär är här\nmen inte Pia");
}

- (void)testDefaultListWithAstricsParsingMultiple {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n* Men att Pär är här\n* Men inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\\t Men att Pär är här\n•\\t Men inte Pia");
}

- (void)testDefaultListWithPlusParsing {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n+ Men att Pär är här\nmen inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\\t Men att Pär är här\nmen inte Pia");
}

- (void)testDefaultListWithPlusParsingMultiple {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n+ Men att Pär är här\n+ Men inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\\t Men att Pär är här\n•\\t Men inte Pia");
}

- (void)testDefaultLinkParsing {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n Men att [Pär](http://www.google.com/) är här\nmen inte Pia"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"http://www.google.com/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"Pär"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);

}

- (void)testDefaultLinkParsingMultipleLinks {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n Men att [Pär](http://www.google.com/) är här\nmen inte [Pia](http://www.google.com/) "];

    //Pär link
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"http://www.google.com/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"Pär"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);

    //Pia link
    NSURL *piaLink = [attributedString attribute:NSLinkAttributeName atIndex:37 effectiveRange:NULL];
    XCTAssertEqualObjects(piaLink, [NSURL URLWithString:@"http://www.google.com/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"Pia"].location != NSNotFound);
    NSNumber *piaUnderline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(piaUnderline, @(NSUnderlineStyleSingle));
    UIColor *piasLinkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(piasLinkColor, [UIColor blueColor]);

    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
}

- (void)testDefaultFont {
    UIFont *font = [UIFont systemFontOfSize:12];
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n Men att Pär är här\nmen inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:6 effectiveRange:NULL], font);
}

- (void)testDefaultH1 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n# Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont boldSystemFontOfSize:23.f];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 23.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH2 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n## Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont boldSystemFontOfSize:21.f];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH3 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont boldSystemFontOfSize:19.f];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 19.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH4 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n#### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont boldSystemFontOfSize:17.f];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 17.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH5 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n##### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont boldSystemFontOfSize:15.f];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 15.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH6 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n###### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont boldSystemFontOfSize:13.f];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 13.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH6NextLine {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n###### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:30 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont systemFontOfSize:12];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 12.f);
}

- (void)testMultipleMatches {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"##Hello\nMen att *Pär* är här\n+ men inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\n•\\t men inte Pia");
}

- (void)testDefaultImage {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Men att ![Pär](markdown) är här\nmen inte Pia"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:8 effectiveRange:NULL];
    XCTAssertNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:8 effectiveRange:NULL];
    XCTAssertNotNil(attachment);
    XCTAssertNotNil(attachment.image);
    XCTAssertTrue([attributedString.string rangeOfString:@"Pär"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"!"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"carrots"].location == NSNotFound);
    XCTAssertEqualObjects(attributedString.string, @"Men att  är här\nmen inte Pia");
}

- (void)testDefaultImageMissingImage {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Men att ![Pär](markdownas) är här\nmen inte Pia"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:8 effectiveRange:NULL];
    XCTAssertNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:8 effectiveRange:NULL];
    XCTAssertNil(attachment);
    XCTAssertTrue([attributedString.string rangeOfString:@"Pär"].location != NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"!"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"carrots"].location == NSNotFound);
    XCTAssertEqualObjects(attributedString.string, @"Men att Pär är här\nmen inte Pia");
}

- (void)testDefaultBoldParsingCustomFont {
    TSMarkdownParser *parser = [TSMarkdownParser standardParser];
    UIFont *customFont = [UIFont boldSystemFontOfSize:19];
    parser.strongFont = customFont;
    NSAttributedString *attributedString = [parser attributedStringFromMarkdown:@"Hello\nMen att **Pär är här** men inte Pia"];
    XCTAssertEqual([[attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL] pointSize], 19.f);
}

@end
