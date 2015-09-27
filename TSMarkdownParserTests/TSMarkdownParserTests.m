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

/// [[TSMarkdownParser alloc] init] version
@property (nonatomic) TSMarkdownParser *parser;
/// [TSMarkdownParser standardParser] version
@property (nonatomic) TSMarkdownParser *standardParser;

@end

@implementation TSMarkdownParserTests

- (void)setUp
{
    [super setUp];

    self.parser = [TSMarkdownParser new];
    self.standardParser = [TSMarkdownParser standardParser];
}

- (void)tearDown
{
    self.parser = nil;
    self.standardParser = nil;

    [super tearDown];
}

- (void)testBasicBoldParsing {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    NSError *error;
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"\\*{2}.*\\*{2}" options:NSRegularExpressionCaseInsensitive error:&error];
    [self.parser addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 2)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-4, 2)];

    }];

    NSAttributedString *attributedString = [self.parser attributedStringFromMarkdown:@"Hello\nMen att **Pär är här** men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertTrue([attributedString.string rangeOfString:@"*"].location == NSNotFound);
}

- (void)testBasicEmParsing {
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    NSError *error;
    NSRegularExpression *boldParsing = [NSRegularExpression regularExpressionWithPattern:@"\\*{1}.*\\*{1}" options:NSRegularExpressionCaseInsensitive error:&error];
    [self.parser addParsingRuleWithRegularExpression:boldParsing withBlock:^(NSTextCheckingResult *match, NSMutableAttributedString *attributedString) {

        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:match.range];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location, 1)];
        [attributedString deleteCharactersInRange:NSMakeRange(match.range.location+match.range.length-2, 1)];

    }];

    NSAttributedString *attributedString = [self.parser attributedStringFromMarkdown:@"Hello\nMen att *Pär är här* men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertTrue([attributedString.string rangeOfString:@"*"].location == NSNotFound);
}

- (void)testStandardFont {
    UIFont *font = [UIFont systemFontOfSize:12];
    XCTAssertEqualObjects(self.parser.paragraphFont, font);
}

- (void)testBoldFont {
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    XCTAssertEqualObjects(self.parser.strongFont, font);
}

- (void)testItalicFont {
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    XCTAssertEqualObjects(self.parser.emphasisFont, font);
}

