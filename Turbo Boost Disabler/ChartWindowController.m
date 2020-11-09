//
//  ChartWindowController.m
//  Turbo Boost Switcher Pro
//
//  Created by Rubén García Pérez on 8/4/18.
//  Copyright © 2018 Rubén García Pérez. All rights reserved.
//

#import "ChartWindowController.h"
#import "ChartDataEntry.h"

@interface ChartWindowController ()

@end

@implementation ChartWindowController

@synthesize fanChartView, tempChartView, txtFanSpeed, txtTemperature, isOpen, isFahrenheit;

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    self.window.delegate = self;
    [self.window setTitle:NSLocalizedString(@"titCharting", nil)];
    
    self.isOpen = YES;
    
    self.tempChartView.tempMode = YES;
    self.fanChartView.tempMode = NO;
    
    self.tempChartView.delegate = self;
    self.fanChartView.delegate = self;
    
    [lblTemperature setStringValue:NSLocalizedString(@"lblTemperature", nil)];
    [lblFanSpeed setStringValue:NSLocalizedString(@"lblFanSpeed", nil)];
    
    [lblTbEnabledFan setStringValue:NSLocalizedString(@"lblTbEnabled", nil)];
    [lblTbDisabledFan setStringValue:NSLocalizedString(@"lblTbDisabled", nil)];
    [lblTbEnabledTemp setStringValue:NSLocalizedString(@"lblTbEnabled", nil)];
    [lblTbDisabledTemp setStringValue:NSLocalizedString(@"lblTbDisabled", nil)];
    
    [self.tempChartView setNeedsDisplay:YES];
    [self.fanChartView setNeedsDisplay:YES];
    
}

- (void) initData {
    isOpen = NO;
    tempEntries = [[NSMutableArray alloc] init];
    fanEntries = [[NSMutableArray alloc] init];
}

- (void)windowWillClose:(NSNotification *)notification {
    self.isOpen = NO;
}

// Method to add the temperature entry
- (void) addTempEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue {

    [tempEntries addObject:entry];
    if ([tempEntries count] > 60) {
        [tempEntries removeObjectAtIndex:0];
    }
    if (isOpen) {
        [txtTemperature setStringValue:strValue];
        [self.tempChartView setNeedsDisplay:YES];
    }
}

// Method to add the fan entry
- (void) addFanEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue {
    
    [fanEntries addObject:entry];
    if ([fanEntries count] > 60) {
        [fanEntries removeObjectAtIndex:0];
    }
    
    if (isOpen) {
        [txtFanSpeed setStringValue:strValue];
        [self.fanChartView setNeedsDisplay:YES];
    }
}

// Method to get the temperature data
- (NSMutableArray *) getTempData {
    return tempEntries;
}

// Method to get the fan data
- (NSMutableArray *) getFanData {
    return fanEntries;
}

// Check if is farenheit
- (BOOL) isFahrenheit {
    return isFahrenheit;
}

- (IBAction)showWindow:(nullable id)sender {
    [super showWindow:sender];
    [self.tempChartView setNeedsDisplay:YES];
    [self.fanChartView setNeedsDisplay:YES];

}
@end
