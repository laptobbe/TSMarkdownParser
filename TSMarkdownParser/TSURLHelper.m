//
//  TSURLHelper.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/18/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSURLHelper.h"

@implementation TSURLHelper

+ (nullable NSURL *)URLWithStringByAddingPercentEncoding:(NSString *)link
{
    // TODO: use [link stringByAddingPercentEncodingWithAllowedCharacters:<#(nonnull NSCharacterSet *)#>];
    NSURL *url = [NSURL URLWithString:link] ?: [NSURL URLWithString:
                                                [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return url;
}

@end
