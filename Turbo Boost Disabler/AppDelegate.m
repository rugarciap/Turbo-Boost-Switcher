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

// Struct to take the cpu samples
struct cpusample {
    uint64_t totalSystemTime;
    uint64_t totalUserTime;
    uint64_t totalIdleTime;
    
};

// The two samples
struct cpusample sample_one;
struct cpusample sample_two;


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
    
    // Init the cpu load samples
    sample_one.totalIdleTime = 0;
    sample_two.totalIdleTime = 0;
    
    // Locale init
    if ([StartupHelper currentLocale] == nil) {
        
        // Get the current language
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        NSString *currentLanguage = [languages objectAtIndex:0];
        
        // Save it
        [StartupHelper storeCurrentLocale:currentLanguage];
    }
    
    // Update languages menú
    [self updateLanguageMenu];
    
    // Init the check for updates helper
    checkUpdatesHelper = [[CheckUpdatesHelper alloc] init];
    
    // Item to show up on the status bar
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    statusImageOn = [NSImage imageNamed:@"icon"];
    statusImageOff = [NSImage imageNamed:@"icon_off"];
    
    [statusImageOn setTemplate:YES];
    [statusImageOff setTemplate:YES];
    
    //[statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Turbo Boost Switcher"];

    [statusItem setHighlightMode:YES];
    [statusItem setImage:statusImageOn];
 
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
    
    // Status strings init
    statusOnOff = [[NSMutableString alloc] initWithString:@""];
    
    [checkOnOffText setState:[StartupHelper isStatusOnOffEnabled]];
    [checkOnOffText setTitle:NSLocalizedString(@"onOffMenu", nil)];
    [checkOnOffText setFont:[statusMenu font]];
       
    // Update fonts
    [settingsLabel setFont:[statusMenu font]];
    [checkDisableAtLaunch setFont:[statusMenu font]];
    [checkOpenAtLogin setFont:[statusMenu font]];
    
    // Disable at launch if enabled
    if (([StartupHelper isDisableAtLaunch]) && (![SystemCommands isModuleLoaded])) {
        [self disableTurboBoost];
    }
    
    // Refresh the status
    [self performSelector:@selector(updateStatus) withObject:nil afterDelay:1];
    
    // Initially refresh the sensor values
    [self updateSensorValues];
    [NSThread sleepForTimeInterval:0.1];
    [self updateSensorValues];

    
    // Timer to update the sensor readings (cpu & fan rpm) each 4 seconds
    self.refreshTimer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(updateSensorValues) userInfo:nil repeats:YES];
    NSRunLoop * rl = [NSRunLoop mainRunLoop];
    [rl addTimer:self.refreshTimer forMode:NSRunLoopCommonModes];
    
    // Suscribe to sleep and wake up notifications
    [self fileNotifications];
    
    // Refresh the status item
    [self updateStatus];
    
    // Check for updates
    if ([StartupHelper isCheckUpdatesOnStart]) {
        [checkUpdatesHelper checkUpdatesWithDelegate:(id) self];
    }
    
    // Check run count and if mod 10, suggets going pro if the user don't answered "never shot this again" :).
    if (![StartupHelper neverShowProMessage]) {
        if (([StartupHelper runCount] % 10) == 0) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            
            [alert addButtonWithTitle:NSLocalizedString(@"alert_later", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"alert_never_show_again", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"btn_pro",nil)];
            
            [alert setMessageText:NSLocalizedString(@"alert_text", nil)];
            [alert setInformativeText:NSLocalizedString(@"alert_informative_text", nil)];
            
            [alert setAlertStyle:NSWarningAlertStyle];
            
            NSModalResponse modalResponse = [alert runModal];
            
            if (modalResponse == NSAlertSecondButtonReturn) {
                
                // Never show again clicked
                [StartupHelper storeNeverShowProMessage:YES];
                
            } else if (modalResponse == NSAlertThirdButtonReturn) {
                
                // Go pro!
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://gumroad.com/l/YeBQUF"]];
                    
            }
        }
        
        // Save the current count
        int currentCount = (int)[StartupHelper runCount];
        [StartupHelper storeRunCount:(currentCount + 1)];
    }

}

// Invoked when the user clicks on the satus menu
- (void)statusItemClicked {
    [statusItem popUpStatusItemMenu:statusMenu];
    [self updateStatus];
}

// Method to refresh the temperature image sensor depending on temperture
- (void) updateImageForTemperature:(int) temp {
    
    if (temp <= 60) {
        [temperatureImage setImage:[NSImage imageNamed:@"temperature_1.png"]];
    } else if (temp < 70) {
        [temperatureImage setImage:[NSImage imageNamed:@"temperature_2.png"]];
    } else if (temp < 80) {
        [temperatureImage setImage:[NSImage imageNamed:@"temperature_3.png"]];
    } else if (temp < 90) {
        [temperatureImage setImage:[NSImage imageNamed:@"temperature_4.png"]];
    } else {
        [temperatureImage setImage:[NSImage imageNamed:@"temperature_5.png"]];
    }
    
}

