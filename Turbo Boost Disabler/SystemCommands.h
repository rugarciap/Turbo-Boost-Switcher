//
//  SystemCommands.h
//  Turbo Boost Switcher
//
//  Created by Rubén García Pérez on 20/07/13.
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
#import "smc.h"

@interface SystemCommands : NSObject {
    
}

+ (BOOL) runProcess:(NSString*)scriptPath
      withArguments:(NSArray *)arguments
             output:(NSString **)output
   errorDescription:(NSString **)errorDescription
    asAdministrator:(BOOL) isAdministrator;

+ (BOOL) loadModuleWithAuthRef:(AuthorizationRef) authRef;

+ (BOOL) unLoadModuleWithAuthRef:(AuthorizationRef) authRef;

+ (BOOL) is32bits;

+ (BOOL) isModuleLoaded;

+ (BOOL) isModuleLoadedNewOS;

+ (BOOL) isModuleLoadedOldOS;

+ (BOOL) is32bitsNewOS;

+ (BOOL) is32bitsOldOS;

+ (NSString *) getOSVersion;

+ (float) readCurrentCpuTemp;

+ (int) readCurrentFanSpeed;

+ (BOOL) runTaskAsAdmin:(NSString *) path withAuthRef:(AuthorizationRef) authRef andArgs:(NSArray *) args;

// Get the module path depending on arch
+ (NSString *) getModulePath:(BOOL) is32bits;

// 2.12.0 - Read CPU Frequency with auth ref
+ (float) readCurrentCpuFreqWithAuthRef:(AuthorizationRef) authRef;

// Get base frequency as GHz
+ (float) getBaseFreq;

@end
