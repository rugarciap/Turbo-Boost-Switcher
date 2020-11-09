//
//  ChartDataDelegate.h
//
//  Created by Rubén García Pérez on 21/2/18.
//  Copyright © 2018 rugarciap.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartDataEntry.h"

@protocol ChartDataDelegate <NSObject>

// Method to get the temperature data
- (NSMutableArray *) getTempData;

// Method to get the fan data
- (NSMutableArray *) getFanData;

// Check if is farenheit
- (BOOL) isFahrenheit;

@end
