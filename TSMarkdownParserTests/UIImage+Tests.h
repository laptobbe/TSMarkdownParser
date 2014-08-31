//
// Created by Tobias Sundstrand on 14-08-31.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
* UIImage imageNamed: method does not work in unit test
* This category provides workaround that works just like imageNamed method from UIImage class.
* Works only for png files. If you need other extension, use imageNamed:extension: method.
* NOTE: Do not load this category or use methods defined in it in targets other than unit tests
* as it will replace original imageNamed: method from UIImage class!
*/
@interface UIImage (Tests)

/**
* Returns image with the specified name and extension.
* @param imageName Name of the image file. Should not contain extension.
* NOTE: You do not have to specify '@2x' in the filename for retina files - it is done automatically.
* @param extension Extension for the image file. Should not contain dot.
* @return UIImage instance or nil if the image with specified name and extension can not be found.
*/
+ (UIImage *)imageNamed:(NSString *)imageName extension:(NSString *)extension;


@end