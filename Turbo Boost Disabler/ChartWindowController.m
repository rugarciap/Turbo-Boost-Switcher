//
//  ChartWindowController.m
//  Turbo Boost Switcher Pro
//
//  Created by Rubén García Pérez on 8/4/18.
//  Copyright © 2018 Rubén García Pérez. All rights reserved.
//

#import "ChartWindowController.h"
#import "ChartDataEntry.h"
#import "SystemCommands.h"

@interface ChartWindowController ()

@end

@implementation ChartWindowController

@synthesize fanChartView, tempChartView, txtFanSpeed, txtTemperature, isOpen, isFahrenheit, cpuLoadChartView, cpuFreqChartView, txtCpuFreq, txtCpuLoad;

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    self.window.delegate = self;
    [self.window setTitle:NSLocalizedString(@"titCharting", nil)];
    
    self.isOpen = YES;
    
    self.tempChartView.chartMode = kTempMode;
    self.tempChartView.minValue = 0;
    self.tempChartView.maxValue = 100;
    self.tempChartView.lines = 10;
    self.tempChartView.step = 20;
    
    self.fanChartView.chartMode = kFanMode;
    self.fanChartView.minValue = 0;
    self.fanChartView.maxValue = 7000;
    self.fanChartView.lines = 14;
    self.fanChartView.step = 1000;
    
    self.tempChartView.delegate = self;
    self.fanChartView.delegate = self;
    
    [lblTemperature setStringValue:NSLocalizedString(@"lblTemperature", nil)];
    [lblFanSpeed setStringValue:NSLocalizedString(@"lblFanSpeed", nil)];
    
    [lblTbEnabledTemp setStringValue:NSLocalizedString(@"lblTbEnabled", nil)];
    [lblTbDisabledTemp setStringValue:NSLocalizedString(@"lblTbDisabled", nil)];
    
    [self.tempChartView setNeedsDisplay:YES];
    [self.fanChartView setNeedsDisplay:YES];
    
    // 2.12.0 - CPU Load and Frequency
    self.cpuLoadChartView.chartMode = kCpuLoadMode;
    self.cpuLoadChartView.minValue = 0;
    self.cpuLoadChartView.maxValue = 100;
    self.cpuLoadChartView.lines = 10;
    self.cpuLoadChartView.step = 20;
    
    self.cpuFreqChartView.chartMode = kCpuFreqMode;
    float baseFreq = [SystemCommands getBaseFreq];
    float maxFreq = baseFreq > 0.0f ? roundf((baseFreq * 2) + 0.5f) : 0.0f;
    int lines = (int) maxFreq * 2;
    self.cpuFreqChartView.lines = lines;
    self.cpuFreqChartView.minValue = 0;
    self.cpuFreqChartView.maxValue = maxFreq;
    self.cpuFreqChartView.step = 1.0f;
    self.cpuFreqChartView.marker = baseFreq;
    
    self.cpuLoadChartView.delegate = self;
    self.cpuFreqChartView.delegate = self;
    
    [lblCpuLoad setStringValue:NSLocalizedString(@"lblCpuLoad", nil)];
    [lblCpuFreq setStringValue:NSLocalizedString(@"lblCpuFreq", nil)];
       
    [self.cpuLoadChartView setNeedsDisplay:YES];
    [self.cpuFreqChartView setNeedsDisplay:YES];
}

- (void) initData {
    self.isOpen = NO;
    tempEntries = [[NSMutableArray alloc] init];
    fanEntries = [[NSMutableArray alloc] init];
    cpuLoadEntries = [[NSMutableArray alloc] init];
    cpuFreqEntries = [[NSMutableArray alloc] init];
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
    if (self.isOpen) {
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
    
    if (self.isOpen) {
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

// Method to get the cpu freq data
- (NSMutableArray *) getCpuFreqData {
    return cpuFreqEntries;
}

// Check if is farenheit
- (BOOL) isFahrenheit {
    return isFahrenheit;
}

- (IBAction)showWindow:(nullable id)sender {
    [super showWindow:sender];
    [self.tempChartView setNeedsDisplay:YES];
    [self.fanChartView setNeedsDisplay:YES];

    // 2.12.0 - Refresh new chart views
    [self.cpuLoadChartView setNeedsDisplay:YES];
    [self.cpuFreqChartView setNeedsDisplay:YES];
}
// 2.12.0 - Method to get the cpu load data
- (NSMutableArray *) getCpuLoadData {
    return cpuLoadEntries;
}

// 2.12.0 - CPU Load
- (void) addCpuLoadEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue {
    
    [cpuLoadEntries addObject:entry];
    if ([cpuLoadEntries count] > 60) {
        [cpuLoadEntries removeObjectAtIndex:0];
    }
    
    if (self.isOpen) {
        [txtCpuLoad setStringValue:strValue];
        [self.cpuLoadChartView setNeedsDisplay:YES];
    }
}

- (void) addCpuFreqEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue {
    
    [cpuFreqEntries addObject:entry];
    if ([cpuFreqEntries count] > 60) {
        [cpuFreqEntries removeObjectAtIndex:0];
    }
    
    if (self.isOpen) {
        [txtCpuFreq setStringValue:strValue];
        [self.cpuFreqChartView setNeedsDisplay:YES];
    }
    
}

// Default charting help
- (IBAction) displayChartingHelp:(id)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert.window setTitle:@"Turbo Boost Switcher Pro"];
   
    [self.window setLevel:NSNormalWindowLevel];
    [alert.window setLevel:NSStatusWindowLevel];
   
    [alert setMessageText:NSLocalizedString(@"helpCharting", nil)];
    [alert runModal];
   
    [self.window setLevel:NSStatusWindowLevel];
}

@end
