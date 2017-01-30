//
//  TSBaseParser.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 24/01/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSBaseParser.h"


@interface TSExpressionBlockPair : NSObject

@property (nonatomic, strong) NSRegularExpression *regularExpression;
@property (nonatomic, strong) TSBaseParserMatchBlock block;

+ (TSExpressionBlockPair *)pairWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSBaseParserMatchBlock)block;

@end


@implementation TSExpressionBlockPair

+ (TSExpressionBlockPair *)pairWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSBaseParserMatchBlock)block {
    TSExpressionBlockPair *pair = [TSExpressionBlockPair new];
    pair.regularExpression = regularExpression;
    pair.block = block;
    return pair;
}

@end


@interface TSBaseParser ()

@property (nonatomic, strong) NSMutableArray *parsingPairs;

@end


@implementation TSBaseParser

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;
    
    _parsingPairs = [NSMutableArray array];
    
    return self;
}

#pragma mark - parser definition

- (void)addParsingRuleWithRegularExpression:(NSRegularExpression *)regularExpression block:(TSBaseParserMatchBlock)block {
    @synchronized (self) {
        [self.parsingPairs addObject:[TSExpressionBlockPair pairWithRegularExpression:regularExpression block:block]];
    }
}

#pragma mark parser evaluation

- (NSAttributedString *)attributedStringFromMarkup:(NSString *)markup {
    return [self attributedStringFromMarkup:markup attributes:self.defaultAttributes];
}

- (NSAttributedString *)attributedStringFromMarkup:(NSString *)markup attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    NSAttributedString *attributedString;
    if (!attributes) {
        attributedString = [[NSAttributedString alloc] initWithString:markup];
    } else {
        attributedString = [[NSAttributedString alloc] initWithString:markup attributes:attributes];
    }
    
    return [self attributedStringFromAttributedMarkupString:attributedString];
}

- (NSAttributedString *)attributedStringFromAttributedMarkupString:(NSAttributedString *)attributedString {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    // TODO: evaluate performances of `beginEditing`/`endEditing`
    //[mutableAttributedString beginEditing];
    @synchronized (self) {
        for (TSExpressionBlockPair *expressionBlockPair in self.parsingPairs) {
            NSTextCheckingResult *match;
            NSUInteger location = 0;
            while ((match = [expressionBlockPair.regularExpression firstMatchInString:mutableAttributedString.string options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(location, mutableAttributedString.length - location)])){
                NSUInteger oldLength = mutableAttributedString.length;
                expressionBlockPair.block(match, mutableAttributedString);
                NSUInteger newLength = mutableAttributedString.length;
                location = match.range.location + match.range.length + newLength - oldLength;
            }
        }
    }
    //[mutableAttributedString endEditing];
    return mutableAttributedString;
}

@end
