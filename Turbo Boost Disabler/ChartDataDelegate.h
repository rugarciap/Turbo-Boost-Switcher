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

// Method to get the cpu load data
- (NSMutableArray *) getCpuLoadData;

// Method to get the cpu freq data
- (NSMutableArray *) getCpuFreqData;

// Check if is fahrenheit
- (BOOL) isFahrenheit;

@end
