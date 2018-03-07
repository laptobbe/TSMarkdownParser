//
//  TSBaseParser.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 24/01/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

@import Foundation;
#import "TSFoundation.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSBaseParserMatchBlock)(NSTextCheckingResult *match, NSMutableAttributedString *attributedString);

/**
 * Basic class for parsing.
 *
 * It is discouraged to subclass directly from TSBaseParser. Subclass TSMarkupParser instead.
 */
@interface TSBaseParser : NSObject

/**
 Default attributes for `attributedStringFromMarkup:`.
 */
@property (nonatomic, strong, nullable) NSDictionary<NSAttributedStringKey, id> *defaultAttributes;

/// Applies defaultAttributes then applies markup
- (NSAttributedString *)attributedStringFromMarkup:(NSString *)markup;

/// Applies attributes then applies markup
- (NSAttributedString *)attributedStringFromMarkup:(NSString *)markup attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

/// Applies markup
- (NSAttributedString *)attributedStringFromAttributedMarkupString:(NSAttributedString *)attributedString;

/// Adds a custom parsing rule to parser. Use `[TSMarkupParser new]` for an empty parser.
- (void)addParsingRuleWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSBaseParserMatchBlock)block;

@end

NS_ASSUME_NONNULL_END
