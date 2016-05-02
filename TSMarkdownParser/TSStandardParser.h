//
//  TSStandardParser.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 03/04/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSMarkdownParser.h"

NS_ASSUME_NONNULL_BEGIN

/*
 Provides the following default parsing rules from below examples:
 * Escaping parsing
 * Code escaping parsing using monospaceAttributes
 * Header using headerAttributes
 * List using listAttributes
 * Quote using quoteAttributes
 * Image using imageAttributes
 * Link using linkAttributes
 * LinkDetection using linkAttributes
 * Strong using strongAttributes
 * Emphasis using emphasisAttributes
 */
@interface TSStandardParser : TSMarkdownParser

/*
 Properties used by standardParser.
 */
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *headerAttributes;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *listAttributes;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *quoteAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *imageAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *linkAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *monospaceAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *strongAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *emphasisAttributes;

@end

NS_ASSUME_NONNULL_END