- (void)testDefaultBoldParsing {
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    NSAttributedString *attributedString = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:@"Hello\nMen att **Pär är här** men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultMonospaceFontParsing {
    TSMarkdownParser *parser = [TSMarkdownParser standardParser];
    UIFont *font = [parser monospaceFont];
    NSAttributedString *attributedString = [parser attributedStringFromMarkdown:@"Hello\nMen att `Pär är här` men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultMonospaceParsing {
    TSMarkdownParser *parser = [TSMarkdownParser standardParser];
    NSAttributedString *attributedString = [parser attributedStringFromMarkdown:@"Hello\nMen att `Pär är här` men inte Pia"];
    XCTAssertTrue([attributedString.string rangeOfString:@"`"].location == NSNotFound);
}

- (void)testDefaultEmParsing {
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\nMen att *Pär är här* men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultBoldParsingUnderscores {
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\nMen att __Pär är här__ men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

- (void)testDefaultEmParsingUnderscores {
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\nMen att _Pär är här_ men inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här men inte Pia");
}

//https://github.com/laptobbe/TSMarkdownParser/issues/24
- (void)testDefaultEmParsingOneCharacter {
    UIFont *font = [UIFont italicSystemFontOfSize:12];
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"This is *a* nice *boy*"];
    XCTAssertNotEqualObjects([attributedString attribute:NSFontAttributeName atIndex:9 effectiveRange:NULL], font);
}

- (void)testDefaultStrongAndEmAndMonospaceInSameInputParsing {
    UIFont *strongFont = self.parser.strongFont;
    UIFont *emphasisFont = self.parser.emphasisFont;
    UIFont *monospaceFont = self.parser.monospaceFont;

    NSMutableArray *emphasizedSnippets = @[@"under", @"From", @"progress"].mutableCopy;
    NSUInteger expectedNumberOfEmphasisBlocks = emphasizedSnippets.count;
    __block NSUInteger actualNumberOfEmphasisBlocks = 0;

    NSMutableArray *strongSnippets = @[@"Tennis Court", @"Strawberries and Cream", @"Worn Grass"].mutableCopy;
    NSUInteger expectedNumberOfStrongBlocks = strongSnippets.count;
    __block NSUInteger actualNumberOfStrongBlocks = 0;

    NSMutableArray *monospaceSnippets = @[@"tournament", @"seat", ].mutableCopy;
    NSUInteger expectedNumberOfMonospaceBlocks = monospaceSnippets.count;
    __block NSUInteger actualNumberOfMonospaceBlocks = 0;
    
    void (^IncreaseCountAndRemoveSnippet)(NSUInteger *, NSString *, NSMutableArray *) = ^(NSUInteger *count, NSString *snippet, NSMutableArray *snippets) {
        *count += 1;
        [snippets removeObject:snippet];
    };

    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"**Tennis Court** Stand *under* the spectacular glass-and-steel roof.\n\n__Strawberries and Cream__ _From_ your `seat`.\n\n**Worn Grass** See the *progress* of the `tournament`."];
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.string.length)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
                                          UIFont *font = attributes[NSFontAttributeName];
                                          NSString *snippet = [attributedString.string substringWithRange:range];

                                          if ( [emphasisFont isEqual:font] ) {
                                              IncreaseCountAndRemoveSnippet(&actualNumberOfEmphasisBlocks, snippet, emphasizedSnippets);
                                          } else if ( [strongFont isEqual:font] ) {
                                              IncreaseCountAndRemoveSnippet(&actualNumberOfStrongBlocks, snippet, strongSnippets);
                                          } else if ([monospaceFont isEqual:font]) {
                                              IncreaseCountAndRemoveSnippet(&actualNumberOfMonospaceBlocks, snippet, monospaceSnippets);
                                          }
                                      }];

    XCTAssertEqual(actualNumberOfEmphasisBlocks, expectedNumberOfEmphasisBlocks);
    XCTAssertEqual(emphasizedSnippets.count, 0);

    XCTAssertEqual(actualNumberOfStrongBlocks, expectedNumberOfStrongBlocks);
    XCTAssertEqual(strongSnippets.count, 0);
    
    XCTAssertEqual(actualNumberOfMonospaceBlocks, expectedNumberOfMonospaceBlocks);
    XCTAssertEqual(monospaceSnippets.count, 0);
}

- (void)testDefaultListWithAstricsParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n* Men att Pär är här\nmen inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\t Men att Pär är här\nmen inte Pia");
}

- (void)testDefaultListWithAstricsParsingMultiple {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n* Men att Pär är här\n* Men inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\t Men att Pär är här\n•\t Men inte Pia");
}

- (void)testCustomListWithAsterisksParsingWithStrongText {
    UIFont *strongFont = [UIFont boldSystemFontOfSize:12];

    [self.parser addListParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString replaceCharactersInRange:range withString:@"    • "];
    }];
    [self.parser addStrongParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString addAttribute:NSFontAttributeName
                                 value:strongFont
                                 range:range];
    }];

    NSUInteger expectedNumberOfStrongBlocks = 1;
    __block NSUInteger actualNumberOfStrongBlocks = 0;
    NSMutableArray *strongSnippets = @[@"Strong Text:"].mutableCopy;

    NSString *expectedRawString = @"Strong Text: Some Subtitle.\n\n    •  List Item One\n    •  List Item Two";
    NSAttributedString *attributedString = [self.parser attributedStringFromMarkdown:@"**Strong Text:** Some Subtitle.\n\n* List Item One\n* List Item Two"];
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.string.length)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
                                          UIFont *font = attributes[NSFontAttributeName];
                                          if ( [strongFont isEqual:font] ) {
                                              actualNumberOfStrongBlocks++;

                                              NSString *snippet = [attributedString.string substringWithRange:range];
                                              [strongSnippets removeObject:snippet];
                                          }
                                      }];

    XCTAssertEqual(actualNumberOfStrongBlocks, expectedNumberOfStrongBlocks);
    XCTAssertEqual(strongSnippets.count, 0);

    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testDefaultListWithPlusParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n+ Men att Pär är här\nmen inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\t Men att Pär är här\nmen inte Pia");
}

