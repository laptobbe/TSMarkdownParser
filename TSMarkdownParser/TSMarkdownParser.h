//
//  TSMarkdownParser.h
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSBaseParser.h"
#import "TSFontTraitMask.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSMarkdownParserFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range);
typedef void (^TSMarkdownParserLevelFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level);
typedef void (^TSMarkdownParserLinkFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range,  NSString * _Nullable link);

/**
 * Recommended starting class for creating your own parser.
 *
 * Subclasses generally have Attributes and Traits properties
 */
@interface TSMarkdownParser : TSBaseParser

/**
 * markdownParser setting for NSLinkAttributeName
 *
 * When YES, references to URL are lost and you have freedom to customize the appearance of text.
 *
 * When NO, reference to URL are kept with NSLinkAttributeName and restrictions to customize the appearance of links apply:
 *
 * * UILabel is forcing all links to be displayed blue and underline, links aren't clickable
 *
 * * UITextView's tintColor property is controlling all links color, links are clickable
 *
 * * NSTextView's linkTextAttributes property is controlling all links attributes
 *
 * If you want clickable links with an UILabel subclass, you should leave skipLinkAttribute to NO and consider using KILabel, TTTAttributedLabel, FRHyperLabel, ... As a bonus, all will lift off the UILabel appearance restrictions for links.
 */
@property (nonatomic, assign) BOOL skipLinkAttribute;

/*
 It is recommended to use `[TSMarkdownParser new]` for an empty markdown parser.
 If you reuse some examples below, it is adviced to use them in the given order.
 */

/* 1. examples escaping parsing */

/// accepts "`code`", "``code``", ...; ALWAYS use together with `addCodeUnescapingParsingWithFormattingBlock:`
- (void)addCodeEscapingParsing;
/// accepts "\."; ALWAYS use together with `addUnescapingParsing`
- (void)addEscapingParsing;

/* 2. examples regular block parsing: headers, lists and quotes */

/// accepts "# text", "## text", ...
- (void)addHeaderParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;
/// accepts "* text", "+ text", "- text", "** text", "++ text", "-- text", ...
- (void)addListParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;
/// accepts "> text", ">> text", ...
- (void)addQuoteParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;

/* 3. examples short block parsing: headers and lists */
/* they are discouraged and not used by standardParser */

/// accepts "#text", "##text", ...
/// (conflicts with inline parsing)
- (void)addShortHeaderParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;
/// accepts "*text", "+text", "-text", "** text", "++ text", "-- text", ...
/// (conflicts with inline parsing)
- (void)addShortListParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;
/// accepts ">text", ">>text", ...
/// (conflicts with inline parsing)
- (void)addShortQuoteParsingWithMaxLevel:(unsigned int)maxLevel leadFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)leadFormattingBlock textFormattingBlock:(nullable TSMarkdownParserLevelFormattingBlock)formattingBlock;

/* 4. examples inline bracket parsing: images and links */
/* text accepts newlines and non-bracket parsing */

/// accepts "![text](image)"
/// @note    you can use formattingBlock to asynchronously download an image from link and replace range with an NSTextAttachment. Be careful of the range when the attributedString is altered.
- (void)addImageParsingWithLinkFormattingBlock:(TSMarkdownParserLinkFormattingBlock)formattingBlock;
/// accepts "[text](link)"
/// @note    you can use formattingBlock to add NSLinkAttributeName
- (void)addLinkParsingWithLinkFormattingBlock:(TSMarkdownParserLinkFormattingBlock)formattingBlock;

/* 5. example autodetection parsing: links */

/// adds links autodetection support to parser
/// @note    you can use formattingBlock to add NSLinkAttributeName
- (void)addLinkDetectionWithLinkFormattingBlock:(TSMarkdownParserLinkFormattingBlock)formattingBlock;

/* 6. examples inline parsing: monospaced, strong, emphasis and link detection */
/* text accepts newlines */

/// accepts "`text`", "``text``", ...
/// (conflicts with `addCodeEscapingParsing`)
- (void)addMonospacedParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
/// accepts "**text**", "__text__"
- (void)addStrongParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
/// accepts "*text*", "_text_"
- (void)addEmphasisParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

/* 7. examples unescaping parsing */
/* to use together with `addEscapingParsing` or `addCodeEscapingParsing` */

/// accepts "`hexa`", "``hexa``", ...; to use with `addCodeEscapingParsing`
- (void)addCodeUnescapingParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
/// accepts "\hexa"; to use with `addEscapingParsing`
- (void)addUnescapingParsing;

@end

NS_ASSUME_NONNULL_END
