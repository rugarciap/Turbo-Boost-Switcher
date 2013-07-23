//
//  AppDelegate.m
//  Turbo Boost Switcher
//
//  Created by Rubén García Pérez on 19/07/13.
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

#import "AppDelegate.h"
#import "SystemCommands.h"
#import "AboutWindowController.h"
#import "StartupHelper.h"

@implementation AppDelegate

@synthesize aboutWindow, refreshTimer;

- (void) awakeFromNib {
    
    // Item to show up on the status bar
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    
    //[statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Turbo Boost Switcher"];

    [statusItem setHighlightMode:YES];
    [statusItem setImage:statusImage];

    // Set separators
    [statusMenu insertItem:[NSMenuItem separatorItem] atIndex:2];
    [statusMenu insertItem:[NSMenuItem separatorItem] atIndex:5];
    
    [statusItem setAction:@selector(statusItemClicked)];
    [statusItem setTarget:self];
    
    // Update open at login status
    NSMenuItem *openLoginItem = [statusMenu itemAtIndex:4];
    [openLoginItem setState:[StartupHelper isOpenAtLogin]];
    [openLoginItem setTitle:NSLocalizedString(@"open_login", nil)];
    
    // Update translations
    [[statusMenu itemAtIndex:6] setTitle:NSLocalizedString(@"donate", nil)];
    [[statusMenu itemAtIndex:7] setTitle:NSLocalizedString(@"about", nil)];
    [[statusMenu itemAtIndex:8] setTitle:NSLocalizedString(@"quit", nil)];
    
    // Refresh the status
    [self updateStatus];
    
    // Timer to update the sensor readings (cpu & fan rpm) each 2 seconds
    self.refreshTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(updateSensorValues) userInfo:nil repeats:YES];
    NSRunLoop * rl = [NSRunLoop mainRunLoop];
    [rl addTimer:self.refreshTimer forMode:NSRunLoopCommonModes];

}

// Invoked when the user clicks on the satus menu
- (void)statusItemClicked {
    [statusItem popUpStatusItemMenu:statusMenu];
    [self updateStatus];
}


// Refresh the GUI general status, including enable/disable options, on-off status, cpu & fan reads
- (void) updateStatus {
    
    BOOL isOn = ![SystemCommands isModuleLoaded];

    NSAttributedString *titleString;

    // Attributes for title string
    NSFont *labelFont = [NSFont fontWithName:@"Helvetica" size:11];
    
    if (isOn) {
        titleString = [[NSAttributedString alloc] initWithString:@"On " attributes:@{
            NSFontAttributeName : labelFont,
            }];
        [[statusMenu itemAtIndex:3] setTitle:NSLocalizedString(@"disable_menu", nil)];
    } else {
        titleString = [[NSAttributedString alloc] initWithString:@"Off " attributes:@{
                                            NSFontAttributeName : labelFont,
                       }];
        [[statusMenu itemAtIndex:3] setTitle:NSLocalizedString(@"enable_menu", nil)];
    }
    
    // Refresh the title
    [statusItem setAttributedTitle:titleString];
        
    // Updates the sensor readings
    [self updateSensorValues];
}

// Update the CPU Temp & Fan speed
- (void) updateSensorValues {

    int fanSpeed = [SystemCommands readCurrentFanSpeed];
    float cpuTemp = [SystemCommands readCurrentCpuTemp];
    
    
    if (cpuTemp > 0) {
        [[statusMenu itemAtIndex:0] setTitle:[NSString stringWithFormat:@"%@ %.02f ºC", NSLocalizedString(@"cpu_temp",@"cpu_temp"), cpuTemp]];
    } else {
        [[statusMenu itemAtIndex:0] setTitle:[NSString stringWithFormat:NSLocalizedString(@"cpu_temp_na",nil)]];
    }
    
    if (fanSpeed > 0) {
        [[statusMenu itemAtIndex:1] setTitle:[NSString stringWithFormat:@"%@ %d rpm", NSLocalizedString(@"fan_speed",@"cpu_temp"), fanSpeed]];
    } else {
        [[statusMenu itemAtIndex:1] setTitle:[NSString stringWithFormat:NSLocalizedString(@"fan_speed_na",nil)]];
    }
}

// Method to switch between enabled and disables states
- (IBAction) enableTurboBoost:(id)sender {

    BOOL isOn = ![SystemCommands isModuleLoaded];
    
    if (isOn) {
        [SystemCommands loadModule];
    } else {
        [SystemCommands unLoadModule];
    }
        
    [self updateStatus];
    
}

// Method to call for donations
- (IBAction) donate:(id)sender {

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WGDEE4ZZ27Y68"]];
}

// Open about window
- (IBAction) about:(id)sender {
    if (self.aboutWindow == nil) {
        // Init the about window
        self.aboutWindow = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    }
    [self.aboutWindow showWindow:nil];
}

// Enables/disables the open at login status
- (IBAction) openAtLogin:(id)sender {
    
    NSMenuItem *openLoginItem = [statusMenu itemAtIndex:4];
    [StartupHelper setOpenAtLogin:![StartupHelper isOpenAtLogin]];
    
    // Refresh open at login item status
    [openLoginItem setState:[StartupHelper isOpenAtLogin]];
}



@end
