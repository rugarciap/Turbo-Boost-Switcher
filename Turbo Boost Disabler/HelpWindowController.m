//
//  HelpWindowController.m
//  Turbo Boost Switcher
//
//  Created by Rubén García Pérez on 17/10/2020.
//  Copyright © 2020 Rubén García Pérez. All rights reserved.
//

#import "HelpWindowController.h"

@interface HelpWindowController ()

@end

@implementation HelpWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString *pathForFile = [[NSBundle mainBundle] pathForResource:@"HELP" ofType:@"rtfd"];
    [textView setEditable:NO];
    [textView readRTFDFromFile:pathForFile];
}

@end
