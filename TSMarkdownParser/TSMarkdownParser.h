//
//  TSMarkdownParser.h
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseParser.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSMarkdownParserFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range);

@interface TSMarkdownParser : TSBaseParser

/*
 Properties used by standardParser.
 */
@property (nonatomic, strong) UIFont *h1Font;
@property (nonatomic, strong) UIFont *h2Font;
@property (nonatomic, strong) UIFont *h3Font;
@property (nonatomic, strong) UIFont *h4Font;
@property (nonatomic, strong) UIFont *h5Font;
@property (nonatomic, strong) UIFont *h6Font;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, strong) NSNumber *linkUnderlineStyle;// NSUnderlineStyle
@property (nonatomic, strong) UIFont *monospaceFont;
@property (nonatomic, strong) UIColor *monospaceTextColor;
@property (nonatomic, strong) UIFont *strongFont;
@property (nonatomic, strong) UIFont *emphasisFont;

/*
 Provides the following default parsing rules from below examples:
 * Header using h1Font, h2Font, h3Font, h4Font, h5Font, h6Font
 * List
 * Image
 * Link using linkColor, linkUnderlineStyle
 * Monospaced using monospaceFont, monospaceTextColor
 * Strong using strongFont
 * Emphasis using emphasisFont
 * default escapingSupport YES
 * default linkDetection YES
 You can use `[TSMarkdownParser new]` for an empty markdown parser.
 */
+ (instancetype)standardParser;

/* examples block parsing: headers and lists */

// accepts "# text", "## text", ...
- (void)addHeaderParsingWithLevel:(int)header formattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
// accepts "#text", "##text", ... (conflicts with inline parsing)
- (void)addShortHeaderParsingWithLevel:(int)header formattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
// accepts "* text", "+ text", "- text"
- (void)addListParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
// accepts "*text", "+text", "-text" (conflicts with inline parsing)
- (void)addShortListParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

/* examples bracket parsing: images and links */

// accepts "![text](image)"
- (void)addImageParsingWithImageFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock alternativeTextFormattingBlock:(TSMarkdownParserFormattingBlock)alternativeFormattingBlock;
// accepts "[text](link)"
- (void)addLinkParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

/* examples inline parsing: monospaced, strong and emphasis */

// accepts "`text`"
- (void)addMonospacedParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
// accepts "**text**", "__text__"
- (void)addStrongParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;
// accepts "*text*", "_text_"
- (void)addEmphasisParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

@end

NS_ASSUME_NONNULL_END
