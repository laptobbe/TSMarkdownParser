//
//  TSMarkupParser+FormatExamples.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/18/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSMarkupParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMarkupParser (FormatExamples)
/* A non-empty separator is recommended */
/* An empty string separator is discouraged as it may conflict with inline parsing */

/// with separator @" ", accepts "# text", "## text", ...
/// with separator @"", accepts "#text", "##text", ...
- (void)addHeaderParsingWithMaxLevel:(unsigned int)maxLevel
                           separator:(NSString *)separator
                 leadFormattingBlock:(nullable TSMarkupLengthFormattingBlock)leadFormattingBlock
                 textFormattingBlock:(nullable TSMarkupLengthFormattingBlock)formattingBlock;

/// with separator @" ", accepts "* text", "+ text", "- text", "** text", "++ text", "-- text", ...
/// with separator @"", accepts "*text", "+text", "-text", "** text", "++ text", "-- text", ...
- (void)addListParsingWithMaxLevel:(unsigned int)maxLevel
                         separator:(NSString *)separator
               leadFormattingBlock:(nullable TSMarkupLengthFormattingBlock)leadFormattingBlock
               textFormattingBlock:(nullable TSMarkupLengthFormattingBlock)formattingBlock;

/// with separator @" ", accepts "> text", ">> text", ...
/// with separator @"", accepts ">text", ">>text", ...
- (void)addQuoteParsingWithMaxLevel:(unsigned int)maxLevel
                          separator:(NSString *)separator
                leadFormattingBlock:(nullable TSMarkupLengthFormattingBlock)leadFormattingBlock
                textFormattingBlock:(nullable TSMarkupLengthFormattingBlock)formattingBlock;

/// accepts "text\n=", "text\n-", "text\n==", "text\n--", ...
- (void)addSubLineHeaderParsingWithMinLevel:(unsigned int)minLevel
                       trailFormattingBlock:(nullable TSMarkupLengthFormattingBlock)trailFormattingBlock
                        textFormattingBlock:(nullable TSMarkupLengthFormattingBlock)textFormattingBlock;

/// accepts "`text`", "``text``", ...
/// (conflicts with `addCodeEscapingParsing`)
- (void)addMonospacedParsingWithFormattingBlock:(TSSimpleFormattingBlock)formattingBlock;

/// accepts "**text**", "__text__"
- (void)addStrongParsingWithFormattingBlock:(TSSimpleFormattingBlock)formattingBlock;

/// accepts "*text*", "_text_"
- (void)addEmphasisParsingWithFormattingBlock:(TSSimpleFormattingBlock)formattingBlock;

@end

NS_ASSUME_NONNULL_END
