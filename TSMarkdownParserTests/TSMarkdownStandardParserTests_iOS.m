//
//  TSMarkdownStandardParserTests.m
//  TSMarkdownParserTests
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TSMarkdownStandardParser.h>
#import <TSMarkupParser+FormatExamples.h>


#if TARGET_OS_TV
#define defaultSize 29
#else
#define defaultSize 12
#endif


@interface TSMarkdownStandardParserTests : XCTestCase

/// `[TSMarkdownStandardParser new]` version.
/// It should follow the behavior of https://daringfireball.net/projects/markdown/dingus
@property (nonatomic) TSMarkdownStandardParser *standardParser;
/// `[TSMarkdownStandardParser lenientParser]` version.
@property (nonatomic) TSMarkdownStandardParser *lenientParser;

@end


@implementation TSMarkdownStandardParserTests

- (void)setUp
{
    [super setUp];
    
    self.standardParser = [TSMarkdownStandardParser new];
    self.standardParser.resourceBundle = [NSBundle bundleForClass:[self class]];
    self.lenientParser = [TSMarkdownStandardParser lenientParser];
    self.lenientParser.resourceBundle = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown
{
    self.standardParser = nil;
    self.lenientParser = nil;
    
    [super tearDown];
}

- (void)testStandardDefaultFont {
    UIFont *font = [UIFont systemFontOfSize:defaultSize];
    XCTAssertEqualObjects(self.standardParser.defaultAttributes[NSFontAttributeName], font);
    XCTAssertEqualObjects(self.lenientParser.defaultAttributes[NSFontAttributeName], font);
}

- (void)testStandardBoldTrait {
    XCTAssertEqual(self.standardParser.strongTraits, (TSFontTraitMask)TSFontMaskBold);
    XCTAssertEqual(self.lenientParser.strongTraits, (TSFontTraitMask)TSFontMaskBold);
}

- (void)testStandardItalicTrait {
    XCTAssertEqual(self.standardParser.emphasisTraits, (TSFontTraitMask)TSFontMaskItalic);
    XCTAssertEqual(self.lenientParser.emphasisTraits, (TSFontTraitMask)TSFontMaskItalic);
}

- (void)testStandardDefaultFontParsing {
    UIFont *font = [UIFont systemFontOfSize:defaultSize];
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\nI drink in a café everyday"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:6 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\nI drink in a café everyday"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:6 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
}

- (void)testStandardBoldParsing {
    TSFontTraitMask strongTrait = (TSFontTraitMask)TSFontMaskBold;
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\nI drink in **a café** everyday"];
    XCTAssert(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\nI drink in **a café** everyday"];
    XCTAssert(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
}

- (void)testStandardEmParsing {
    TSFontTraitMask emphasisTrait = (TSFontTraitMask)TSFontMaskItalic;
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\nI drink in *a café* everyday"];
    XCTAssert(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\nI drink in *a café* everyday"];
    XCTAssert(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
}

- (void)testStandardBoldParsingUnderscores {
    TSFontTraitMask strongTrait = (TSFontTraitMask)TSFontMaskBold;
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\nI drink in __a café__ everyday"];
    XCTAssert(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\nI drink in __a café__ everyday"];
    XCTAssert(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
}

- (void)testStandardEmParsingUnderscores {
    TSFontTraitMask emphasisTrait = (TSFontTraitMask)TSFontMaskItalic;
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\nI drink in _a café_ everyday"];
    XCTAssert(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\nI drink in _a café_ everyday"];
    XCTAssert(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
}

- (void)testStandardMonospaceParsing {
    UIFont *font = self.standardParser.monospaceAttributes[NSFontAttributeName];
    UIFont *lenientFont = self.lenientParser.monospaceAttributes[NSFontAttributeName];
    XCTAssertEqualObjects(font, lenientFont);
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\nI drink in `a café` everyday"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\nI drink in `a café` everyday"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:20 effectiveRange:NULL], font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday");
}

- (void)testStandardBoldParsingOneCharacter {
    TSFontTraitMask strongTrait = (TSFontTraitMask)TSFontMaskBold;
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"This is **a** nice **boy**"];
    XCTAssert(!(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:9 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait));
    attributedString = [self.lenientParser attributedStringFromMarkup:@"This is **a** nice **boy**"];
    XCTAssert(!(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:9 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait));
}

//https://github.com/laptobbe/TSMarkdownParser/issues/24
- (void)testStandardEmParsingOneCharacter {
    TSFontTraitMask emphasisTrait = (TSFontTraitMask)TSFontMaskItalic;
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"This is *a* nice *boy*"];
    XCTAssert(!(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:9 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait));
    attributedString = [self.lenientParser attributedStringFromMarkup:@"This is *a* nice *boy*"];
    XCTAssert(!(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:9 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait));
}

- (void)testStandardMonospaceParsingOneCharacter {
    UIFont *font = self.standardParser.monospaceAttributes[NSFontAttributeName];
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"This is `a` nice `boy`"];
    XCTAssertNotEqualObjects([attributedString attribute:NSFontAttributeName atIndex:9 effectiveRange:NULL], font);
    attributedString = [self.lenientParser attributedStringFromMarkup:@"This is `a` nice `boy`"];
    XCTAssertNotEqualObjects([attributedString attribute:NSFontAttributeName atIndex:9 effectiveRange:NULL], font);
}

- (void)testStandardStrongAndEmAndMonospaceInSameInputParsing {
    TSFontTraitMask strongTrait = (TSFontTraitMask)TSFontMaskBold;
    TSFontTraitMask emphasisTrait = (TSFontTraitMask)TSFontMaskItalic;
    UIFont *monospaceFont = self.standardParser.monospaceAttributes[NSFontAttributeName];
    
    NSMutableArray *emphasizedSnippets = @[@"under", @"From", @"progress"].mutableCopy;
    NSUInteger expectedNumberOfEmphasisBlocks = emphasizedSnippets.count;
    __block NSUInteger actualNumberOfEmphasisBlocks = 0;
    
    NSMutableArray *strongSnippets = @[@"Tennis Court", @"Strawberries and Cream", @"Worn Grass"].mutableCopy;
    NSUInteger expectedNumberOfStrongBlocks = strongSnippets.count;
    __block NSUInteger actualNumberOfStrongBlocks = 0;
    
    NSMutableArray *monospaceSnippets = @[@"tournament", @"seat"].mutableCopy;
    NSUInteger expectedNumberOfMonospaceBlocks = monospaceSnippets.count;
    __block NSUInteger actualNumberOfMonospaceBlocks = 0;
    
    void (^IncreaseCountAndRemoveSnippet)(NSUInteger *, NSString *, NSMutableArray *) = ^(NSUInteger *count, NSString *snippet, NSMutableArray *snippets) {
        *count += 1;
        [snippets removeObject:snippet];
    };
    
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"**Tennis Court** Stand *under* the spectacular glass-and-steel roof.\n\n__Strawberries and Cream__ _From_ your `seat`.\n\n**Worn Grass** See the *progress* of the `tournament`."];
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(NSDictionary *attributes, NSRange range, __unused BOOL *stop) {
                                          UIFont *font = attributes[NSFontAttributeName];
                                          NSString *snippet = [attributedString.string substringWithRange:range];
                                          
                                          if (font.fontDescriptor.symbolicTraits & emphasisTrait) {
                                              IncreaseCountAndRemoveSnippet(&actualNumberOfEmphasisBlocks, snippet, emphasizedSnippets);
                                          } else if (font.fontDescriptor.symbolicTraits & strongTrait) {
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

- (void)testStandardBoldEmParsing {
    TSFontTraitMask strongTrait = (TSFontTraitMask)TSFontMaskBold;
    TSFontTraitMask emphasisTrait = (TSFontTraitMask)TSFontMaskItalic;
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"This ***is*** a ***nice* boy**"];
    // Expect: This <strong><em>is</em></strong> a <strong><em>nice</em> boy</strong>
    XCTAssert((((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:5 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait));
    XCTAssert((((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:5 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait));
    XCTAssert(!(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:7 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait));
    XCTAssert(!(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:7 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait));
    attributedString = [self.lenientParser attributedStringFromMarkup:@"This ***is*** a ***nice* boy**"];
    // Expect: This <strong><em>is</em></strong> a <strong><em>nice</em> boy</strong>
    XCTAssert((((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:5 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait));
    XCTAssert((((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:5 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait));
    XCTAssert(!(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:7 effectiveRange:NULL]).fontDescriptor.symbolicTraits & strongTrait));
    XCTAssert(!(((UIFont*)[attributedString attribute:NSFontAttributeName atIndex:7 effectiveRange:NULL]).fontDescriptor.symbolicTraits & emphasisTrait));
}

- (void)testStandardListWithAsteriskParsing {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n* I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n* I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardListWith2AsterisksParsing {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n** I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n\t•\tI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n** I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n\t•\tI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardQuoteParsing {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n> I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n\tI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n> I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n\tI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardQuoteLevel2Parsing {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n>> I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n\t\tI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n>> I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n\t\tI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardListWithAsteriskParsingMultiple {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n* I drink in a café everyday\n* to use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\n•\tto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n* I drink in a café everyday\n* to use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\n•\tto use Wi-Fi");
}

- (void)testStandardListWithPlusParsing {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n+ I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n+ I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardListWithDashParsing {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n- I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n- I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardListWithPlusParsingMultiple {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n+ I drink in a café everyday\n+ to use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\n•\tto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n+ I drink in a café everyday\n+ to use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\tI drink in a café everyday\n•\tto use Wi-Fi");
}

- (void)testStandardListWorksWithMultipleDifferentListOptions {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n+ item1\n- item2\n* item3"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\titem1\n•\titem2\n•\titem3");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n+ item1\n- item2\n* item3"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n•\titem1\n•\titem2\n•\titem3");
}


- (void)testStandardLinkParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n This is a [link](https://www.example.net/) to test Wi-Fi\nat home"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"link"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);

    NSURL *linkAtTheNextCharacter = [attributedString attribute:NSLinkAttributeName atIndex:21 effectiveRange:NULL];
    XCTAssertNil(linkAtTheNextCharacter);
}

- (void)testStandardLinkParsingAutodetectionConflict {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n This is a [foo@bar.com](https://www.example.net/) to test Wi-Fi\nat home"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"foo@bar.com"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
    
    NSURL *linkAtTheNextCharacter = [attributedString attribute:NSLinkAttributeName atIndex:28 effectiveRange:NULL];
    XCTAssertNil(linkAtTheNextCharacter);
}

- (void)testStandardLinkParsingAutodetectionConflictOverlap {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n This is a [expanded foo@bar.com test](https://www.example.net/) to test Wi-Fi\nat home"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"expanded foo@bar.com test"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
    
    NSURL *linkAtTheNextCharacter = [attributedString attribute:NSLinkAttributeName atIndex:42 effectiveRange:NULL];
    XCTAssertNil(linkAtTheNextCharacter);
}

- (void)testStandardAutoLinkParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n This is a link https://www.example.net/ to test Wi-Fi\nat home"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:24 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:24 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:24 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
}

- (void)testStandardUnicodeAutoLinkParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n This is a link http://槍ヶ岳山荘.jp to test Wi-Fi\nat home"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:24 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:[@"http://槍ヶ岳山荘.jp" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:24 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:24 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
}

- (void)testStandardLinkParsingOnEndOfStrings {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n This is a [link](https://www.example.net/)"];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"link"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:20 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
}

- (void)testStandardLinkParsingEnclosedInParenthesis {
    NSString *markupString = @"Hello\n This is a ([link](https://www.example.net/)) to test Wi-Fi\nat home";
    NSString *expectedRawString = @"Hello\n This is a (link) to test Wi-Fi\nat home";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:21 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testStandardLinkParsingWithEscapedLeftBracketInside {
    NSString *markupString = @"[link with escaped \\[ inside](https://example.net/)";
    NSString *expectedRawString = @"link with escaped [ inside";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://example.net/"]);
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testStandardLinkParsingWithEscapedRightBracketInside {
    NSString *markupString = @"[link with escaped \\] inside](https://example.net/)";
    NSString *expectedRawString = @"link with escaped ] inside";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://example.net/"]);
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

// https://github.com/laptobbe/TSMarkdownParser/pull/39
- (void)testStandardLinkParsingWithBracketsInside {
    NSString *markupString = @"Hello\n [a link [with brackets inside]](https://example.net/)";
    NSString *expectedRawString = @"Hello\n a link [with brackets inside]";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:35 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://example.net/"]);
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

// https://github.com/laptobbe/TSMarkdownParser/pull/39
- (void)testStandardLinkParsingWithBracketsOutside {
    NSString *markupString = @"Hello\n [This is not a link] but this is a [link](https://www.example.net/) to test [the difference]";
    NSString *expectedRawString = @"Hello\n [This is not a link] but this is a link to test [the difference]";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:44 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testStandardLinkParsingMultipleLinks {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n This is a [link](https://www.example.net/) and this is [a link](https://www.example.com/) too"];
    
    //first link
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"link"].location != NSNotFound);
    NSNumber *underline = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(underline, @(NSUnderlineStyleSingle));
    UIColor *linkColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:17 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor, [UIColor blueColor]);
    
    //second link
    NSURL *link2 = [attributedString attribute:NSLinkAttributeName atIndex:37 effectiveRange:NULL];
    XCTAssertEqualObjects(link2, [NSURL URLWithString:@"https://www.example.com/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"a link"].location != NSNotFound);
    NSNumber *underline2 = [attributedString attribute:NSUnderlineStyleAttributeName atIndex:37 effectiveRange:NULL];
    XCTAssertEqualObjects(underline2, @(NSUnderlineStyleSingle));
    UIColor *linkColor2 = [attributedString attribute:NSForegroundColorAttributeName atIndex:37 effectiveRange:NULL];
    XCTAssertEqualObjects(linkColor2, [UIColor blueColor]);

    XCTAssertTrue([attributedString.string rangeOfString:@"["].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"]"].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@"("].location == NSNotFound);
    XCTAssertTrue([attributedString.string rangeOfString:@")"].location == NSNotFound);
}

// https://github.com/laptobbe/TSMarkdownParser/pull/22
- (void)testStandardLinkParsingWithPipe {
    NSString *markupString = @"Hello ([link](https://www.example.net/|)). Bye";
    NSString *expectedRawString = @"Hello (link). Bye";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:8 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:[@"https://www.example.net/|" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);

    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

// https://github.com/laptobbe/TSMarkdownParser/issues/30
- (void)testStandardLinkParsingWithSharp {
    NSString *markupString = @"Hello ([link](https://www.example.net/#)). Bye";
    NSString *expectedRawString = @"Hello (link). Bye";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:8 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/#"]);

    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

// https://stackoverflow.com/questions/33558933/why-is-the-return-value-of-string-addingpercentencoding-optional
- (void)testStandardLinkParsingWithUTF16 {
    // [!](�)
    uint8_t bytes[] = { 0x00, 0x5B, 0x00, 0x21, 0x00, 0x5D, 0x00, 0x28, 0xD8, 0x00, 0x00, 0x29 };
    NSString *markupString = [[NSString alloc] initWithBytes:bytes length:12 encoding:NSUTF16BigEndianStringEncoding];
    NSString *expectedRawString = @"!";
    // we're only testing that it doesn't crash on some improperly handled `stringByAddingPercentEncodingWithAllowedCharacters:`
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testStandardH1 {
    UIFont *h1Font = self.standardParser.headerAttributes[0][NSFontAttributeName];
    UIFont *h1LenientFont = self.lenientParser.headerAttributes[0][NSFontAttributeName];
    XCTAssertEqualObjects(h1Font, h1LenientFont);
#if TARGET_OS_TV
    XCTAssertEqual(h1Font.pointSize, 76.f);
#else
    XCTAssertEqual(h1Font.pointSize, 23.f);
#endif
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n# I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h1Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n#I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h1Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardH1IsParsedCorrectly {
    UIFont *h1Font = self.standardParser.headerAttributes[0][NSFontAttributeName];
    
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"first line\n# header\nsecond line"];
    NSRange headerRange = [attributedString.string rangeOfString:@"header"];
    XCTAssertTrue(headerRange.location != NSNotFound);
    
    [attributedString enumerateAttributesInRange:headerRange options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attributes, __unused NSRange range, __unused BOOL *stop) {
        UIFont *font = attributes[NSFontAttributeName];
        XCTAssertNotNil(font);
        XCTAssertEqual(font, h1Font);
    }];
}

// '#header' is not a valid header per markdown syntax and shouldn't be parsed as one
- (void)testStandardHeaderIsNotParsedWithoutSpaceInBetween {
    NSString *notValidHeader = @"#header";
    UIFont *h1Font = self.standardParser.headerAttributes[0][NSFontAttributeName];
    
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:notValidHeader];
    NSRange headerRange = [attributedString.string rangeOfString:@"header"];
    [attributedString enumerateAttributesInRange:headerRange options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attributes, __unused NSRange range, __unused BOOL *stop) {
        UIFont *font = attributes[NSFontAttributeName];
        XCTAssertNotEqual(font, h1Font);
    }];
    XCTAssertEqualObjects(attributedString.string, notValidHeader);
}

- (void)testStandardHeaderIsNotParsedAtNotBeginningOfTheLine {
    NSString *hashtag = @"# hashtag";
    NSString *input = [NSString stringWithFormat:@"A sentence %@", hashtag];
    
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:input];
    XCTAssertEqualObjects(attributedString.string, input);
    NSRange hashTagStillThereRange = [attributedString.string rangeOfString:hashtag];
    XCTAssertTrue(hashTagStillThereRange.location != NSNotFound);
}

- (void)testLenientHeaderIsNotParsedAtNotBeginningOfTheLine {
    NSString *hashtag = @"#hashtag";
    NSString *input = [NSString stringWithFormat:@"A sentence %@", hashtag];
    
    NSAttributedString *attributedString = [self.lenientParser attributedStringFromMarkup:input];
    XCTAssertEqualObjects(attributedString.string, input);
    NSRange hashTagStillThereRange = [attributedString.string rangeOfString:hashtag];
    XCTAssertTrue(hashTagStillThereRange.location != NSNotFound);
}

- (void)testStandardH2 {
    UIFont *h2Font = self.standardParser.headerAttributes[1][NSFontAttributeName];
    UIFont *h2LenientFont = self.lenientParser.headerAttributes[1][NSFontAttributeName];
    XCTAssertNotNil(h2Font);
    XCTAssertEqualObjects(h2Font, h2LenientFont);
    
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n## I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h2Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n##I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h2Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardH3 {
    UIFont *h3Font = self.standardParser.headerAttributes[2][NSFontAttributeName];
#if TARGET_OS_TV
    XCTAssertEqual(h3Font.pointSize, 48.f);
#else
    XCTAssertEqual(h3Font.pointSize, 19.f);
#endif
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n### I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h3Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n###I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h3Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardH4 {
    UIFont *h4Font = self.standardParser.headerAttributes[3][NSFontAttributeName];
#if TARGET_OS_TV
    XCTAssertEqual(h4Font.pointSize, 40.f);
#else
    XCTAssertEqual(h4Font.pointSize, 17.f);
#endif
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n#### I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h4Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n####I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h4Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardH5 {
    UIFont *h5Font = self.standardParser.headerAttributes[4][NSFontAttributeName];
#if TARGET_OS_TV
    XCTAssertEqual(h5Font.pointSize, 36.f);
#else
    XCTAssertEqual(h5Font.pointSize, 15.f);
#endif
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n##### I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h5Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n#####I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h5Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardH6 {
    UIFont *h6Font = self.standardParser.headerAttributes[5][NSFontAttributeName];
#if TARGET_OS_TV
    XCTAssertEqual(h6Font.pointSize, 32.f);
#else
    XCTAssertEqual(h6Font.pointSize, 13.f);
#endif
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n###### I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h6Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"Hello\n######I drink in a café everyday\nto use Wi-Fi"];
    XCTAssertEqualObjects([attributedString attribute:NSFontAttributeName atIndex:10 effectiveRange:NULL], h6Font);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardH6NextLine {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n###### I drink in a café everyday\nto use Wi-Fi"];
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:37 effectiveRange:NULL];
    UIFont *expectedFont = [UIFont systemFontOfSize:defaultSize];
    XCTAssertNotNil(font);
    XCTAssertEqualObjects(font, expectedFont);
    XCTAssertEqual(font.pointSize, defaultSize);
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\nto use Wi-Fi");
}

- (void)testStandardMultipleMatches {
    NSAttributedString *attributedString;
    attributedString = [self.standardParser attributedStringFromMarkup:@"## Hello\nI drink in a *café* everyday\n+ to use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\n•\tto use Wi-Fi");
    attributedString = [self.lenientParser attributedStringFromMarkup:@"##Hello\nI drink in a *café* everyday\n+to use Wi-Fi"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\nI drink in a café everyday\n•\tto use Wi-Fi");
}

- (void)testStandardImage {
#if TARGET_OS_IPHONE
    UIImage *refImage = [UIImage imageNamed:@"markdown.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    XCTAssertNotNil(refImage);
#endif
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"We use ![café](markdown) everyday\neverywhere"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:7 effectiveRange:NULL];
    XCTAssertNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:7 effectiveRange:NULL];
    XCTAssertNotNil(attachment);
    XCTAssertNotNil(attachment.image);
    XCTAssertEqualObjects(attributedString.string, @"We use \uFFFC everyday\neverywhere");
}

- (void)testStandardImageEnclosedInParenthesis {
    NSString *markupString = @"This is (![café](markdown)) for home";
    NSString *expectedRawString = @"This is (\uFFFC) for home";
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:markupString];
    XCTAssertEqualObjects(attributedString.string, expectedRawString);
}

- (void)testStandardImageWithSpacesAndUnderscores {
#if TARGET_OS_IPHONE
    UIImage *refImage = [UIImage imageNamed:@"markdown_test_i m a g e.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    XCTAssertNotNil(refImage);
#endif
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"A ![AltText](markdown_test_i m a g e)"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:2 effectiveRange:NULL];
    XCTAssertNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:2 effectiveRange:NULL];
    XCTAssertNotNil(attachment);
    XCTAssertNotNil(attachment.image);
    XCTAssertEqualObjects(attributedString.string, @"A \uFFFC");
}

- (void)testStandardLinkWithImage {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"[a link ![with image](markdown)](https://example.com)"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
    XCTAssertNotNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:7 effectiveRange:NULL];
    XCTAssertNotNil(attachment);
    XCTAssertNotNil(attachment.image);
    XCTAssertEqualObjects(attributedString.string, @"a link \uFFFC");
}

// Accepting nested brackets is not possible with NSRegularExpression: https://stackoverflow.com/q/33096411/1033581
/*
- (void)testStandardImageWithBracketsInside {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"![an image [with brackets]](markdown)"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
    XCTAssertNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:NULL];
    XCTAssertNotNil(attachment);
    XCTAssertNotNil(attachment.image);
    XCTAssertEqualObjects(attributedString.string, @"\uFFFC");
}

- (void)testStandardLinkWithImageWithBracketsInside {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"[a link ![with image [with brackets]](markdown)](https://example.com)"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
    XCTAssertNotNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:7 effectiveRange:NULL];
    XCTAssertNotNil(attachment);
    XCTAssertNotNil(attachment.image);
    XCTAssertEqualObjects(attributedString.string, @"a link \uFFFC");
}
*/

- (void)testStandardImageMultiple {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"We use ![café](markdown) and ![café](markdown)\nalways"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:7 effectiveRange:NULL];
    XCTAssertNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:7 effectiveRange:NULL];
    XCTAssertNotNil(attachment);
    XCTAssertNotNil(attachment.image);
    XCTAssertEqualObjects(attributedString.string, @"We use \uFFFC and \uFFFC\nalways");
}

- (void)testStandardImageMissingImage {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"We use ![café](markdownas) everyday\neverywhere"];
    NSString *link = [attributedString attribute:NSLinkAttributeName atIndex:7 effectiveRange:NULL];
    XCTAssertNil(link);
    NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:7 effectiveRange:NULL];
    XCTAssertNil(attachment);
    XCTAssertEqualObjects(attributedString.string, @"We use café everyday\neverywhere");
}

- (void)testStandardBoldParsingCustomFont {
    UIFont *customFont = [UIFont boldSystemFontOfSize:19];
    self.standardParser.strongAttributes = @{ NSFontAttributeName: customFont };
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\nWe use **café** everyday"];
    XCTAssertEqual([[attributedString attribute:NSFontAttributeName atIndex:15 effectiveRange:NULL] pointSize], 19.f);
}

- (void)testStandardURLWithParenthesesInTheTitleText {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\n We use [café (Arabica)](https://www.example.net/) always."];
    NSURL *link = [attributedString attribute:NSLinkAttributeName atIndex:16 effectiveRange:NULL];
    XCTAssertEqualObjects(link, [NSURL URLWithString:@"https://www.example.net/"]);
    XCTAssertTrue([attributedString.string rangeOfString:@"café"].location != NSNotFound);
}

- (void)testStandardEscapeParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\\.\n"];
    XCTAssertEqualObjects(attributedString.string, @"Hello.\n");
}

- (void)testStandardCodeEscapeParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello`*.*`\n"];
    XCTAssertEqualObjects(attributedString.string, @"Hello*.*\n");
}

- (void)testStandardEscapingCodeEscapeParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello\\`*.*`\n"];
    XCTAssertEqualObjects(attributedString.string, @"Hello`.`\n");
}

- (void)testStandardCodeEscapingEscapeParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello`\\.`\n"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\\.\n");
}

- (void)testStandardMultilineCodeEscapeParsing {
    NSAttributedString *attributedString = [self.standardParser attributedStringFromMarkup:@"Hello``\n*.*\n``"];
    XCTAssertEqualObjects(attributedString.string, @"Hello\n*.*\n");
}

@end
