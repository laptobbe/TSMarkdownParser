//
//  TSMarkdownStandardParser.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 03/04/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSMarkdownStandardParser.h"
#import "NSMutableAttributedString+Traits.h"


@implementation TSMarkdownStandardParser

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;
    
    self.defaultAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:12] };
    
    _headerAttributes = @[ @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:23] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:21] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:19] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:17] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:15] },
                           @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } ];
    _listAttributes = @[];
    _quoteAttributes = @[@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:12]}];
    
    _imageAttributes = @{};
    _linkAttributes = @{ NSForegroundColorAttributeName: [UIColor blueColor],
                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
    
    // Courier New and Courier are the only monospace fonts compatible with watchOS 2
    _monospaceAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Courier New" size:12],
                              NSForegroundColorAttributeName: [UIColor colorWithRed:0.95 green:0.54 blue:0.55 alpha:1] };
    _strongTraits = (TSFontTraitMask)TSFontMaskBold;
    _emphasisTraits = (TSFontTraitMask)TSFontMaskItalic;
    
    // weak reference for blocks
    __weak typeof(self) weakSelf = self;
    
    /* escaping parsing */
    
    [self addCodeEscapingParsing];
    
    [self addEscapingParsing];
    
    /* block parsing */
    
    [self addHeaderParsingWithMaxLevel:0 leadFormattingBlock:nil textFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        if (weakSelf.headerAttributes)
            [attributedString addAttributes:weakSelf.headerAttributes atIndex:level - 1 range:range];
        [attributedString addTraits:weakSelf.headerTraits atIndex:level - 1 range:range];
    }];
    
    [self addListParsingWithMaxLevel:0 leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        NSMutableString *listString = [NSMutableString string];
        while (--level)
            [listString appendString:@"\t"];
        [listString appendString:@"•\t"];
        [attributedString replaceCharactersInRange:range withString:listString];
    } textFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        if (weakSelf.listAttributes)
            [attributedString addAttributes:weakSelf.listAttributes atIndex:level - 1 range:range];
        [attributedString addTraits:weakSelf.listTraits atIndex:level - 1 range:range];
    }];
    
    [self addQuoteParsingWithMaxLevel:0 leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        NSMutableString *quoteString = [NSMutableString string];
        while (level--)
            [quoteString appendString:@"\t"];
        [attributedString replaceCharactersInRange:range withString:quoteString];
    } textFormattingBlock:^(NSMutableAttributedString * attributedString, NSRange range, NSUInteger level) {
        if (weakSelf.quoteAttributes)
            [attributedString addAttributes:weakSelf.quoteAttributes atIndex:level - 1 range:range];
        [attributedString addTraits:weakSelf.quoteTraits atIndex:level - 1 range:range];
    }];
    
    /* bracket parsing */
    
    [self addImageParsingWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * _Nullable link) {
#if !TARGET_OS_WATCH
        UIImage *image = [UIImage imageNamed:link];
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
            [attributedString addTrait:weakSelf.imageTraits range:range];
        }
    }];
    
    [self addLinkParsingWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * _Nullable link) {
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
        [attributedString addTrait:weakSelf.linkTraits range:range];
    }];
    
    /* autodetection */
    
    [self addLinkDetectionWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * _Nullable link) {
        if (!weakSelf.skipLinkAttribute) {
            [attributedString addAttribute:NSLinkAttributeName
                                     value:[NSURL URLWithString:link]
                                     range:range];
        }
        if (weakSelf.linkAttributes)
            [attributedString addAttributes:weakSelf.linkAttributes range:range];
        [attributedString addTrait:weakSelf.linkTraits range:range];
    }];
    
    /* inline parsing */
    
    [self addStrongParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        if (weakSelf.strongAttributes)
            [attributedString addAttributes:weakSelf.strongAttributes range:range];
        [attributedString addTrait:weakSelf.strongTraits range:range];
    }];
    
    [self addEmphasisParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        if (weakSelf.emphasisAttributes)
            [attributedString addAttributes:weakSelf.emphasisAttributes range:range];
        [attributedString addTrait:weakSelf.emphasisTraits range:range];
    }];
    
    /* unescaping parsing */
    
    [self addCodeUnescapingParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        if (weakSelf.monospaceAttributes)
            [attributedString addAttributes:weakSelf.monospaceAttributes range:range];
        [attributedString addTrait:weakSelf.monospaceTraits range:range];
    }];
    
    [self addUnescapingParsing];
    
    return self;
}

@end
