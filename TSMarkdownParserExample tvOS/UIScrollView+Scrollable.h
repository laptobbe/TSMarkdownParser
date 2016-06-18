//
//  UIScrollView+Scrollable.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/16/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIScrollView (Scrollable)

- (void)makeScrollable;

@property (nonatomic, unsafe_unretained) UIView *leftRightPreferredFocusedView;
- (void)addLeftRightFocusGuides;
- (void)removeLeftRightFocusGuides;

@end
