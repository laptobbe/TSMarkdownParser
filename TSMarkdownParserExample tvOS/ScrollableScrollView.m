//
//  ScrollableScrollView.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/16/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "ScrollableScrollView.h"
#import "UIScrollView+Scrollable.h"


@implementation ScrollableScrollView

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self makeScrollable];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self makeScrollable];
    return self;
}

- (BOOL)canBecomeFocused {
    return YES;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
    
    if (context.nextFocusedView == self) {
        [self addLeftRightFocusGuides];
    } else {
        [self removeLeftRightFocusGuides];
    }
}

@end
