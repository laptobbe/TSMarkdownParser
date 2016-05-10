//
//  ViewController.m
//  TSMarkdownParser tvOS
//
//  Created by Antoine Cœur on 3/29/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "ViewController.h"
#import "TSMarkdownStandardParser.h"

@interface ViewController ()

@property (strong, nonatomic) TSMarkdownParser *parser;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.parser = [TSMarkdownStandardParser new];
}

@end
