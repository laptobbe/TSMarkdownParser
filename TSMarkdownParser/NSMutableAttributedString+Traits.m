//
//  NSMutableAttributedString+Traits.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 09/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "NSMutableAttributedString+Traits.h"
#import "TSHelper.h"

@implementation NSMutableAttributedString (Traits)

- (void)addTrait:(TSFontTraitMask)trait range:(NSRange)range
{
    if (!trait)
        return;
    [self enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary<NSString *, id> * _Nonnull attrs, NSRange range, __unused BOOL * _Nonnull stop) {
        UIFont *font = attrs[NSFontAttributeName];
        if (font)
            [self addAttribute:NSFontAttributeName value:[TSHelper convertFont:font toHaveTrait:trait] range:range];
    }];
}

- (void)addAttributes:(NSArray<NSDictionary<NSString *, id> *> *)attributesArray
              atIndex:(NSUInteger)level
                range:(NSRange)range
{
    if (!attributesArray.count)
        return;
    NSDictionary<NSString *, id> *attributes = level < attributesArray.count ? attributesArray[level] : attributesArray.lastObject;
    [self addAttributes:attributes range:range];
}

- (void)addTraits:(NSArray<NSNumber *> *)traitsArray
          atIndex:(NSUInteger)level
            range:(NSRange)range
{
    if (!traitsArray.count)
        return;
    NSNumber *traits = level < traitsArray.count ? traitsArray[level] : traitsArray.lastObject;
    [self addTrait:traits.unsignedIntValue range:range];
}

@end
