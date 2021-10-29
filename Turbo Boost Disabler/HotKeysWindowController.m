//
//  HotKeysWindowController.m
//  Turbo Boost Switcher Pro
//
//  Created by Rubén García Pérez on 10/9/21.
//  Copyright © 2021 Rubén García Pérez. All rights reserved.
//

#import "HotKeysWindowController.h"
#import "StartupHelper.h"
#import "Carbon/Carbon.h"
@interface HotKeysWindowController ()

@end

@implementation HotKeysWindowController

@synthesize delegate;

- (IBAction)showWindow:(id)sender
{
    [super showWindow:sender];
    [self refreshState];
}
- (void)windowDidLoad {
    [super windowDidLoad];
    
    [lblTB setStringValue:NSLocalizedString(@"lblTB", nil)];
    [lblChart setStringValue:NSLocalizedString(@"lblChart", nil)];
    [checkEnableHotkeys setTitle:NSLocalizedString(@"checkEnableHotkeys", nil)];
}

- (void) refreshState {
    
    // Init the dictionary
    // Load all available keys for hotkeys (map from A to B)
    NSString *keyList = @"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z";
    NSArray *keysArray = [keyList componentsSeparatedByString:@","];
    
    [cmbKeysTB removeAllItems];
    [cmbKeysChart removeAllItems];
    
    [cmbKeysTB addItemsWithObjectValues: keysArray];
    [cmbKeysChart addItemsWithObjectValues: keysArray];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSMutableArray *turboHotKey = [StartupHelper turboBoostHotKey];
    NSMutableArray *chartHotKey = [StartupHelper chartHotKey];
    BOOL enableHotKeys = [StartupHelper isHotKeysEnabled];
    
    // Update GUI
    [checkEnableHotkeys setState:enableHotKeys];
    
    [checkCtrlTB setState:([[turboHotKey objectAtIndex:0] isEqualTo:@"1"])];
    [checkShiftTB setState:([[turboHotKey objectAtIndex:1] isEqualTo:@"1"])];
    [checkCmdTB setState:([[turboHotKey objectAtIndex:2] isEqualTo:@"1"])];
    [cmbKeysTB selectItemWithObjectValue:[turboHotKey objectAtIndex:3]];
    
    [checkCtrlChart setState:([[chartHotKey objectAtIndex:0] isEqualTo:@"1"])];
    [checkShiftChart setState:([[chartHotKey objectAtIndex:1] isEqualTo:@"1"])];
    [checkCmdChart setState:([[chartHotKey objectAtIndex:2] isEqualTo:@"1"])];
    [cmbKeysChart selectItemWithObjectValue:[chartHotKey objectAtIndex:3]];
    
    [self refreshLabelForTB];
    [self refreshLabelForCharting];
    
    [self refreshHotKeyEnabledConfig];
}

- (IBAction) enableHotKeysAction:(id)sender {
    [self refreshHotKeyEnabledConfig];
}

- (void) refreshHotKeyEnabledConfig {
    [checkCtrlTB setEnabled:checkEnableHotkeys.state];
    [checkShiftTB setEnabled:checkEnableHotkeys.state];
    [checkCmdTB setEnabled:checkEnableHotkeys.state];
    [checkCtrlChart setEnabled:checkEnableHotkeys.state];
    [checkShiftChart setEnabled:checkEnableHotkeys.state];
    [checkCmdChart setEnabled:checkEnableHotkeys.state];
    [cmbKeysTB setEnabled:checkEnableHotkeys.state];
    [cmbKeysChart setEnabled:checkEnableHotkeys.state];
    [lblTBFinalConfig setHidden:!checkEnableHotkeys.state];
    [lblChartFinalConfig setHidden:!checkEnableHotkeys.state];
}

- (IBAction) refreshTBConfiguration:(id)sender {
    [self refreshLabelForTB];
}

- (IBAction) refreshChartConfiguration:(id)sender {
    [self refreshLabelForCharting];
}

- (IBAction) cancel:(id)sender {
    [self close];
}

- (BOOL) validate {
    
    BOOL tbValid = checkCtrlTB.state || checkShiftTB.state || checkCmdTB.state;
    BOOL chartValid = checkCtrlChart.state || checkShiftChart.state || checkCmdChart.state;
    
    NSString *keyTb = [cmbKeysTB objectValueOfSelectedItem];
    NSString *keyChart = [cmbKeysChart objectValueOfSelectedItem];
    
    tbValid = tbValid && (keyTb != nil) && ([keyTb length] > 0);
    chartValid = chartValid && (keyChart != nil) && ([keyChart length] > 0);
    
    return tbValid && chartValid;
}

- (IBAction) apply:(id)sender {
    
    if (!checkEnableHotkeys.state) {
        
        [StartupHelper storeHotKeysEnabled:NO];
        [delegate enableDisableHotKey];
        [self close];
        return;
    }
    
    if (![self validate]) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [self.window setLevel:NSNormalWindowLevel];
        [alert.window setLevel:NSStatusWindowLevel];
        [alert.window setTitle:@"Turbo Boost Switcher"];
        [alert setMessageText:NSLocalizedString(@"hotKeyValidateKo", nil)];
        [alert runModal];
        [self.window setLevel:NSStatusWindowLevel];
        return;
    }
    
    [self saveConfig];
    [StartupHelper storeHotKeysEnabled:YES];
    [delegate enableDisableHotKey];
    [self close];
}

- (void) saveConfig {
 
    [StartupHelper storeHotKeysEnabled:YES];
    
    NSMutableArray *tbConfig = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray *chartConfig = [[NSMutableArray alloc] initWithCapacity:4];
    
    [tbConfig addObject:checkCtrlTB.state ? @"1" : @"0"];
    [tbConfig addObject:checkShiftTB.state ? @"1" : @"0"];
    [tbConfig addObject:checkCmdTB.state ? @"1" : @"0"];
    [tbConfig addObject:[cmbKeysTB objectValueOfSelectedItem]];
    
    [chartConfig addObject:checkCtrlChart.state ? @"1" : @"0"];
    [chartConfig addObject:checkShiftChart.state ? @"1" : @"0"];
    [chartConfig addObject:checkCmdChart.state ? @"1" : @"0"];
    [chartConfig addObject:[cmbKeysChart objectValueOfSelectedItem]];
    
    [StartupHelper storeTurboBoostHotKey:tbConfig];
    [StartupHelper storeChartHotKey:chartConfig];

}

- (void) refreshLabelForTB {
    NSString *theLabel = [self labelForCtrl:checkCtrlTB.state withShift:checkShiftTB.state andCmd:checkCmdTB.state forKey:[cmbKeysTB objectValueOfSelectedItem]];
    [lblTBFinalConfig setStringValue:theLabel];
}

- (void) refreshLabelForCharting {
    NSString *theLabel = [self labelForCtrl:checkCtrlChart.state withShift:checkShiftChart.state andCmd:checkCmdChart.state forKey:[cmbKeysChart objectValueOfSelectedItem]];
    [lblChartFinalConfig setStringValue:theLabel];
}

- (NSString *) labelForCtrl:(BOOL) ctrl withShift:(BOOL) shift andCmd:(BOOL) cmd forKey:(NSString *) key {

    NSString *label = @"";
    if (ctrl) {
        label = [label stringByAppendingString:@"^"];
    }
    if (shift) {
        label = [label stringByAppendingString:@"\u21E7"];
    }
    if (cmd) {
        label = [label stringByAppendingString:@"\u2318"];
    }
    
    if (key != nil) {
        label = [label stringByAppendingString:key];
    }
    return label;
}

@end
