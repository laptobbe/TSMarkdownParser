//
//  TSBaseParser.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 24/01/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSMarkdownParserMatchBlock)(NSTextCheckingResult *match, NSMutableAttributedString *attributedString);

@interface TSBaseParser : NSObject

/**
 Default attributes for `attributedStringFromMarkdown:`.
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *defaultAttributes;

/// Applies defaultAttributes then markdown
- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown;

/// Applies attributes then markdown
- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/// Applies markdown
- (NSAttributedString *)attributedStringFromAttributedMarkdownString:(NSAttributedString *)attributedString;

/// Adds a custom parsing rule to parser. Use `[TSMarkdownParser new]` for an empty parser.
- (void)addParsingRuleWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSMarkdownParserMatchBlock)block;

@end

NS_ASSUME_NONNULL_END
