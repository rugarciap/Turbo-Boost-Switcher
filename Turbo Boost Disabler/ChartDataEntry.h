//
//  ChartDataEntry.h
//
//  Created by Rubén García Pérez on 21/2/18.
//  Copyright © 2018 rugarciap.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartDataEntry : NSObject {
    
    float value; // Registered value (temp / fan speed...)
    BOOL isTbEnabled; // Turbo Boost is disabled or not
}

@property (nonatomic) float value;
@property (nonatomic) BOOL isTbEnabled;

@end
