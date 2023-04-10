//
//  ChartView.h
//  Turbo Boost Switcher 
//
//  Created by Rubén García Pérez on 7/4/18.
//  Copyright © 2018 Rubén García Pérez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChartDataDelegate.h"

#define kTempMode 0
#define kFanMode 1
#define kCpuLoadMode 2
#define kCpuFreqMode 3

@interface ChartView : NSView {
    
    int chartMode; // Charting type
    BOOL isDarkMode;
    id <ChartDataDelegate> delegate; // The data delegate
        
    int lines;
    float minValue;
    float maxValue;
    float step;
    float marker;

}

@property (nonatomic) id <ChartDataDelegate> delegate;
@property (nonatomic) int chartMode;
@property (nonatomic) BOOL isDarkMode;
@property (nonatomic) float minValue;
@property (nonatomic) float maxValue;
@property (nonatomic) int lines;
@property (nonatomic) float step;
@property (nonatomic) float marker;

@end
