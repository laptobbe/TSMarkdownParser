//
//  NSMutableAttributedString+TSTraits.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 09/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

@import Foundation;
#import "TSFoundation.h"
#import "TSFontTraitMask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (TSTraits)

- (void)ts_addTrait:(TSFontTraitMask)trait range:(NSRange)range;

- (void)ts_addAttributes:(nullable NSArray<NSDictionary<NSAttributedStringKey, id> *> *)attributesArray
                 atIndex:(NSUInteger)level
                   range:(NSRange)range;

- (void)ts_addTraits:(nullable NSArray<NSNumber *> *)traitsArray
             atIndex:(NSUInteger)level
               range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
