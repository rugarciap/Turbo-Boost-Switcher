//
//  CheckUpdatesWindowController.m
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

#import "CheckUpdatesWindowController.h"
#import "StartupHelper.h"

@interface CheckUpdatesWindowController ()

@end

@implementation CheckUpdatesWindowController

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
    
    // Set the title
    [self.window setTitle:NSLocalizedString(@"updates_title", nil)];
    
    checkUpdatesHelper = [[CheckUpdatesHelper alloc] init];
    
    [checkUpdates setTitle:NSLocalizedString(@"checkUpdates", nil)];
    [checkUpdates setState:[StartupHelper isCheckUpdatesOnStart]];
    
}

// Check if there is a new version available
- (void) checkVersion {
    
    // Start the download
    fileDownloaded = NO;
    updatesAvailable = NO;
    
    [imgStatus setHidden:YES];
    
    [progressIndicator setHidden:NO];
    [btnCancel setHidden:YES];
    [progressIndicator startAnimation:self];
    [txtStatus setStringValue:NSLocalizedString(@"updates_progress", nil)];
    [btnOk setTitle:NSLocalizedString(@"btn_cancel", nil)];
    
    // Download the version descriptor
    [checkUpdatesHelper checkUpdatesWithDelegate:(id)self];

}

- (IBAction) checkUpdatesPressed:(id)sender {
    
    // Store check for updates on startup
    BOOL checkForUpdatesOnStart = ([checkUpdates state] == NSOnState);
    [StartupHelper storeCheckUpdatesOnStart:checkForUpdatesOnStart];

}


// If there was an error
- (void) errorCheckingUpdate {
    
    [progressIndicator setHidden:YES];
    [progressIndicator stopAnimation:self];
    
    [txtStatus setStringValue:NSLocalizedString(@"updates_error", nil)];
    [btnOk setTitle:NSLocalizedString(@"btn_close", nil)];
    
    [imgStatus setImage:[NSImage imageNamed:@"icon_cancel.png"]];
    [imgStatus setHidden:NO];
}

// Update available
- (void) updateAvailable {
    updatesAvailable = YES;
    [self refreshUpdate];
}

// Update not available
- (void) updateNotAvailable {
    updatesAvailable = NO;
    [self refreshUpdate];
}

// Data download finished
- (void) refreshUpdate {
    
    fileDownloaded = YES;
    
    [progressIndicator setHidden:YES];
    [progressIndicator stopAnimation:self];
    
    [imgStatus setImage:[NSImage imageNamed:@"icon_ok.png"]];
    [imgStatus setHidden:NO];
    
    if (updatesAvailable) {
        
        [txtStatus setStringValue:NSLocalizedString(@"updates_available", nil)];
        [btnOk setTitle:NSLocalizedString(@"btn_download", nil)];
        
        [btnCancel setTitle:NSLocalizedString(@"btn_cancel", nil)];
        [btnCancel setHidden:NO];
        
    } else {
        
        [btnCancel setTitle:@""];
        [btnCancel setHidden:YES];
        
        [txtStatus setStringValue:NSLocalizedString(@"updates_not_available", nil)];
        [btnOk setTitle:NSLocalizedString(@"btn_close", nil)];
        
    }
}

- (IBAction) btnOkPressed:(id)sender {
    
    // If the file was not yet downloaded
    if (!fileDownloaded) {
        [self close];
        return;
    }
    
    // If there are updates, navigate to the download page
    if (updatesAvailable) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.rugarciap.com/tbs-update-page"]];
        [self close];
        return;
    }
    
    [self close];
}

- (IBAction) btnCancelPressed:(id)sender {
    [self close];
}




@end
