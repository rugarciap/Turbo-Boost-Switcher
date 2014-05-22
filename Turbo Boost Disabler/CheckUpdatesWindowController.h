//
//  CheckUpdatesWindowController.h
//  Turbo Boost Switcher
//
//  Created by Rubén García Pérez on 21/05/14.
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
#import <Cocoa/Cocoa.h>

@interface CheckUpdatesWindowController : NSWindowController <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    IBOutlet NSTextField *txtStatus;
    
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSButton *btnCancel;
    IBOutlet NSButton *btnOk;
    
    BOOL fileDownloaded;
    BOOL updatesAvailable;
    
    NSMutableData *contents;
    IBOutlet NSImageView *imgStatus;
    
}

- (IBAction) btnOkPressed:(id)sender;
- (IBAction) btnCancelPressed:(id)sender;

// Check if there is a new version available
- (void) checkVersion;

@end
