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

- (BOOL) runProcess:(NSString*)scriptPath
      withArguments:(NSArray *)arguments
             output:(NSString **)output
   errorDescription:(NSString **)errorDescription
    asAdministrator:(BOOL) isAdministrator;

- (BOOL) loadModule;

- (BOOL) unLoadModule;

- (BOOL) isModuleLoaded;

- (BOOL) is32bits;

- (float) readCurrentCpuTemp;

- (int) readCurrentFanSpeed;
 

@end
