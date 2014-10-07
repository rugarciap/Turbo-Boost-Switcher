//
//  AppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import "SystemCommands.h"
#import "AboutWindowController.h"
#import "CheckUpdatesWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    // The status menu
    IBOutlet NSMenu *statusMenu;
    
    // The status item to display on bar
    NSStatusItem *statusItem;
    NSImage *statusImage;
    
    // About and check for updates window
    AboutWindowController *aboutWindow;
    CheckUpdatesWindowController *checkUpdatesWindow;
    
    NSTimer *refreshTimer;
    
    // Current auth ref
    AuthorizationRef authorizationRef;
    
    // Menú outlets
    IBOutlet NSMenuItem *enableDisableItem;
    IBOutlet NSMenuItem *checkUpdatesItem;
    IBOutlet NSMenuItem *aboutItem;
    IBOutlet NSMenuItem *exitItem;
    
    // Settings Window outlets
    IBOutlet NSTextField *settingsLabel;
    IBOutlet NSButton *checkOpenAtLogin;
    IBOutlet NSButton *checkDisableAtLaunch;
}

@property(nonatomic, strong) AboutWindowController *aboutWindow;
@property(nonatomic, strong) CheckUpdatesWindowController *checkUpdatesWindow;
@property(nonatomic, strong) NSTimer *refreshTimer;

- (IBAction) enableTurboBoost:(id)sender;

- (IBAction) about:(id)sender;
- (IBAction) openAtLogin:(id)sender;
- (IBAction) disableAtLogin:(id)sender;
- (IBAction) checkForUpdates:(id)sender;
- (IBAction) exitItemEvent:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
