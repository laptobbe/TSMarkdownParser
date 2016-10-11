//
//  NSMutableAttributedString+TSTraits.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 09/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "NSMutableAttributedString+TSTraits.h"
#import "TSFontHelper.h"

@implementation NSMutableAttributedString (TSTraits)

- (void)ts_addTrait:(TSFontTraitMask)trait range:(NSRange)range
{
    if (!trait)
        return;
    [self enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary<NSString *, id> * _Nonnull attrs, NSRange range, __unused BOOL * _Nonnull stop) {
        UIFont *font = attrs[NSFontAttributeName];
        if (font)
            [self addAttribute:NSFontAttributeName value:[TSFontHelper convertFont:font toHaveTrait:trait] range:range];
    }];
}

- (void)ts_addAttributes:(NSArray<NSDictionary<NSString *, id> *> *)attributesArray
              atIndex:(NSUInteger)level
                range:(NSRange)range
{
    if (!attributesArray.count)
        return;
    NSDictionary<NSString *, id> *attributes = level < attributesArray.count ? attributesArray[level] : attributesArray.lastObject;
    [self addAttributes:attributes range:range];
}

- (void)ts_addTraits:(NSArray<NSNumber *> *)traitsArray
          atIndex:(NSUInteger)level
            range:(NSRange)range
{
    if (!traitsArray.count)
        return;
    NSNumber *traits = level < traitsArray.count ? traitsArray[level] : traitsArray.lastObject;
    [self ts_addTrait:traits.unsignedIntValue range:range];
}

@end
