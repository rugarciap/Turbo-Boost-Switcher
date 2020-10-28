//
//  StartupHelper.h
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

#import <Foundation/Foundation.h>

@interface StartupHelper : NSObject {
    
}

+ (BOOL) isOpenAtLogin;

+ (void) setOpenAtLogin:(BOOL) isOpenAtLogin;

+ (void) setDisableAtLaunch:(BOOL) disableAtLaunch;

+ (BOOL) isDisableAtLaunch;

// Check for updates on start
+ (BOOL) isCheckUpdatesOnStart;

// Store check for updates on start
+ (void) storeCheckUpdatesOnStart:(BOOL) value;

// Get the run count
+ (NSInteger) runCount;

// Store the run count
+ (void) storeRunCount:(NSInteger) value;

// Never show pro message again
+ (BOOL) neverShowProMessage;

// Store never show going pro message
+ (void) storeNeverShowProMessage:(BOOL) value;

// Get selected locale
+ (NSString *) currentLocale;

// Set selected locale
+ (void) storeCurrentLocale:(NSString *) value;

// Get Status bar on off
+ (BOOL) isStatusOnOffEnabled;

// Store status bar on off value
+ (void) storeStatusOnOffEnabled:(BOOL) value;

// Get / Store refersh time
+ (NSInteger) sensorRefreshTime;
+ (void) storeSensorRefreshTime:(NSInteger) value;

// Monitoring enabled / disabled
+ (BOOL) isMonitoringEnabled;
+ (void) storeMonitoringEnabled: (BOOL) value;

    
@end
