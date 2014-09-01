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
#import "CheckUpdatesWindowController.h"

@implementation AppDelegate

@synthesize aboutWindow, refreshTimer, checkUpdatesWindow;


// On wake up reinstall the module if needed
- (void) receiveWakeNote: (NSNotification*) note
{
    
    // Reload the module if the current status is on, since OSX enables turbo boost after an
    // undetermined time on sleep / hibernation
    
    if ([SystemCommands isModuleLoaded]) {
        
        if (authorizationRef == NULL) {
            OSStatus status = AuthorizationCreate(NULL,
                                                  kAuthorizationEmptyEnvironment,
                                                  kAuthorizationFlagDefaults,
                                                  &authorizationRef);
            
            AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
            AuthorizationRights rights = {1, &right};
            AuthorizationFlags flags = kAuthorizationFlagDefaults |
            kAuthorizationFlagInteractionAllowed |
            kAuthorizationFlagPreAuthorize |
            kAuthorizationFlagExtendRights;
            
            status = AuthorizationCopyRights(authorizationRef, &rights, NULL, flags, NULL);
            if (status != errAuthorizationSuccess)
                NSLog(@"Copy Rights Unsuccessful: %d", status);
            
        }
        
        [SystemCommands unLoadModuleWithAuthRef:authorizationRef];
        [SystemCommands loadModuleWithAuthRef:authorizationRef];
    }
    
    [self performSelector:@selector(updateStatus) withObject:nil afterDelay:0.5];
   
}

// Suscribe to wake up notifications
- (void) fileNotifications
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

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
    [statusMenu insertItem:[NSMenuItem separatorItem] atIndex:[statusMenu indexOfItem:enableDisableItem]];
    [statusMenu insertItem:[NSMenuItem separatorItem] atIndex:([statusMenu indexOfItem:checkUpdatesItem] + 1)];
    [statusMenu insertItem:[NSMenuItem separatorItem] atIndex:[statusMenu indexOfItem:aboutItem]];
    
    [statusItem setAction:@selector(statusItemClicked)];
    [statusItem setTarget:self];
    
    // Update open at login status
    [checkOpenAtLogin setState:[StartupHelper isOpenAtLogin]];
    [checkOpenAtLogin setTitle:NSLocalizedString(@"open_login", nil)];
    
    // Update disable at login status
    [checkDisableAtLaunch setState:[StartupHelper isDisableAtLaunch]];
    [checkDisableAtLaunch setTitle:NSLocalizedString(@"disable_login", nil)];
    
    // Update translations
    [settingsLabel setTitleWithMnemonic:NSLocalizedString(@"settings", nil)];
    [checkUpdatesItem setTitle:NSLocalizedString(@"updates", nil)];
    [aboutItem setTitle:NSLocalizedString(@"about", nil)];
    [exitItem setTitle:NSLocalizedString(@"quit", nil)];
    
    // Update fonts
    [settingsLabel setFont:[statusMenu font]];
    [checkDisableAtLaunch setFont:[statusMenu font]];
    [checkOpenAtLogin setFont:[statusMenu font]];
    
    // Disable at launch if enabled
    if (([StartupHelper isDisableAtLaunch]) && (![SystemCommands isModuleLoaded])) {
        [self disableTurboBoost];
    }
    
    // Refresh the status
    [self performSelector:@selector(updateStatus) withObject:nil afterDelay:0.5];
    
    // Timer to update the sensor readings (cpu & fan rpm) each 4 seconds
    self.refreshTimer = [NSTimer timerWithTimeInterval:4 target:self selector:@selector(updateSensorValues) userInfo:nil repeats:YES];
    NSRunLoop * rl = [NSRunLoop mainRunLoop];
    [rl addTimer:self.refreshTimer forMode:NSRunLoopCommonModes];
    
    // Suscribe to sleep and wake up notifications
    [self fileNotifications];
    
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
        [enableDisableItem setTitle:NSLocalizedString(@"disable_menu", nil)];
    } else {
        titleString = [[NSAttributedString alloc] initWithString:@"Off " attributes:@{
                                            NSFontAttributeName : labelFont,
                       }];
        [enableDisableItem setTitle:NSLocalizedString(@"enable_menu", nil)];
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
        [self disableTurboBoost];
    } else {
        [self enableTurboBoost];
    }
    
    [self performSelector:@selector(updateStatus) withObject:nil afterDelay:0.5];
    
}

