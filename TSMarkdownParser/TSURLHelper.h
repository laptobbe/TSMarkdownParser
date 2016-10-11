//
//  TSURLHelper.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/18/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

NS_ROOT_CLASS
@interface TSURLHelper

+ (nullable NSURL *)URLWithStringByAddingPercentEncoding:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
