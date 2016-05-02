//
//  TSStandardParser.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 03/04/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSStandardParser.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
typedef NSColor UIColor;
typedef NSImage UIImage;
typedef NSFont UIFont;
#endif


@implementation TSStandardParser

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
    _quoteAttributes = @[@{NSFontAttributeName: [UIFont fontWithName:@"Georgia-Italic" size:12]}];
    
    _imageAttributes = @{};
    _linkAttributes = @{ NSForegroundColorAttributeName: [UIColor blueColor],
                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
    
    _monospaceAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12],
                              NSForegroundColorAttributeName: [UIColor colorWithRed:0.95 green:0.54 blue:0.55 alpha:1] };
    _strongAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:12] };
    
#if TARGET_OS_IPHONE
    _emphasisAttributes = @{ NSFontAttributeName: [UIFont italicSystemFontOfSize:12] };
#else
    _emphasisAttributes = @{ NSFontAttributeName: [[NSFontManager sharedFontManager] convertFont:[UIFont systemFontOfSize:12] toHaveTrait:NSItalicFontMask] };
#endif
    
    // weak reference for blocks
    __weak typeof(self) weakSelf = self;
    
    /* escaping parsing */
    
    [self addCodeEscapingParsing];
    
    [self addEscapingParsing];
    
    /* block parsing */
    
    [self addHeaderParsingWithMaxLevel:0 leadFormattingBlock:nil textFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        [TSStandardParser addAttributes:weakSelf.headerAttributes atIndex:level - 1 toString:attributedString range:range];
    }];
    
    [self addListParsingWithMaxLevel:0 leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        NSMutableString *listString = [NSMutableString string];
        while (--level)
            [listString appendString:@"\t"];
        [listString appendString:@"•\t"];
        [attributedString replaceCharactersInRange:range withString:listString];
    } textFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        [TSStandardParser addAttributes:weakSelf.listAttributes atIndex:level - 1 toString:attributedString range:range];
    }];
    
    [self addQuoteParsingWithMaxLevel:0 leadFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSUInteger level) {
        NSMutableString *quoteString = [NSMutableString string];
        while (level--)
            [quoteString appendString:@"\t"];
        [attributedString replaceCharactersInRange:range withString:quoteString];
    } textFormattingBlock:^(NSMutableAttributedString * attributedString, NSRange range, NSUInteger level) {
        [TSStandardParser addAttributes:weakSelf.quoteAttributes atIndex:level - 1 toString:attributedString range:range];
    }];
    
    /* bracket parsing */
    
    [self addImageParsingWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * _Nullable link) {
        UIImage *image = [UIImage imageNamed:link];
        if (image) {
            NSTextAttachment *imageAttachment = [NSTextAttachment new];
            imageAttachment.image = image;
            imageAttachment.bounds = CGRectMake(0, -5, image.size.width, image.size.height);
            NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:imageAttachment];
            [attributedString replaceCharactersInRange:range withAttributedString:imgStr];
        } else {
            if (!weakSelf.skipLinkAttribute) {
                NSURL *url = [NSURL URLWithString:link] ?: [NSURL URLWithString:
                                                            [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                if (url.scheme) {
                    [attributedString addAttribute:NSLinkAttributeName
                                             value:url
                                             range:range];
                }
            }
            [attributedString addAttributes:weakSelf.imageAttributes range:range];
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
        [attributedString addAttributes:weakSelf.linkAttributes range:range];
    }];
    
    /* autodetection */
    
    [self addLinkDetectionWithLinkFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range, NSString * _Nullable link) {
        if (!weakSelf.skipLinkAttribute) {
            [attributedString addAttribute:NSLinkAttributeName
                                     value:[NSURL URLWithString:link]
                                     range:range];
        }
        [attributedString addAttributes:weakSelf.linkAttributes range:range];
    }];
    
    /* inline parsing */
    
    [self addStrongParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString addAttributes:weakSelf.strongAttributes range:range];
    }];
    
    [self addEmphasisParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString addAttributes:weakSelf.emphasisAttributes range:range];
    }];
    
    /* unescaping parsing */
    
    [self addCodeUnescapingParsingWithFormattingBlock:^(NSMutableAttributedString *attributedString, NSRange range) {
        [attributedString addAttributes:weakSelf.monospaceAttributes range:range];
    }];
    
    [self addUnescapingParsing];
    
    return self;
}

#pragma mark -

+ (void)addAttributes:(NSArray<NSDictionary<NSString *, id> *> *)attributesArray atIndex:(NSUInteger)level toString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    if (!attributesArray.count)
        return;
    NSDictionary<NSString *, id> *attributes = level < attributesArray.count ? attributesArray[level] : attributesArray.lastObject;
    [attributedString addAttributes:attributes range:range];
}

@end
