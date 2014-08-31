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
    NSError *error;
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"\\*{2}.*\\*{2}" options:NSRegularExpressionCaseInsensitive error:&error];
    [parser addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:12]
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 2)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-4, 2)];

    }];

    NSAttributedString *attributedString = [parser attributedStringFromMarkdown:@"Hello\nMen att **Pär är här** men inte Pia"];
    XCTAssertEqualObjects([[attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL] fontName], @".Helvetica NeueUI Bold");
    XCTAssertTrue([attributedString.string rangeOfString:@"*"].location == NSNotFound);
}

- (void)testBasicEmParsing {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    NSError *error;
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"\\*{1}.*\\*{1}" options:NSRegularExpressionCaseInsensitive error:&error];
    [parser addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont italicSystemFontOfSize:12]
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-2, 1)];

    }];

    NSAttributedString *attributedString = [parser attributedStringFromMarkdown:@"Hello\nMen att *Pär är här* men inte Pia"];
    XCTAssertEqualObjects([[attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL] fontName], @".Helvetica NeueUI Italic");
    XCTAssertTrue([attributedString.string rangeOfString:@"*"].location == NSNotFound);
}

- (void)testStandardFont {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    XCTAssertEqualObjects(parser.paragraphFont.fontName, @".Helvetica NeueUI");
}

- (void)testBoldFont {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    XCTAssertEqualObjects(parser.strongFont.fontName, @".Helvetica NeueUI Bold");
}

- (void)testItalicFont {
    TSMarkdownParser *parser = [TSMarkdownParser new];
    XCTAssertEqualObjects(parser.emphasisFont.fontName, @".Helvetica NeueUI Italic");
}

- (void)testDefaultBoldParsing {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att **Pär är här** men inte Pia"];
    XCTAssertEqualObjects([[attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL] fontName], @".Helvetica NeueUI Bold");
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultEmParsing {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att *Pär är här* men inte Pia"];
    XCTAssertEqualObjects([[attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL] fontName], @".Helvetica NeueUI Italic");
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultBoldParsingUnderscores {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att __Pär är här__ men inte Pia"];
    XCTAssertEqualObjects([[attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL] fontName], @".Helvetica NeueUI Bold");
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultEmParsingUnderscores {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att _Pär är här_ men inte Pia"];
    XCTAssertEqualObjects([[attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL] fontName], @".Helvetica NeueUI Italic");
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
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n Men att Pär är här\nmen inte Pia"];
    XCTAssertEqualObjects([[attributedString attribute:NSFontAttributeName atIndex:6 effectiveRange:NULL] fontName], @".Helvetica NeueUI");
}

- (void)testDefaultH1 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n# Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font.fontName, @".Helvetica NeueUI Bold");
    XCTAssertEqual(font.pointSize, 23.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH2 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n## Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font.fontName, @".Helvetica NeueUI Bold");
    XCTAssertEqual(font.pointSize, 21.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH3 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font.fontName, @".Helvetica NeueUI Bold");
    XCTAssertEqual(font.pointSize, 19.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH4 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n#### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font.fontName, @".Helvetica NeueUI Bold");
    XCTAssertEqual(font.pointSize, 17.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH5 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n##### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font.fontName, @".Helvetica NeueUI Bold");
    XCTAssertEqual(font.pointSize, 15.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH6 {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n###### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font.fontName, @".Helvetica NeueUI Bold");
    XCTAssertEqual(font.pointSize, 13.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
}

- (void)testDefaultH6NextLine {
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\n###### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:30 effectiveRange:NULL];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font.fontName, @".Helvetica NeueUI");
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

@end
