//
//  TSMarkdownParser.h
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TSMarkdownParserMatchBlock)(NSTextCheckingResult *match, NSMutableAttributedString *attributedString);
typedef void (^TSMarkdownParserFormattingBlock)(NSMutableAttributedString *attributedString, NSRange range);

@interface TSMarkdownParser : NSObject

@property (nonatomic, strong) UIFont *paragraphFont;
@property (nonatomic, strong) UIFont *strongFont;
@property (nonatomic, strong) UIFont *emphasisFont;
@property (nonatomic, strong) UIFont *h1Font;
@property (nonatomic, strong) UIFont *h2Font;
@property (nonatomic, strong) UIFont *h3Font;
@property (nonatomic, strong) UIFont *h4Font;
@property (nonatomic, strong) UIFont *h5Font;
@property (nonatomic, strong) UIFont *h6Font;
@property (nonatomic, strong) UIFont *monospaceFont;
@property (nonatomic, strong) UIColor *monospaceTextColor;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, copy) NSNumber *linkUnderlineStyle;

+ (instancetype)standardParser;

- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown;

- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown attributes:(NSDictionary *)attributes;

- (NSAttributedString *)attributedStringFromAttributedMarkdownString:(NSAttributedString *)attributedString;

- (void)addParsingRuleWithRegularExpression:(NSRegularExpression *)regularExpression withBlock:(TSMarkdownParserMatchBlock)block;

- (void)addEscapingParsing;

- (void)addParagraphParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

- (void)addStrongParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

- (void)addEmphasisParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

- (void)addListParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

- (void)addLinkParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

- (void)addHeaderParsingWithLevel:(int)header formattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

- (void)addMonospacedParsingWithFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock;

- (void)addImageParsingWithImageFormattingBlock:(TSMarkdownParserFormattingBlock)formattingBlock alternativeTextFormattingBlock:(TSMarkdownParserFormattingBlock)alternativeFormattingBlock;

@end
