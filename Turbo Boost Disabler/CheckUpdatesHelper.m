//
//  CheckUpdatesHelper.m
//  Turbo Boost Switcher Pro
//
//  Created by Rubén García Pérez on 18/09/16.
//  Copyright © 2016 Rubén García Pérez. All rights reserved.
//

#import "CheckUpdatesHelper.h"

#define CURRENT_VERSION 280

@implementation CheckUpdatesHelper {
    
}

// Check for updates
- (void) checkUpdatesWithDelegate:(id <CheckUpdatesHelperDelegate>) _delegate {
    
    // Save the delegate
    delegate = _delegate;
    
    // Download the version descriptor
    NSURL *url = [NSURL URLWithString:@"https://api.rugarciap.com/tbs_version_free"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}


// Error downloading file
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [delegate errorCheckingUpdate];
}

// Start the download
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    contents = [[NSMutableData alloc]init];
}

// Download data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [contents appendData:data];
}


// Data download finished
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *versionContent = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
    
    int latestVersion = [versionContent intValue];
    
    if (latestVersion > CURRENT_VERSION) {
        [delegate updateAvailable];
    } else {
        [delegate updateNotAvailable];
    }
}



@end
