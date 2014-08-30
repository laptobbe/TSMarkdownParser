//
//  TSMarkdownParser.h
//  TSMarkdownParser
//
//  Created by Tobias Sundstrand on 14-08-30.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TSMarkdownParserBlock)(NSTextCheckingResult *match, NSMutableAttributedString *attributedString);

@interface TSMarkdownParser : NSObject

@property (nonatomic, strong) UIFont *paragraphFont;
@property (nonatomic, strong) UIFont *boldFont;
@property (nonatomic, strong) UIFont *italicFont;
@property (nonatomic, strong) UIFont *h1Font;
@property (nonatomic, strong) UIFont *h2Font;

+ (TSMarkdownParser *)defaultParser;

- (void)addParsingRuleWithRegularExpression:(NSRegularExpression *)regularExpression withBlock:(TSMarkdownParserBlock)block;

- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown;

- (void)addStrongParsing;

- (void)addEmParsing;

- (void)addListParsing;

- (void)addLinkParsing;

- (void)addH1Parsing;

- (void)addH2Parsing;
@end