- (IBAction) exitItemEvent:(id)sender {
    
    // Re-enable Turbo Boost before exit app
    if ([SystemCommands isModuleLoaded]) {
        [self enableTurboBoost];
    }
    [[NSApplication sharedApplication] terminate:self];
    
}


// Loads the kernel module disabling turbo boost feature
- (void) disableTurboBoost {
    
    if (authorizationRef == NULL) {
        
        OSStatus status = AuthorizationCreate(NULL,
                                              kAuthorizationEmptyEnvironment,
                                              kAuthorizationFlagDefaults,
                                              &authorizationRef);
        
        AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
        AuthorizationRights rights = {1, &right};
        AuthorizationFlags flags = kAuthorizationFlagDefaults |
        kAuthorizationFlagInteractionAllowed |
        kAuthorizationFlagPreAuthorize |
        kAuthorizationFlagExtendRights;
        
        status = AuthorizationCopyRights(authorizationRef, &rights, NULL, flags, NULL);
        if (status != errAuthorizationSuccess)
            NSLog(@"Copy Rights Unsuccessful: %d", status);
        
    }
    
    [SystemCommands loadModuleWithAuthRef:authorizationRef];
    
}

// Unloads the kernel module enabling turbo boost feature
- (void) enableTurboBoost {
    
    if (authorizationRef == NULL) {
        
        OSStatus status = AuthorizationCreate(NULL,
                                              kAuthorizationEmptyEnvironment,
                                              kAuthorizationFlagDefaults,
                                              &authorizationRef);
        
        AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
        AuthorizationRights rights = {1, &right};
        AuthorizationFlags flags = kAuthorizationFlagDefaults |
        kAuthorizationFlagInteractionAllowed |
        kAuthorizationFlagPreAuthorize |
        kAuthorizationFlagExtendRights;
        
        status = AuthorizationCopyRights(authorizationRef, &rights, NULL, flags, NULL);
        if (status != errAuthorizationSuccess)
            NSLog(@"Copy Rights Unsuccessful: %d", status);
        
    }
    
    [SystemCommands unLoadModuleWithAuthRef:authorizationRef];
    
}

// Method to check for updates
- (IBAction) checkForUpdates:(id)sender {
    
    // Download the update opening the CheckUpdates Window Controller
    if (self.checkUpdatesWindow == nil) {
        self.checkUpdatesWindow = [[CheckUpdatesWindowController alloc] initWithWindowNibName:@"CheckUpdatesWindowController"];
    }
    
    [self.checkUpdatesWindow.window center];
    [self.checkUpdatesWindow showWindow:nil];
    [self.checkUpdatesWindow checkVersion];
    
}

// Open about window
- (IBAction) about:(id)sender {
    if (self.aboutWindow == nil) {
        // Init the about window
        self.aboutWindow = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    }
    
    [self.aboutWindow.window center];
    [self.aboutWindow showWindow:nil];
}

// Enables/disables the open at login status
- (IBAction) openAtLogin:(id)sender {
   
    [StartupHelper setOpenAtLogin:![StartupHelper isOpenAtLogin]];
    
    // Refresh open at login item status
    [checkOpenAtLogin setState:[StartupHelper isOpenAtLogin]];
}

- (IBAction) disableAtLogin:(id)sender {
    
    [StartupHelper setDisableAtLaunch:[checkDisableAtLaunch state]];
}


@end
