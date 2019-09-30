//
//  StartupHelper.m
//  Turbo Boost Switcher
//
//  Created by Rubén García Pérez on 21/07/13.
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

#import "StartupHelper.h"

@implementation StartupHelper


+ (BOOL) isOpenAtLogin {
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    UInt32 seedValue;
    NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
    
    for (id itemObject in loginItemsArray) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef) itemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
        if (currentItemURL && CFEqual(currentItemURL, url)) {
            CFRelease(currentItemURL);
            return YES;
        }
        if (currentItemURL)
            CFRelease(currentItemURL);
    }
    
    return NO;
    
}

// Is check updates on start
+ (BOOL) isCheckUpdatesOnStart {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"isCheckUpdatesOnStart"];
}

// Store check updates on start
+ (void) storeCheckUpdatesOnStart:(BOOL) value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:@"isCheckUpdatesOnStart"];
    [userDefaults synchronize];
}

+ (void) setOpenAtLogin:(BOOL) isOpenAtLogin {
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (isOpenAtLogin) {
    

        if (loginItems) {
            LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
            if (item){
                CFRelease(item);
            }
        }
    } else {
        
        if (loginItems) {
            UInt32 seedValue;
            NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
            for(int i=0; i< [loginItemsArray count]; i++){
                LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                            objectAtIndex:i];
                //Resolve the item with URL
                if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                    NSString * urlPath = [(__bridge NSURL*)url path];
                    if ([urlPath compare:appPath] == NSOrderedSame){
                        LSSharedFileListItemRemove(loginItems,itemRef);
                    }
                }
            }
        }
    }
    
	CFRelease(loginItems);
}

// Stores disable at launch configuration
+ (void) setDisableAtLaunch:(BOOL) disableAtLaunch {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:disableAtLaunch forKey:@"disableAtLaunch"];
    [userDefaults synchronize];
    
}

// Check if it should disable at launch
+ (BOOL) isDisableAtLaunch {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"disableAtLaunch"];
}

// Get the run count
+ (NSInteger) runCount {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:@"runCount"];
}

// Store the run count
+ (void) storeRunCount:(NSInteger) value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:@"runCount"];
    [userDefaults synchronize];
}

// Never show pro message again
+ (BOOL) neverShowProMessage {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"neverShowProMessage"];
}

// Store never show going pro message
+ (void) storeNeverShowProMessage:(BOOL) value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:@"neverShowProMessage"];
    [userDefaults synchronize];
}

// Get selected locale
+ (NSString *) currentLocale {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:@"currentLocale"];
}

// Set selected locale
+ (void) storeCurrentLocale:(NSString *) value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:value forKey:@"currentLocale"];
    [userDefaults synchronize];
}

+ (BOOL) isStatusOnOffEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"isStatusOnOffEnabled"];
}

+ (void) storeStatusOnOffEnabled:(BOOL) value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:@"isStatusOnOffEnabled"];
    [userDefaults synchronize];
}

// Get refresh time
+ (NSInteger) sensorRefreshTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:@"sensorRefreshTime"];
}

// Store refresh time
+ (void) storeSensorRefreshTime:(NSInteger) value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:@"sensorRefreshTime"];
    [userDefaults synchronize];
}


@end
