//
//  NSMutableAttributedString+TSTraits.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 09/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "NSMutableAttributedString+TSTraits.h"
#import "TSHelper.h"

@implementation NSMutableAttributedString (TSTraits)

- (void)ts_addTrait:(TSFontTraitMask)trait range:(NSRange)range
{
    if (!trait)
        return;
    [self enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary<NSAttributedStringKey, id> * _Nonnull attrs, NSRange range, __unused BOOL * _Nonnull stop) {
        // 'objectForKeyedSubscript:' is only available on macOS 10.8 or newer
        UIFont *font = [attrs objectForKey:NSFontAttributeName];
        if (font)
            [self addAttribute:NSFontAttributeName value:[TSHelper convertFont:font toHaveTrait:trait] range:range];
    }];
}

- (void)ts_addAttributes:(NSArray<NSDictionary<NSAttributedStringKey, id> *> *)attributesArray
              atIndex:(NSUInteger)level
                range:(NSRange)range
{
    if (!attributesArray.count)
        return;
    // 'objectAtIndexedSubscript:' is only available on macOS 10.8 or newer
    NSDictionary<NSAttributedStringKey, id> *attributes = level < attributesArray.count ? [attributesArray objectAtIndex:level] : attributesArray.lastObject;
    [self addAttributes:attributes range:range];
}

- (void)ts_addTraits:(NSArray<NSNumber *> *)traitsArray
          atIndex:(NSUInteger)level
            range:(NSRange)range
{
    if (!traitsArray.count)
        return;
    // 'objectAtIndexedSubscript:' is only available on macOS 10.8 or newer
    NSNumber *traits = level < traitsArray.count ? [traitsArray objectAtIndex:level] : traitsArray.lastObject;
    [self ts_addTrait:traits.unsignedIntValue range:range];
}

@end
