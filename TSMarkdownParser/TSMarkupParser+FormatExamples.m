//
//  TSMarkupParser+FormatExamples.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/18/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSMarkupParser+FormatExamples.h"


@implementation TSMarkupParser (FormatExamples)

// lead symbols
static NSString *const TSMarkdownExampleHeaderSymbol        = @"#";
static NSString *const TSMarkdownExampleListSymbol          = @"\\*|\\+|\\-";
static NSString *const TSMarkdownExampleQuoteSymbol         = @"\\>";
//static NSString *const TSMarkdownExampleNumericListSymbol   = @"0-9";

// trail symbols
static NSString *const TSMarkdownExampleSubLineSymbol       = @"=|\\-";

// enclosing symbols
static NSString *const TSMarkdownExampleBoldSymbol          = @"\\*\\*|__";
static NSString *const TSMarkdownExampleEmphasisSymbol      = @"\\*|_";
//static NSString *const TSMarkdownExampleStrikethroughSymbol = @"~|\\-";
//static NSString *const TSMarkdownExampleUnderlineSymbol     = @"_";

// prefix symbols
//static NSString *const TSMarkupExampleArobaseSymbol       = @"@";
//static NSString *const TSMarkupExampleHashtagSymbol       = @"#";

static inline TSFullFormattingBlock TSMarkupFullBlockWithLeadAndTextBlocks(TSMarkupLengthFormattingBlock _Nullable leadFormattingBlock, TSMarkupLengthFormattingBlock _Nullable textFormattingBlock) {
    return ^(NSMutableAttributedString * _Nonnull attributedString, NSRange textRange, NSRange leadRange, NSRange fullRange) {
        NSUInteger level = leadRange.length;
        NSRange leadingRange = NSMakeRange(leadRange.location, textRange.location - leadRange.location);
        // formatting string (may alter the length)
        if (textFormattingBlock)
            textFormattingBlock(attributedString, textRange, level);
        // formatting leading markup (may alter the length)
        if (leadFormattingBlock)
            leadFormattingBlock(attributedString, leadingRange, level);
        else
            // deleting leading markup
            [attributedString deleteCharactersInRange:leadingRange];
    };
}

static inline TSFullFormattingBlock TSMarkupFullBlockWithTrailAndTextBlocks(TSMarkupLengthFormattingBlock _Nullable trailFormattingBlock, TSMarkupLengthFormattingBlock _Nullable textFormattingBlock) {
    return ^(NSMutableAttributedString * _Nonnull attributedString, NSRange textRange, NSRange trailRange, NSRange fullRange) {
        NSUInteger level = trailRange.length;
#warning // TODO: test range
        NSRange trailingRange = NSMakeRange(textRange.location + textRange.length, trailRange.location + trailRange.length - textRange.location - textRange.length);
        // formatting trailing markup (may alter the length)
        if (trailFormattingBlock)
            trailFormattingBlock(attributedString, trailingRange, level);
        else
            // deleting trailing markup
            [attributedString deleteCharactersInRange:trailingRange];
        // formatting string (may alter the length)
        if (textFormattingBlock)
            textFormattingBlock(attributedString, textRange, level);
    };
}

- (void)addHeaderParsingWithMaxLevel:(unsigned int)maxLevel
                           separator:(NSString *)separator
                 leadFormattingBlock:(nullable TSMarkupLengthFormattingBlock)leadFormattingBlock
                 textFormattingBlock:(nullable TSMarkupLengthFormattingBlock)textFormattingBlock
{
    [self addStartLineParsingWithSymbols:@"#"
                                maxLevel:maxLevel
                              separators:separator
                         formattingBlock:TSMarkupFullBlockWithLeadAndTextBlocks(leadFormattingBlock, textFormattingBlock)];
}

- (void)addListParsingWithMaxLevel:(unsigned int)maxLevel
                         separator:(NSString *)separator
               leadFormattingBlock:(nullable TSMarkupLengthFormattingBlock)leadFormattingBlock
               textFormattingBlock:(nullable TSMarkupLengthFormattingBlock)textFormattingBlock {
    [self addStartLineParsingWithSymbols:@"\\*|\\+|\\-"
                                maxLevel:maxLevel
                              separators:separator
                         formattingBlock:TSMarkupFullBlockWithLeadAndTextBlocks(leadFormattingBlock, textFormattingBlock)];
}

- (void)addQuoteParsingWithMaxLevel:(unsigned int)maxLevel
                          separator:(NSString *)separator
                leadFormattingBlock:(nullable TSMarkupLengthFormattingBlock)leadFormattingBlock
                textFormattingBlock:(nullable TSMarkupLengthFormattingBlock)textFormattingBlock {
    [self addStartLineParsingWithSymbols:@"\\>"
                                maxLevel:maxLevel
                              separators:separator
                         formattingBlock:TSMarkupFullBlockWithLeadAndTextBlocks(leadFormattingBlock, textFormattingBlock)];
}

- (void)addSubLineHeaderParsingWithMinLevel:(unsigned int)minLevel
                       trailFormattingBlock:(nullable TSMarkupLengthFormattingBlock)trailFormattingBlock
                        textFormattingBlock:(nullable TSMarkupLengthFormattingBlock)textFormattingBlock {
    [self addSubLineParsingWithSymbols:@"=|\\-"
                              minLevel:minLevel
                       formattingBlock:TSMarkupFullBlockWithTrailAndTextBlocks(trailFormattingBlock, textFormattingBlock)];
}

#pragma mark -

- (void)addMonospacedParsingWithFormattingBlock:(TSSimpleFormattingBlock)formattingBlock {
    [self addVariableEnclosedParsingWithSymbol:@"`" formattingBlock:formattingBlock];
}

- (void)addStrongParsingWithFormattingBlock:(TSSimpleFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithSymbol:@"\\*\\*|__" formattingBlock:formattingBlock];
}

- (void)addEmphasisParsingWithFormattingBlock:(TSSimpleFormattingBlock)formattingBlock {
    [self addEnclosedParsingWithSymbol:@"\\*|_" formattingBlock:formattingBlock];
}

@end
