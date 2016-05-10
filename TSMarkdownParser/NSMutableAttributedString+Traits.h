//
//  NSMutableAttributedString+Traits.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 09/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

@import Foundation;
#import "TSFontTraitMask.h"

@interface NSMutableAttributedString (Traits)

- (void)addTrait:(TSFontTraitMask)trait range:(NSRange)range;

- (void)addAttributes:(NSArray<NSDictionary<NSString *, id> *> *)attributesArray
              atIndex:(NSUInteger)level
                range:(NSRange)range;

- (void)addTraits:(NSArray<NSNumber *> *)traitsArray
          atIndex:(NSUInteger)level
            range:(NSRange)range;

@end
