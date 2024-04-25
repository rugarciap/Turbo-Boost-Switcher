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

@synthesize chartMode, delegate, isDarkMode, minValue,maxValue, lines, step, marker;

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
       
    // Draw vertical line at the beginning
    float xAdjustment = 1.0f;
    if (chartMode == kFanMode) {
        xAdjustment = 1.2f;
    }
    
    float stepY = (dirtyRect.size.height - 1.3f*kOffsetY) / lines;
    
    // Ajustamos las coordenadas
    CGRect viewBounds = self.bounds;
    CGContextTranslateCTM(context, 0, viewBounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    // Draw horizontal dashed lines
    for (int i = 1; i <= (lines); i++)
    {
        CGFloat yPos = dirtyRect.size.height - kOffsetY*0.5f - i * stepY;
        CGContextSetStrokeColorWithColor(context, horizontalLinesColor);
        CGContextMoveToPoint(context, kOffsetX*xAdjustment, yPos);
        CGContextAddLineToPoint(context, dirtyRect.size.width*0.97f, yPos);
        CGContextStrokePath(context);
    }
        
    // Draw Y axis labels
    for (int i=0; i < 0.5*lines ; i++) {
        
        CGFloat yPos = dirtyRect.size.height - kOffsetY*0.25f - (i+1)*stepY*2 ;
        int value = (i*self.step) + self.step;
                  
        NSString *text = nil;
    
        if (chartMode == kFanMode) {
            text = [NSString stringWithFormat:@"%.00f", (i*self.step) + self.step];
        } else if (chartMode == kCpuFreqMode) {
            text = [NSString stringWithFormat:@"%.01f", (i*self.step) + self.step];
        } else {
            text = [NSString stringWithFormat:@"%d", value];
        }
    
        if ((chartMode == kCpuLoadMode) || (chartMode == kTempMode)) {
            if (i==4) {
                [self drawText:[text UTF8String] atX:5.0 andY:yPos withContext:context];
            } else {
                [self drawText:[text UTF8String] atX:12.0 andY:yPos withContext:context];
            }
        } else {
            [self drawText:[text UTF8String] atX:5.0 andY:yPos withContext:context];
        }
    }
    
    // Y axis
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetStrokeColorWithColor(context, axisColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, kOffsetX*xAdjustment, dirtyRect.size.height - kOffsetY * 0.2f );
    CGContextAddLineToPoint(context, kOffsetX*xAdjustment, kOffsetY*0.5f);
    CGContextStrokePath(context);
    
    // X axis
    CGFloat yPos = dirtyRect.size.height - kOffsetY*0.5;
    CGContextSetStrokeColorWithColor(context, axisColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, kOffsetX*xAdjustment*0.93f, yPos);
    CGContextAddLineToPoint(context, dirtyRect.size.width*0.97f, yPos);
    CGContextStrokePath(context);
    
    // Marker
    if (self.marker > 0) {
        CGFloat newYPos = [self heightWithRect:dirtyRect andValue:self.marker];
        CGContextSetStrokeColorWithColor(context, axisColor);
        CGContextSetLineWidth(context, 0.6f);
        CGContextMoveToPoint(context, kOffsetX*xAdjustment*0.97f, newYPos);
        CGContextAddLineToPoint(context, dirtyRect.size.width*0.97f, newYPos);
        CGContextStrokePath(context);
    }
    
    // Calc tick depending on width
    int tickSize = dirtyRect.size.width / maxTicks;
    
    // Recover the data depending on the current mode
    NSMutableArray *data = nil;
    if (chartMode == kTempMode) {
        data = [delegate getTempData];
    } else if (chartMode == kCpuLoadMode){
        data = [delegate getCpuLoadData];
    } else if (chartMode == kCpuFreqMode){
        data = [delegate getCpuFreqData];
    } else {
        data = [delegate getFanData];
    }
    
    if ((data == nil) || ([data count] == 0)) {
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
        
        if (entry.value >= 0) {
            
            float previousValue = previousEntry.value >= 0.0f ? previousEntry.value : entry.value;
            
            CGContextSetLineWidth(context, 2.0f);
            CGContextBeginPath(context);
            
            CGContextMoveToPoint(context, kOffsetX*xAdjustment + (i-1)*tickSize,
                              [self heightWithRect:dirtyRect andValue:previousValue]);
         
            if (entry.isTbEnabled) {
                CGContextSetStrokeColorWithColor(context, tbEnabledColor);
            } else {
                CGContextSetStrokeColorWithColor(context, tbDisabledColor);
            }
            
            float height = [self heightWithRect:dirtyRect andValue:entry.value];
            
            CGContextAddLineToPoint(context, kOffsetX*xAdjustment + i*tickSize, height);
            CGContextStrokePath(context);
        
        } else {
        
            // Draw grey box (no data available)
            CGRect rectangle = CGRectMake(kOffsetX*xAdjustment + (i-1)*tickSize, kOffsetY*0.5f, tickSize, dirtyRect.size.height - kOffsetY);
            CGContextSetRGBFillColor(context, 0.4, 0.4, 0.4, 0.3);
            CGContextSetRGBStrokeColor(context, 0.4, 0.4, 0.4, 0.3);
            CGContextFillRect(context, rectangle);
        }
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

// Height depending on max value
- (float) heightWithRect:(CGRect) rect andValue:(float) value {
    return rect.size.height - 0.5f*kOffsetY - (value/maxValue)*(rect.size.height - 1.3f*kOffsetY);
}

- (BOOL) checkDarkMode {
    NSAppearance *appearance = NSAppearance.currentAppearance;
    if (@available(*, macOS 10.14)) {
        return appearance.name == NSAppearanceNameDarkAqua || appearance.name == NSAppearanceNameVibrantDark;
    }
    
    return NO;
}


@end
