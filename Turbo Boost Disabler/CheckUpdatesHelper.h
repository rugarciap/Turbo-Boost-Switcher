//
//  CheckUpdatesWindowController.h
//  Turbo Boost Switcher
//
//  Created by Rubén García Pérez on 18/09/16.
//  Copyright © 2016 Rubén García Pérez. All rights reserved.
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

@protocol CheckUpdatesHelperDelegate <NSObject>

// Error
- (void) errorCheckingUpdate;

// Update available
- (void) updateAvailable;

// Update not available
- (void) updateNotAvailable;

@end

@interface CheckUpdatesHelper : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    id <CheckUpdatesHelperDelegate> delegate;
    NSMutableData *contents;
}

// Check for updates
- (void) checkUpdatesWithDelegate:(id <CheckUpdatesHelperDelegate>) _delegate;

@end