// Refresh the GUI general status, including enable/disable options, on-off status, cpu & fan reads
- (void) updateStatus {
    
    // Check other status
    BOOL isOn = ![SystemCommands isModuleLoaded];
    
    if (isOn) {
        
        if ([StartupHelper isStatusOnOffEnabled]) {
            [statusOnOff setString:@"On"];
        } else {
            [statusOnOff setString:@""];
        }
        
        [enableDisableItem setTitle:NSLocalizedString(@"disable_menu", nil)];
        [statusItem setImage:statusImageOn];
        
    } else {
        
        if ([StartupHelper isStatusOnOffEnabled]) {
            [statusOnOff setString:@"Off"];
        } else {
            [statusOnOff setString:@""];
        }
        
        [enableDisableItem setTitle:NSLocalizedString(@"enable_menu", nil)];
        [statusItem setImage:statusImageOff];
    }
    
    // Refresh the title
    [self refreshTitleString];
    
}

// Update the CPU Temp & Fan speed
- (void) updateSensorValues {

    int fanSpeed = [SystemCommands readCurrentFanSpeed];
    float cpuTemp = [SystemCommands readCurrentCpuTemp];
    
    // Read the CPU temp
    if (cpuTemp > 0) {
        NSString *tempString = [NSString stringWithFormat:@"%.00f ºC", cpuTemp];
        
        [txtCpuTemp setStringValue:tempString];
        
        // Update temperature image
        [self updateImageForTemperature:cpuTemp];
        
    } else {
        [txtCpuTemp setStringValue:@"N/A"];
    }

    
    // Read the fan speed
    NSString *rpmData = nil;
    if (fanSpeed > 0) {
        rpmData = [NSString stringWithFormat:@"%d rpm", fanSpeed];
        [txtCpuFan setStringValue:rpmData];
    } else {
        rpmData = @"N/A";
        [txtCpuFan setStringValue:rpmData];
    }
    
    // Get the CPU Load
    if (sample_one.totalIdleTime == 0) {
        sample(true);
    } else {
        sample(false);
        
        struct cpusample delta;
        delta.totalSystemTime = sample_two.totalSystemTime - sample_one.totalSystemTime;
        delta.totalUserTime = sample_two.totalUserTime - sample_one.totalUserTime;
        delta.totalIdleTime = sample_two.totalIdleTime - sample_one.totalIdleTime;
        
        sample_one.totalSystemTime = sample_two.totalSystemTime;
        sample_one.totalUserTime = sample_two.totalUserTime;
        sample_one.totalIdleTime = sample_two.totalIdleTime;
        
        uint64_t total = delta.totalSystemTime + delta.totalUserTime + delta.totalIdleTime;
        
        double onePercent = total/100.0f;
        
        double cpuIdleValue = (double)delta.totalIdleTime/(double)onePercent;
        double cpuLoadValue = 100.0 - cpuIdleValue;
        
        [txtCpuLoad setStringValue:[NSString stringWithFormat:@"CPU Load: %.01f%%", cpuLoadValue]];
        
    }
    
    // Refresh the title string
    [self refreshTitleString];
}


// Take one cpu sample
void sample(bool isOne) {
    
    kern_return_t kernelReturn;
    mach_msg_type_number_t msgType;
    host_cpu_load_info_data_t loadInfoData;
    
    msgType = HOST_CPU_LOAD_INFO_COUNT;
    kernelReturn = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (int *)&loadInfoData, &msgType);
    if (kernelReturn != KERN_SUCCESS) {
        printf("oops: %s\n", mach_error_string(kernelReturn));
        return;
    }
    
    if (isOne) {
        sample_one.totalSystemTime = loadInfoData.cpu_ticks[CPU_STATE_SYSTEM];
        sample_one.totalUserTime = loadInfoData.cpu_ticks[CPU_STATE_USER] + loadInfoData.cpu_ticks[CPU_STATE_NICE];
        sample_one.totalIdleTime = loadInfoData.cpu_ticks[CPU_STATE_IDLE];
    } else {
        sample_two.totalSystemTime = loadInfoData.cpu_ticks[CPU_STATE_SYSTEM];
        sample_two.totalUserTime = loadInfoData.cpu_ticks[CPU_STATE_USER] + loadInfoData.cpu_ticks[CPU_STATE_NICE];
        sample_two.totalIdleTime = loadInfoData.cpu_ticks[CPU_STATE_IDLE];
    }
    
}

