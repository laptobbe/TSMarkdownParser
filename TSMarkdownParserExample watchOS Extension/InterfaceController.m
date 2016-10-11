//
//  InterfaceController.m
//  TSMarkdownParserExample watchOS Extension
//
//  Created by Antoine Cœur on 07/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "InterfaceController.h"
#import <TSMarkdownStandardParser.h>


@interface InterfaceController()

@property (strong, nonatomic) TSMarkupParser *parser;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *markdownOutputLabel;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    self.parser = [TSMarkdownStandardParser new];
    
    NSString *input = @"# header\n\
###### header\n\
* list, _emphasis_, *emphasis*\n\
++ list, __bold__, **bold**\n\
--- list, `code`, ``code``\n\
> quote\n\
>> quote\n\
\\# \\*escaping\\* \\_escaping\\_ \\`escaping\\`\n\
[link](http://example.net)\n\
http://example.net\n\
![image](markdown)";
    NSAttributedString *result = [self.parser attributedStringFromMarkup:input];
    self.markdownOutputLabel.attributedText = result;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



