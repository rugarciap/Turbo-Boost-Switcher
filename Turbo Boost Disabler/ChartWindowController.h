//
//  ChartWindowController.h
//  Turbo Boost Switcher Pro
//
//  Created by Rubén García Pérez on 8/4/18.
//  Copyright © 2018 Rubén García Pérez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import "ChartDataDelegate.h"

@interface ChartWindowController : NSWindowController <ChartDataDelegate, NSWindowDelegate> {
    
    IBOutlet ChartView *tempChartView;
    IBOutlet ChartView *fanChartView;
   
    IBOutlet NSTextField *txtTemperature;
    IBOutlet NSTextField *txtFanSpeed;
    
    IBOutlet NSTextField *lblTemperature;
    IBOutlet NSTextField *lblFanSpeed;
    
    IBOutlet NSTextField *lblTbEnabledTemp;
    IBOutlet NSTextField *lblTbDisabledTemp;
    
    NSMutableArray *tempEntries;
    NSMutableArray *fanEntries;
    
    BOOL isOpen;
    BOOL isFahrenheit;
    
    // 2.12.0 - CPU Load and Frequency Charting
    IBOutlet ChartView *cpuLoadChartView;
    IBOutlet ChartView *cpuFreqChartView;
    
    IBOutlet NSTextField *txtCpuLoad;
    IBOutlet NSTextField *txtCpuFreq;
    
    IBOutlet NSTextField *lblCpuLoad;
    IBOutlet NSTextField *lblCpuFreq;

    NSMutableArray *cpuLoadEntries;
    NSMutableArray *cpuFreqEntries;
    
    IBOutlet NSTextField *lblNoData;
    
}

@property (nonatomic) IBOutlet ChartView *tempChartView;
@property (nonatomic) IBOutlet ChartView *fanChartView;

@property (nonatomic) IBOutlet NSTextField *txtTemperature;
@property (nonatomic) IBOutlet NSTextField *txtFanSpeed;

@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL isFahrenheit;

// 2.12.0 - CPU Load and Frequency Charting
@property (nonatomic) IBOutlet ChartView *cpuLoadChartView;
@property (nonatomic) IBOutlet ChartView *cpuFreqChartView;

@property (nonatomic) IBOutlet NSTextField *txtCpuFreq;
@property (nonatomic) IBOutlet NSTextField *txtCpuLoad;

// Method to add the temperature entry
- (void) addTempEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue;

// Method to add the fan entry
- (void) addFanEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue;

- (void) initData;

// 2.12.0 - Add CPU Load entry
- (void) addCpuLoadEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue;

- (void) addCpuFreqEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue;

- (IBAction) displayChartingHelp:(id)sender;

@end
