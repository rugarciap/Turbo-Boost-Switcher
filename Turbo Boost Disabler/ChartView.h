//
//  ChartView.h
//  Turbo Boost Switcher Pro
//
//  Created by Rubén García Pérez on 7/4/18.
//  Copyright © 2018 Rubén García Pérez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChartDataDelegate.h"

@interface ChartView : NSView {
    
    BOOL tempMode; // Temperature mode (true) or not (fan)..., in the future might change due to more charting types.
    id <ChartDataDelegate> delegate; // The data delegate

}

@property (nonatomic) id <ChartDataDelegate> delegate;
@property (nonatomic) BOOL tempMode;

@end
