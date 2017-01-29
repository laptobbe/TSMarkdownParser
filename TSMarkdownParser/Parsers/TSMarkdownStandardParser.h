//
//  TSMarkdownStandardParser.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 03/04/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSMarkupParser.h"

NS_ASSUME_NONNULL_BEGIN

/**
 StandardParser is inspired by [Daring Fireball](http://daringfireball.net/projects/markdown/syntax).
 Provides the following default parsing rules:
 * Escaping parsing
 * Code escaping parsing using monospaceAttributes/monospaceTraits
 * Header using headerAttributes/headerTraits
 * List using listAttributes/listTraits
 * Quote using quoteAttributes/quoteTraits
 * Image using imageAttributes/imageTraits
 * Link using linkAttributes/linkTraits
 * LinkDetection using linkAttributes/linkTraits
 * Strong using strongAttributes/strongTraits
 * Emphasis using emphasisAttributes/emphasisTraits
 */
@interface TSMarkdownStandardParser : TSMarkupParser

/**
 * strict parsing is the default and requires a space after a lead markup like header/list/quote.
 */
+ (instancetype)strictParser;
/**
 * lenient parsing does not require a space after a lead markup like header/list/quote.
 */
+ (instancetype)lenientParser;

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *headerAttributes;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *listAttributes;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *quoteAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *imageAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *linkAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *monospaceAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *strongAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *emphasisAttributes;

// NSFontAttributeName and symbolic traits are mutually exclusive, avoid using both

@property (nonatomic, strong) NSArray<NSNumber *> *headerTraits;
@property (nonatomic, strong) NSArray<NSNumber *> *listTraits;
@property (nonatomic, strong) NSArray<NSNumber *> *quoteTraits;
@property (nonatomic, assign) TSFontTraitMask imageTraits;
@property (nonatomic, assign) TSFontTraitMask linkTraits;
@property (nonatomic, assign) TSFontTraitMask monospaceTraits;
@property (nonatomic, assign) TSFontTraitMask strongTraits;
@property (nonatomic, assign) TSFontTraitMask emphasisTraits;

@end

NS_ASSUME_NONNULL_END