// Update language menu
- (void) updateLanguageMenu {
    
    NSString *currentLocale = [StartupHelper currentLocale];
    
    [spanishMenu setState:NSOffState];
    [englishMenu setState:NSOffState];
    [frenchMenu setState:NSOffState];
    [chineseMenu setState:NSOffState];
    [germanMenu setState:NSOffState];
    [polishMenu setState:NSOffState];
    [russianMenu setState:NSOffState];
    [swedishMenu setState:NSOffState];
    
    // TODO: Change this to a nsmutabledict
    if ([currentLocale rangeOfString:@"es"].location != NSNotFound) {
        [spanishMenu setState:NSOnState];
    } else if ([currentLocale rangeOfString:@"en"].location != NSNotFound) {
        [englishMenu setState:NSOnState];
    } else if ([currentLocale rangeOfString:@"fr"].location != NSNotFound) {
        [frenchMenu setState:NSOnState];
    } else if ([currentLocale rangeOfString:@"cn"].location != NSNotFound) {
        [chineseMenu setState:NSOnState];
    } else if ([currentLocale rangeOfString:@"de"].location != NSNotFound) {
        [germanMenu setState:NSOnState];
    } else if ([currentLocale rangeOfString:@"pl"].location != NSNotFound) {
        [polishMenu setState:NSOnState];
    } else if ([currentLocale rangeOfString:@"ru"].location != NSNotFound) {
        [russianMenu setState:NSOnState];
    } else if ([currentLocale rangeOfString:@"sv"].location != NSNotFound) {
        [swedishMenu setState:NSOnState];
    }
    
    // Update language translations
    [languageMenu setTitle:NSLocalizedString(@"language", nil)];
    [spanishMenu setTitle:NSLocalizedString(@"language_es", nil)];
    [englishMenu setTitle:NSLocalizedString(@"language_en", nil)];
    [frenchMenu setTitle:NSLocalizedString(@"language_fr", nil)];
    [chineseMenu setTitle:NSLocalizedString(@"language_zh", nil)];
    [germanMenu setTitle:NSLocalizedString(@"language_de", nil)];
    [polishMenu setTitle:NSLocalizedString(@"language_pl", nil)];
    [russianMenu setTitle:NSLocalizedString(@"language_ru", nil)];
    [swedishMenu setTitle:NSLocalizedString(@"language_sv", nil)];
    
}

// Change language to
- (void) changeLanguageTo:(NSString *) value {
    
    [StartupHelper storeCurrentLocale:value];
    
    // AppleLanguages
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:value, nil] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

// Language changed
- (IBAction) languageChanged:(id)sender {
    
    // Asks for user confirmation
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:NSLocalizedString(@"btn_close", nil)];
    [alert setMessageText:NSLocalizedString(@"language_change_confirmation", nil)];
    [alert setInformativeText:NSLocalizedString(@"language_change_informative_text", nil)];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        
        // OK clicked... TODO: Change this to a nsmutabledict
        if ([sender isEqualTo:spanishMenu]) {
            [self changeLanguageTo:@"es"];
        } else if ([sender isEqualTo:englishMenu]) {
            [self changeLanguageTo:@"en"];
        } else if ([sender isEqualTo:frenchMenu]) {
            [self changeLanguageTo:@"fr"];
        } else if ([sender isEqualTo:chineseMenu]) {
            [self changeLanguageTo:@"zh"];
        } else if ([sender isEqualTo:germanMenu]) {
            [self changeLanguageTo:@"de"];
        } else if ([sender isEqualTo:polishMenu]) {
            [self changeLanguageTo:@"pl"];
        } else if ([sender isEqualTo:russianMenu]) {
            [self changeLanguageTo:@"ru"];
        } else if ([sender isEqualTo:swedishMenu]) {
            [self changeLanguageTo:@"sv"];
        }
        
        [self updateLanguageMenu];
        
        // Relaunch the app
        [self relaunchAfterDelay:1];
        
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
    
    [self performSelector:@selector(updateStatus) withObject:nil afterDelay:1.0];
    
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

// Error
- (void) errorCheckingUpdate {
    
}

// Update available
- (void) updateAvailable {
    
    // Download the update opening the CheckUpdates Window Controller
    if (self.checkUpdatesWindow == nil) {
        self.checkUpdatesWindow = [[CheckUpdatesWindowController alloc] initWithWindowNibName:@"CheckUpdatesWindowController"];
    }
    
    [self.checkUpdatesWindow.window center];
    [self.checkUpdatesWindow showWindow:nil];
    [self.checkUpdatesWindow updateAvailable];
}

// Update not available
- (void) updateNotAvailable {
    
}

// Method to refresh the status bar title string
- (void) refreshTitleString {
    
    // Attributes for title string
    NSFont *labelFont = [NSFont fontWithName:@"Helvetica" size:11];
    
    // Final title string
    NSMutableString *finalString = [[NSMutableString alloc] initWithString:@""];
    
    [finalString appendString:statusOnOff];
    
    // Refresh the title
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:finalString attributes:@{NSFontAttributeName : labelFont}];
    [statusItem setAttributedTitle:attributedTitle];
}

// On / Off check click
- (IBAction) onOffClick:(id)sender {
    
    [StartupHelper storeStatusOnOffEnabled:[checkOnOffText state] == NSOnState];
    
    // Refresh the title string
    [self updateSensorValues];
    
}


- (void) terminate {
    [[NSApplication sharedApplication] terminate:self];
}

// Relaunch after delay
- (void)relaunchAfterDelay:(float)seconds
{
    NSTask *task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-c"];
    [args addObject:[NSString stringWithFormat:@"sleep %f; open \"%@\"", seconds, [[NSBundle mainBundle] bundlePath]]];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
    
    [self terminate];
}


@end
