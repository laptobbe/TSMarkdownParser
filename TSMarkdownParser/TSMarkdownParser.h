//
//  TSMarkdownParser.h
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif
#import "TSBaseParser.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSMarkdownParserFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range);
typedef void (^TSMarkdownParserLevelFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level);

@interface TSMarkdownParser : TSBaseParser

/*
 Properties used by standardParser.
 */
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *headerAttributes;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *listAttributes;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *quoteAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *imageAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *linkAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *monospaceAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *strongAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *emphasisAttributes;

/*
 Provides the following default parsing rules from below examples:
 * Escaping parsing
 * Code escaping parsing using monospaceAttributes
 * Header using headerAttributes
 * List using listAttributes
 * Quote using quoteAttributes
 * Image using imageAttributes
 * Link using linkAttributes
 * LinkDetection using linkAttributes
 * Strong using strongAttributes
 * Emphasis using emphasisAttributes
 */
+ (instancetype)standardParser;

/*
 It is recommended to use `[TSMarkdownParser new]` for an empty markdown parser.
 If you reuse some examples below, it is adviced to use them in the given order.
 */

/* 1. examples escaping parsing */

// accepts "\."; ALWAYS use together with `addUnescapingParsing`
- (void)addEscapingParsing;
// accepts "`code`", "``code``", ...; ALWAYS use together with `addCodeUnescapingParsingWithFormattingBlock:`
- (void)addCodeEscapingParsing;

/* 2. examples regular block parsing: headers, lists and quotes */

// accepts "# text", "## text", ...
- (void)addHeaderParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;
// accepts "* text", "+ text", "- text", "** text", "++ text", "-- text", ...
- (void)addListParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;
// accepts "> text", ">> text", ...
- (void)addQuoteParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;

/* 3. examples short block parsing: headers and lists */
/* they are discouraged and not used by standardParser */

// accepts "#text", "##text", ...
// (conflicts with inline parsing)
- (void)addShortHeaderParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;
// accepts "*text", "+text", "-text", "** text", "++ text", "-- text", ...
// (conflicts with inline parsing)
- (void)addShortListParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;
// accepts ">text", ">>text", ...
// (conflicts with inline parsing)
- (void)addShortQuoteParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;

/* 4. examples inline bracket parsing: images and links */
/* text accepts newlines and non-bracket parsing */

// accepts "![text](image)"
- (void)addImageParsingWithImageFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock alternativeTextFormattingBlock:(TSMarkdownParserFormattingBlock)alternativeFormattingBlock;
// accepts "[text](link)"
- (void)addLinkParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

/* 5. example autodetection parsing: links */

// adds links autodetection support to parser
- (void)addLinkDetectionWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

/* 6. examples inline parsing: monospaced, strong, emphasis and link detection */
/* text accepts newlines */

// accepts "`text`", "``text``", ... (conflicts with `addCodeEscapingParsing`)
- (void)addMonospacedParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
// accepts "**text**", "__text__"
- (void)addStrongParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
// accepts "*text*", "_text_"
- (void)addEmphasisParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

/* 7. examples unescaping parsing */
/* to use together with `addEscapingParsing` or `addCodeEscapingParsing` */

// accepts "\hexa"; to use with `addEscapingParsing`
- (void)addUnescapingParsing;
// accepts "`hexa`", "``hexa``", ...; to use with `addCodeEscapingParsing`
- (void)addCodeUnescapingParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

@end

NS_ASSUME_NONNULL_END
