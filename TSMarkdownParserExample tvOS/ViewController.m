//
//  ViewController.m
//  TSMarkdownParser tvOS
//
//  Created by Antoine Cœur on 3/29/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "ViewController.h"
#import <TSMarkdownStandardParser.h>

@interface ViewController ()

@property (strong, nonatomic) TSMarkdownParser *parser;
@property (weak, nonatomic) IBOutlet UITextView *markdownInput;
@property (weak, nonatomic) IBOutlet UILabel *markdownOutputLabel;
@property (weak, nonatomic) IBOutlet UITextView *markdownOutputTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.parser = [TSMarkdownStandardParser new];
    
    // updating output
    [self textViewDidChange:self.markdownInput];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSAttributedString *result = [self.parser attributedStringFromMarkdown:textView.text];
    self.markdownOutputLabel.attributedText = result;
    self.markdownOutputTextView.attributedText = result;
}

- (IBAction)switchOutput:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.markdownOutputLabel.hidden = NO;
        self.markdownOutputTextView.hidden = YES;
    } else {
        self.markdownOutputLabel.hidden = YES;
        self.markdownOutputTextView.hidden = NO;
    }
}

@end
