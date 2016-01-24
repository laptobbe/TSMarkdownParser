//
//  ViewController.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 24/01/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "ViewController.h"
#import "TSMarkdownParser.h"

@interface ViewController ()

@property (strong, nonatomic) TSMarkdownParser *parser;
@property (weak, nonatomic) IBOutlet UITextView *markdownInput;
@property (weak, nonatomic) IBOutlet UILabel *markdownOutput;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parser = [TSMarkdownParser standardParser];
    [self textViewDidChange:self.markdownInput];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.markdownOutput.attributedText = [self.parser attributedStringFromMarkdown:textView.text];
}

@end
