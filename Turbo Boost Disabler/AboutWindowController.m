//
//  AboutWindowController.m
//  Turbo Boost Switcher
//
//  Created by Rubén García Pérez on 22/07/13.
//  Copyright (c) 2013 Rubén García Pérez.
//  rugarciap.com
//
/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "AboutWindowController.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setTitle:NSLocalizedString(@"about_title", nil)];

    [appCopyRight setStringValue:NSLocalizedString(@"author", nil)];
    [authorLink setStringValue:NSLocalizedString(@"web", nil)];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"License" ofType:@"rtf"]];
    
    if (data != nil)
    {
        NSAttributedString *content = [[NSAttributedString alloc] initWithRTF:data
                                                           documentAttributes:NULL];
        [[txtLicense textStorage] setAttributedString: content];
    }

}

@end