- (void)testDefaultListWithDashParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n- Men att Pär är här\nmen inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\t Men att Pär är här\nmen inte Pia");
}

- (void)testDefaultListWithPlusParsingMultiple {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n+ Men att Pär är här\n+ Men inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\t Men att Pär är här\n•\t Men inte Pia");
}

- (void)testThatDefaultListWorksWithMultipleDifferentListOptions {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n+ item1\n- item2\n* item3"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\t item1\n•\t item2\n•\t item3");
}


- (void)testDefaultLinkParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n Men att [Pär](https://www.example.net/) är här\nmen inte Pia"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"Pär"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
    
    NSURL *linkAtTheNextCharacter = [attributedString attribute:NSLinkAttributeName atIndex:18 effectiveRange:NULL];
    XCTAssertNil(linkAtTheNextCharacter);
}

- (void)testDefaultLinkParsingOnEndOfStrings {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n Men att [Pär](https://www.example.net/)"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
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

- (void)testDefaultLinkParsingEnclosedInParenthesis {
    NSString *expectedRawString = @"Hello\n Men att (Pär) är här\nmen inte Pia";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n Men att ([Pär](https://www.example.net/)) är här\nmen inte Pia"];
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.string.length)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
                                          NSURL *link = attributes[NSLinkAttributeName];
                                          if ( link ) {
                                              XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);

                                              NSNumber *underlineStyle = attributes[NSUnderlineStyleAttributeName];
                                              XCTAssertEqualObjects(underlineStyle, @(NSUnderlineStyleSingle));

                                              UIColor *linkColor = attributes[NSForegroundColorAttributeName];
                                              XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
                                          }
                                      }];

    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testDefaultLinkParsingMultipleLinks {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n Men att [Pär](https://www.example.net/) är här. men inte [Pia](https://www.example.net/) "];

    //Pär link
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"Pär"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
    
    //Pia link
    NSURL *piaLink = [attributedString attribute:NSLinkAttributeName atIndex:37 effectiveRange:NULL];
    XCTAssertEqualObjects(piaLink, [NSURL URLWithString:@"https://www.example.net/"]);
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

// https://github.com/laptobbe/TSMarkdownParser/pull/22
- (void)testDefaultLinkParsingWithPipe {
    NSString *expectedRawString = @"Hello (link). Bye";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello ([link](https://www.example.net/|)). Bye"];
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.string.length)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
                                          NSURL *link = attributes[NSLinkAttributeName];
                                          if ( link ) {
                                              XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/|"]);
                                              
                                              NSNumber *underlineStyle = attributes[NSUnderlineStyleAttributeName];
                                              XCTAssertEqualObjects(underlineStyle, @(NSUnderlineStyleSingle));
                                              
                                              UIColor *linkColor = attributes[NSForegroundColorAttributeName];
                                              XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
                                          }
                                      }];
    
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testDefaultFont {
    UIFont *font = [UIFont systemFontOfSize:12];
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n Men att Pär är här\nmen inte Pia"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:6 effectiveRange:NULL], font);
}

- (void)testDefaultH1 {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n# Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = self.standardParser.h1Font;
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 23.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\nmen inte Pia");
}

- (void)testThatH1IsParsedCorrectly {
    NSString *header = @"header";
    NSString *input = [NSString stringWithFormat:@"first line\n# %@\nsecond line", header];
    UIFont *h1Font = self.standardParser.h1Font;
    
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:input];
    NSString *string = attributedString.string;
    NSRange headerRange = [string rangeOfString:header];
    XCTAssertTrue(headerRange.location != NSNotFound);
    
    [attributedString enumerateAttributesInRange:headerRange options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
        UIFont *font = attributes[NSFontAttributeName];
        XCTAssertNotNil(font);
        XCTAssertEqual(font, h1Font);
    }];
}

// '#header' is not a valid header per markdown syntax and shouldn't be parsed as one
- (void)testThatHeaderIsNotParsedWithoutSpaceInBetween {
    NSString *header = @"header";
    NSString *notValidHeader = [NSString stringWithFormat:@"#%@", header];
    UIFont *h1Font = self.standardParser.h1Font;
    
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:notValidHeader];
    NSRange headerRange = [attributedString.string rangeOfString:header];
    [attributedString enumerateAttributesInRange:headerRange options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
        UIFont *font = attributes[NSFontAttributeName];
        XCTAssertNotEqual(font, h1Font);
    }];
    XCTAssertEqualObjects(attributedString.string, notValidHeader);
}

