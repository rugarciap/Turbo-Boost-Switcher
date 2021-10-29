//
//  HotKeysWindowController.h
//  Turbo Boost Switcher Pro
//
//  Created by Rubén García Pérez on 10/9/21.
//  Copyright © 2021 Rubén García Pérez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HotKeysConfigDelegate <NSObject>

// Enable - Disable hotkey
- (void) enableDisableHotKey;

@end

@interface HotKeysWindowController : NSWindowController {
    
    IBOutlet NSButton *checkEnableHotkeys;
    IBOutlet NSButton *btnClose;
    
    // Hotkey to enable / disable TB
    IBOutlet NSButton *checkCtrlTB;
    IBOutlet NSButton *checkShiftTB;
    IBOutlet NSButton *checkCmdTB;
    IBOutlet NSTextField *lblTB;
    IBOutlet NSComboBox *cmbKeysTB;
    IBOutlet NSTextField *lblTBFinalConfig;
    
    // Hotkey to enable / disable Chart
    IBOutlet NSButton *checkCtrlChart;
    IBOutlet NSButton *checkShiftChart;
    IBOutlet NSButton *checkCmdChart;
    IBOutlet NSTextField *lblChart;
    IBOutlet NSComboBox *cmbKeysChart;
    IBOutlet NSTextField *lblChartFinalConfig;
    
    NSMutableDictionary *keysDict;
    id <HotKeysConfigDelegate> delegate;
    
}
@property (nonatomic) id <HotKeysConfigDelegate> delegate;

- (void) refreshLabelForTB;

- (void) refreshLabelForCharting;

- (NSString *) labelForCtrl:(BOOL) ctrl withShift:(BOOL) shift andCmd:(BOOL) cmd forKey:(NSString *) key;

- (IBAction) refreshTBConfiguration:(id)sender;

@end

NS_ASSUME_NONNULL_END
