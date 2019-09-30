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
    IBOutlet NSTextField *lblTbEnabledFan;
    IBOutlet NSTextField *lblTbDisabledFan;
    
    NSMutableArray *tempEntries;
    NSMutableArray *fanEntries;
    
    BOOL isOpen;
    
}

@property (nonatomic) IBOutlet ChartView *tempChartView;
@property (nonatomic) IBOutlet ChartView *fanChartView;

@property (nonatomic) IBOutlet NSTextField *txtTemperature;
@property (nonatomic) IBOutlet NSTextField *txtFanSpeed;

@property (nonatomic) BOOL isOpen;

// Method to add the temperature entry
- (void) addTempEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue;

// Method to add the fan entry
- (void) addFanEntry:(ChartDataEntry *) entry withCurrentValue:(NSString *) strValue;

- (void) initData;


@end