- (void)testThatHeaderIsNotParsedAtNotBeginningOfTheLine {
    NSString *hashtag = @"#hashtag";
    NSString *input = [NSString stringWithFormat:@"A sentence %@", hashtag];
    
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:input];
    XCTAssertEqualObjects(attributedString.string, input);
    NSRange hashTagStillThereRange = [attributedString.string rangeOfString:hashtag];
    XCTAssertTrue(hashTagStillThereRange.location != NSNotFound);
}

- (void)testDefaultH2 {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n## Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = self.standardParser.h2Font;
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\nmen inte Pia");
}

- (void)testDefaultH3 {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = self.standardParser.h3Font;
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 19.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\nmen inte Pia");
}

- (void)testDefaultH4 {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n#### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = self.standardParser.h4Font;
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 17.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\nmen inte Pia");
}

- (void)testDefaultH5 {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n##### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = self.standardParser.h5Font;
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 15.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\nmen inte Pia");
}

- (void)testDefaultH6 {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n###### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL];
    UIFont *expectedFont = self.standardParser.h6Font;
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 13.f);
    XCTAssertTrue([attributedString.string rangeOfString:@"#"].location == NSNotFound);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\nmen inte Pia");
}

- (void)testDefaultH6NextLine {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n###### Men att Pär är här\nmen inte Pia"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:30 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont systemFontOfSize:12];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, 12.f);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\nmen inte Pia");
}

- (void)testMultipleMatches {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"## Hello\nMen att *Pär* är här\n+ men inte Pia"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\nMen att Pär är här\n•\t men inte Pia");
}

- (void)testDefaultImage {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Men att ![Pär](markdown) är här\nmen inte Pia"];
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
    NSString *expected = @"Men att \uFFFC är här\nmen inte Pia";
    XCTAssertEqualObjects(attributedString.string, expected);
}

- (void)testDefaultImageWithUnderscores {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"A ![AltText](markdown_test_image)"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:2 effectiveRange:NULL];
    XCTAssertNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:2 effectiveRange:NULL];
    XCTAssertNotNil(attachment);
    XCTAssertNotNil(attachment.image);
    XCTAssertTrue([attributedString.string rangeOfString:@"AltText"].location == NSNotFound);
    NSString *expected = @"A \uFFFC";
    XCTAssertEqualObjects(attributedString.string, expected);
}

- (void)testDefaultImageMultiple {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Men att ![Pär](markdown) är här ![Pär](markdown)\nmen inte Pia"];
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
    NSString *expected = @"Men att \uFFFC är här \uFFFC\nmen inte Pia";
    XCTAssertEqualObjects(attributedString.string, expected);
}

- (void)testDefaultImageMissingImage {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Men att ![Pär](markdownas) är här\nmen inte Pia"];
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
    UIFont *customFont = [UIFont boldSystemFontOfSize:19];
    self.standardParser.strongFont = customFont;
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\nMen att **Pär är här** men inte Pia"];
    XCTAssertEqual([[attributedString attribute:NSFontAttributeName atIndex:16 effectiveRange:NULL] pointSize], 19.f);
}

- (void)testURLWithParenthesesInTheTitleText {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkdown:@"Hello\n Men att [Pär och (Mia)](https://www.example.net/) är här."];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"Pär"].location != NSNotFound);
}

@end
