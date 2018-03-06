//
//  TSMarkupParser.h
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSFoundation.h"
#import "TSBaseParser.h"
#import "TSFontTraitMask.h"

NS_ASSUME_NONNULL_BEGIN

/// @param    range is the part of the string enclosed by the markup
typedef void (^TSSimpleFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range);

/// @param    range depends on context
/// @param    markupLength is the part of the markup that is relevant to interpret it
typedef void (^TSMarkupLengthFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range, NSUInteger markupLength);

/// @param    range depends on context
/// @param    markupString is the part of the markup that is relevant to interpret it
typedef void (^TSMarkupStringFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range, NSString *markupString);

/// @param    matchRange is the part of the string enclosed by the markup
/// @param    markupRange is the part of the markup that is relevant to interpret it
/// @param    fullRange is the full markup, eventual separators and the enclosed text
typedef void (^TSFullFormattingBlock)(NSMutableAttributedString *attributedString, NSRange matchRange, NSRange markupRange, NSRange fullRange);

/**
 * Recommended starting class for creating your own parser.
 *
 * Subclasses generally have Attributes and Traits properties
 */
@interface TSMarkupParser : TSBaseParser

/**
 * markupParser setting for NSLinkAttributeName
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

/**
 * bundle for markup resources
 * 
 * for iOS8+ only
 * default is mainBundle
 */
@property (nonatomic, strong) NSBundle *resourceBundle NS_AVAILABLE(10_7, 8_0);

/*
 It is recommended to use `[TSMarkupParser new]` for an empty markup parser.
 If you reuse some examples below, it is adviced to use them in the given order.
 */

/* 1. examples escaping parsing */

/// accepts "`code`", "``code``", ...; ALWAYS use together with `addCodeUnescapingParsingWithFormattingBlock:`
- (void)addCodeEscapingParsing;

/// accepts "\."; ALWAYS use together with `addUnescapingParsing`
- (void)addEscapingParsing;

/* 2. generic lead parsing */

/// pattern matching should be two parts: (leadingMarkup)separators(string)
- (void)addLeadParsingWithPattern:(NSString *)markupPattern
                  formattingBlock:(TSFullFormattingBlock)formattingBlock;

/// convenient parsing based on LeadParsing
- (void)addStartLineParsingWithSymbols:(NSString *)symbolPattern
                              maxLevel:(unsigned int)maxLevel
                            separators:(NSString *)separatorPattern
                       formattingBlock:(TSFullFormattingBlock)formattingBlock;

/* 2. generic trail parsing */

/// pattern matching should be two parts: (string)separators(trailingMarkup)
- (void)addTrailParsingWithPattern:(NSString *)markupPattern
                   formattingBlock:(TSFullFormattingBlock)formattingBlock;

/// convenient parsing based on TrailParsing
- (void)addSubLineParsingWithSymbols:(NSString *)symbolPattern
                            minLevel:(unsigned int)minLevel
                     formattingBlock:(TSFullFormattingBlock)formattingBlock;

/* 4. examples inline bracket parsing: images and links */
/* text accepts newlines and non-bracket parsing */

/// accepts "![text](image)"
/// @note    you can use formattingBlock to asynchronously download an image from link and replace range with an NSTextAttachment. Be careful of the range when the attributedString is altered.
- (void)addImageParsingWithLinkFormattingBlock:(TSMarkupStringFormattingBlock)formattingBlock;

/// accepts "[text](link)"
/// @note    you can use formattingBlock to add NSLinkAttributeName
- (void)addLinkParsingWithLinkFormattingBlock:(TSMarkupStringFormattingBlock)formattingBlock;

/* 5. example autodetection parsing: links */

/// adds links autodetection support to parser
/// @note    you can use formattingBlock to add NSLinkAttributeName
- (void)addLinkDetectionWithLinkFormattingBlock:(TSMarkupStringFormattingBlock)formattingBlock;

/* 6. generic inline parsing */
/* text accepts newlines */

- (void)addEnclosedParsingWithSymbol:(NSString *)symbol formattingBlock:(TSSimpleFormattingBlock)formattingBlock;

- (void)addVariableEnclosedParsingWithSymbol:(NSString *)symbol formattingBlock:(TSSimpleFormattingBlock)formattingBlock;

// pattern matching should be three parts: (leadingMarkup)(string)(trailingMarkup)
- (void)addEnclosedParsingWithPattern:(NSString *)pattern formattingBlock:(TSSimpleFormattingBlock)formattingBlock;

/* 7. examples unescaping parsing */
/* to use together with `addEscapingParsing` or `addCodeEscapingParsing` */

/// accepts "`hexa`", "``hexa``", ...; to use with `addCodeEscapingParsing`
- (void)addCodeUnescapingParsingWithFormattingBlock:(TSSimpleFormattingBlock)formattingBlock;

/// accepts "\hexa"; to use with `addEscapingParsing`
- (void)addUnescapingParsing;

@end

NS_ASSUME_NONNULL_END
