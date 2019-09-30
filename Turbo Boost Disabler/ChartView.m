//
//  ChartView.m
//
//  Created by Rubén García Pérez on 3/2/18.
//  Copyright © 2018 rugarciap.com. All rights reserved.
//
#import "ChartView.h"

#define kOffsetX 30
#define kOffsetY 10
#define kStepX 20
#define kStepY 20
#define maxTicks 60; // 60 seconds at max on the chart

@implementation ChartView

@synthesize tempMode, delegate, isDarkMode;

- (void)drawRect:(NSRect)dirtyRect {
    
    // Depending on Dark mode status and availability, set background color
    self.isDarkMode = [self checkDarkMode];
    
    if (self.isDarkMode) {
        [[NSColor grayColor] setFill];
    } else {
        [[NSColor whiteColor] setFill];
    }
    
    // Set colors depending on dark mode status
    CGColorRef horizontalLinesColor = self.isDarkMode ? [[NSColor whiteColor] CGColor] : [[NSColor lightGrayColor] CGColor];
    CGColorRef axisColor = self.isDarkMode ? [[NSColor whiteColor] CGColor] : [[NSColor blackColor] CGColor];
    
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
    
    // Init tb on and off colors
    CGColorRef tbDisabledColor = [[NSColor colorWithSRGBRed:0.0f green:0.69f blue:0.95f alpha:1.0f] CGColor];
    CGColorRef tbEnabledColor = [[NSColor colorWithSRGBRed:1.0f green:0.56f blue:0.18f alpha:1.0f] CGColor];
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    // Now add the chart horizontal lines
    CGContextSetLineWidth(context, 0.6);
    CGContextSetStrokeColorWithColor(context, [[NSColor whiteColor] CGColor]);
    
    CGFloat dash[] = {3.0, 4.0};
    CGContextSetLineDash(context, 0.0, dash, 2);
    
    // Number of lines depending on mode
    int lines = 10;
    if (!tempMode) {
        lines = 14;
    }
    
    // Draw vertical line at the beginning
    float xAdjustment = 1.1f;
    if (!tempMode) {
        xAdjustment = 1.2f;
    }
    
    float stepY = dirtyRect.size.height / lines;
    
    for (int i = 0; i < (lines-1); i++)
    {
        CGFloat yPos = dirtyRect.size.height - kOffsetY - i * stepY;
        CGContextSetStrokeColorWithColor(context, horizontalLinesColor);
        CGContextMoveToPoint(context, kOffsetX*xAdjustment, yPos);
        CGContextAddLineToPoint(context, dirtyRect.size.width*0.97f, yPos);
        CGContextStrokePath(context);
        
    }
    
    // Ajustamos las coordenadas
    CGRect viewBounds = self.bounds;
    CGContextTranslateCTM(context, 0, viewBounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    float normalizer = 2;
    for (int i=0; i< (lines/normalizer) ; i++) {
        
        if (tempMode) {
            CGFloat yPos = dirtyRect.size.height - kOffsetY - i * stepY*normalizer - i*0.5f;
            NSString *text = [NSString stringWithFormat:@"%d", (i*20) + 20];
            if (i==4) {
                [self drawText:[text UTF8String] atX:5.0 andY:yPos withContext:context];
            } else {
                [self drawText:[text UTF8String] atX:12.0 andY:yPos withContext:context];
            }
        } else {
            
            CGFloat yPos = dirtyRect.size.height - kOffsetY - i * stepY*normalizer + i*0.5f;
            NSString *text = [NSString stringWithFormat:@"%d", (i*1000) + 1000];
            [self drawText:[text UTF8String] atX:5.0 andY:yPos withContext:context];
        }
    }
    
    // Y axis
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetStrokeColorWithColor(context, axisColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, kOffsetX*xAdjustment, dirtyRect.size.height - kOffsetY * 0.2f );
    CGContextAddLineToPoint(context, kOffsetX*xAdjustment, dirtyRect.size.height - kOffsetY - 0.9f * lines * stepY);
    CGContextStrokePath(context);
    
    // X axis
    CGFloat yPos = dirtyRect.size.height - kOffsetY*0.5;
    CGContextSetStrokeColorWithColor(context, axisColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, kOffsetX*xAdjustment*0.93f, yPos);
    CGContextAddLineToPoint(context, dirtyRect.size.width*0.97f, yPos);
    CGContextStrokePath(context);
    
    // Calc tick depending on width
    int tickSize = dirtyRect.size.width / maxTicks;
    
    // Recover the data depending on the current mode
    NSMutableArray *data = nil;
    if (tempMode) {
        data = [delegate getTempData];
    } else {
        data = [delegate getFanData];
    }
    
    if ((data == nil)||([data count] == 0)) {
        return;
    }
    
    ChartDataEntry *entry = [data objectAtIndex:0];
    
    if (entry.isTbEnabled) {
        CGContextSetStrokeColorWithColor(context, tbEnabledColor);
    } else {
        CGContextSetStrokeColorWithColor(context, tbDisabledColor);
    }
    
    // Paint the corresponding data
    for (int i=1; i<[data count]; i++) {
        
        ChartDataEntry *entry = [data objectAtIndex:i];
        ChartDataEntry *previousEntry = [data objectAtIndex:(i-1)];
        
        CGContextSetLineWidth(context, 2.0f);
        CGContextBeginPath(context);
        
        if (tempMode) {
            CGContextMoveToPoint(context, kOffsetX*xAdjustment + (i-1)*tickSize,
                             dirtyRect.size.height - [self heightWithRect:dirtyRect andTemp:previousEntry.value]);
        } else {
            CGContextMoveToPoint(context, kOffsetX*xAdjustment + (i-1)*tickSize,
                                 dirtyRect.size.height - [self heightWithRect:dirtyRect andFanSpeed:previousEntry.value]);
        }
        if (entry.isTbEnabled) {
            CGContextSetStrokeColorWithColor(context, tbEnabledColor);
        } else {
            CGContextSetStrokeColorWithColor(context, tbDisabledColor);
        }
        
        float height = 0;
        if (tempMode) {
            height = dirtyRect.size.height - [self heightWithRect:dirtyRect andTemp:entry.value];
        } else {
            height = dirtyRect.size.height - [self heightWithRect:dirtyRect andFanSpeed:entry.value];
        }
        CGContextAddLineToPoint(context, kOffsetX*xAdjustment + i*tickSize, height);
        
        CGContextStrokePath(context);
    }
    
    CGContextFlush(context);
}

// Draw text method
- (void) drawText:(char *) text atX:(CGFloat) xPos andY:(CGFloat) yPos withContext:(CGContextRef) context {
    
    if (self.isDarkMode)  {
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    } else {
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    }
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSelectFont(context, "Helvetica", 10.0, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing(context, 1.7);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGAffineTransform currentTransform = CGContextGetTextMatrix(context);
    CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(context, transform);
    CGContextShowTextAtPoint(context, xPos, yPos, text, strlen(text));
    
    CGContextSetTextMatrix(context, currentTransform);
    CGContextStrokePath(context);
    
}


// Height depending on temperature value (max 100)
- (float) heightWithRect:(CGRect) rect andTemp:(float) temp {

    float returnValue = (temp / 100) * rect.size.height - 2*kOffsetY;
    return returnValue;
}

// Height depending on fan value (max 7000)
- (float) heightWithRect:(CGRect) rect andFanSpeed:(float) fanSpeed {
    float returnValue = (fanSpeed / 7000) * rect.size.height - kOffsetY;
    return returnValue;
}

- (BOOL) checkDarkMode {
    NSAppearance *appearance = NSAppearance.currentAppearance;
    if (@available(*, macOS 10.14)) {
        return appearance.name == NSAppearanceNameDarkAqua || appearance.name == NSAppearanceNameVibrantDark;
    }
    
    return NO;
}

@end
