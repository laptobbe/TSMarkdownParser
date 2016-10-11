//
//  TSMarkdownStandardParser.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 03/04/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSMarkdownStandardParser.h"
#import "NSMutableAttributedString+TSTraits.h"
#import "TSMarkupParser+FormatExamples.h"


@implementation TSMarkdownStandardParser

+ (instancetype)strictParser
{
    return [self new];
}

+ (instancetype)lenientParser
{
    return [[self alloc] initLenientParser];
}

#pragma mark - init

- (instancetype)init {
    return [self initStrictParser];
}

- (instancetype)initStrictParser {
    self = [super init];
    if (!self)
        return nil;
    [self setupAttributesAndTraits];
    [self setupStrictParsing:YES];
    return self;
}

- (instancetype)initLenientParser {
    self = [super init];
    if (!self)
        return nil;
    [self setupAttributesAndTraits];
    [self setupStrictParsing:NO];
    return self;
}

- (void)setupAttributesAndTraits {
#if TARGET_OS_TV
    NSUInteger defaultSize = 29;
#else
    NSUInteger defaultSize = 12;
#endif
    
    self.defaultAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:defaultSize] };
    
#if TARGET_OS_TV
    _headerAttributes = @[ @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:76] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:57] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:48] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:40] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:36] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:32] } ];
#else
    _headerAttributes = @[ @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:23] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:21] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:19] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:17] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:15] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } ];
#endif
    
    _listAttributes = @[];
    _quoteAttributes = @[@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:defaultSize]}];
    
    _imageAttributes = @{};
    _linkAttributes = @{ NSForegroundColorAttributeName: [UIColor blueColor],
                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
    
    // Courier New and Courier are the only monospace fonts compatible with watchOS 2
    _monospaceAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Courier New" size:defaultSize],
                              NSForegroundColorAttributeName: [UIColor colorWithRed:0.95 green:0.54 blue:0.55 alpha:1] };
    _strongTraits = (TSFontTraitMask)TSFontMaskBold;
    _emphasisTraits = (TSFontTraitMask)TSFontMaskItalic;
}

- (void)setupStrictParsing:(BOOL)strictParsing {
    // weak reference for blocks
    __weak typeof(self) weakSelf = self;
    
    NSString *separator = strictParsing ? @" " : @"";
    
    /* escaping parsing */
    
    [self addCodeEscapingParsing];
    
    [self addEscapingParsing];
    
    /* block parsing */
    
    [self addHeaderParsingWithMaxLevel:6 separator:separator leadFormattingBlock:nil textFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        if (weakSelf.headerAttributes)
            [attributedString ts_addAttributes:weakSelf.headerAttributes atIndex:level - 1 range:range];
        [attributedString ts_addTraits:weakSelf.headerTraits atIndex:level - 1 range:range];
    }];
    
    [self addListParsingWithMaxLevel:0 separator:separator leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        NSMutableString *listString = [NSMutableString string];
        while (--level)
            [listString appendString:@"\t"];
        [listString appendString:@"•\t"];
        [attributedString replaceCharactersInRange:range withString:listString];
    } textFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        if (weakSelf.listAttributes)
            [attributedString ts_addAttributes:weakSelf.listAttributes atIndex:level - 1 range:range];
        [attributedString ts_addTraits:weakSelf.listTraits atIndex:level - 1 range:range];
    }];
    
    [self addQuoteParsingWithMaxLevel:0 separator:separator leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        NSMutableString *quoteString = [NSMutableString string];
        while (level--)
            [quoteString appendString:@"\t"];
        [attributedString replaceCharactersInRange:range withString:quoteString];
    } textFormattingBlock:^(NSMutableAttributedString * attributedString, NSRange range, NSUInteger level) {
        if (weakSelf.quoteAttributes)
            [attributedString ts_addAttributes:weakSelf.quoteAttributes atIndex:level - 1 range:range];
        [attributedString ts_addTraits:weakSelf.quoteTraits atIndex:level - 1 range:range];
    }];
    
    /* bracket parsing */
    
    [self addImageParsingWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * link) {
        
#if !TARGET_OS_WATCH
        UIImage *image;
        NSBundle *resourceBundle = self.resourceBundle;
#if !TARGET_OS_IPHONE
        if (resourceBundle) {
            image = [resourceBundle imageForResource:link];
        } else
#elif __has_include(<UIKit/UITraitCollection.h>)
        if (resourceBundle && [UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
            image = [UIImage imageNamed:link inBundle:resourceBundle compatibleWithTraitCollection:nil];
        } else
#endif
        {
            image = [UIImage imageNamed:link];
        }
        if (image) {
            NSTextAttachment *imageAttachment = [NSTextAttachment new];
            imageAttachment.image = image;
            imageAttachment.bounds = CGRectMake(0, -5, image.size.width, image.size.height);
            NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:imageAttachment];
            [attributedString replaceCharactersInRange:range withAttributedString:imgStr];
        } else
#endif
        {
            if (!weakSelf.skipLinkAttribute) {
                NSURL *url = [NSURL URLWithString:link] ?: [NSURL URLWithString:
                                                            [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                if (url.scheme) {
                    [attributedString addAttribute:NSLinkAttributeName
                                             value:url
                                             range:range];
                }
            }
            if (weakSelf.imageAttributes)
                [attributedString addAttributes:weakSelf.imageAttributes range:range];
            [attributedString ts_addTrait:weakSelf.imageTraits range:range];
        }
    }];
    
    [self addLinkParsingWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * link) {
        if (!weakSelf.skipLinkAttribute) {
            NSURL *url = [NSURL URLWithString:link] ?: [NSURL URLWithString:
                                                        [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if (url) {
                [attributedString addAttribute:NSLinkAttributeName
                                         value:url
                                         range:range];
            }
        }
        if (weakSelf.linkAttributes)
            [attributedString addAttributes:weakSelf.linkAttributes range:range];
        [attributedString ts_addTrait:weakSelf.linkTraits range:range];
    }];
    
    /* autodetection */
    
    [self addLinkDetectionWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * link) {
        if (!weakSelf.skipLinkAttribute) {
            [attributedString addAttribute:NSLinkAttributeName
                                     value:[NSURL URLWithString:link]
                                     range:range];
        }
        if (weakSelf.linkAttributes)
            [attributedString addAttributes:weakSelf.linkAttributes range:range];
        [attributedString ts_addTrait:weakSelf.linkTraits range:range];
    }];
    
    /* inline parsing */
    
    [self addStrongParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        if (weakSelf.strongAttributes)
            [attributedString addAttributes:weakSelf.strongAttributes range:range];
        [attributedString ts_addTrait:weakSelf.strongTraits range:range];
    }];
    
    [self addEmphasisParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        if (weakSelf.emphasisAttributes)
            [attributedString addAttributes:weakSelf.emphasisAttributes range:range];
        [attributedString ts_addTrait:weakSelf.emphasisTraits range:range];
    }];
    
    /* unescaping parsing */
    
    [self addCodeUnescapingParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        if (weakSelf.monospaceAttributes)
            [attributedString addAttributes:weakSelf.monospaceAttributes range:range];
        [attributedString ts_addTrait:weakSelf.monospaceTraits range:range];
    }];
    
    [self addUnescapingParsing];
}

@end
