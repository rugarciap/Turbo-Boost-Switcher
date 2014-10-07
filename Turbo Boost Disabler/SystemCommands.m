//
//  SystemCommands.m
//  Turbo Boost Switcher
//
//  Created by Rubén García Pérez on 20/07/13.
//  Copyright (c) 2013 Rubén García Pérez.
//  rugarciap.com
//
/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "SystemCommands.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <IOKit/IOKitLib.h>

#include "smc.h"

#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

static io_connect_t conn;
#define KEY_INFO_CACHE_SIZE 100
struct {
    UInt32 key;
    SMCKeyData_keyInfo_t keyInfo;
} g_keyInfoCache[KEY_INFO_CACHE_SIZE];

int g_keyInfoCacheCount = 0;
OSSpinLock g_keyInfoSpinLock = 0;
static NSArray *allSensors = nil;

kern_return_t SMCCall2(int index, SMCKeyData_t *inputStructure, SMCKeyData_t *outputStructure, io_connect_t conn);


UInt32 _strtoul(char *str, int size, int base)
{
    UInt32 total = 0;
    int i;
    
    for (i = 0; i < size; i++)
    {
        if (base == 16)
            total += str[i] << (size - 1 - i) * 8;
        else
            total += ((unsigned char) (str[i]) << (size - 1 - i) * 8);
    }
    return total;
}

void _ultostr(char *str, UInt32 val)
{
    str[0] = '\0';
    sprintf(str, "%c%c%c%c",
            (unsigned int) val >> 24,
            (unsigned int) val >> 16,
            (unsigned int) val >> 8,
            (unsigned int) val);
}

kern_return_t SMCOpen(io_connect_t *conn)
{
    kern_return_t result;
    mach_port_t   masterPort;
    io_iterator_t iterator;
    io_object_t   device;
    
	IOMasterPort(MACH_PORT_NULL, &masterPort);
    
    CFMutableDictionaryRef matchingDictionary = IOServiceMatching("AppleSMC");
    result = IOServiceGetMatchingServices(masterPort, matchingDictionary, &iterator);
    if (result != kIOReturnSuccess)
    {
        printf("Error: IOServiceGetMatchingServices() = %08x\n", result);
        return 1;
    }
    
    device = IOIteratorNext(iterator);
    IOObjectRelease(iterator);
    if (device == 0)
    {
        printf("Error: no SMC found\n");
        return 1;
    }
    
    result = IOServiceOpen(device, mach_task_self(), 0, conn);
    IOObjectRelease(device);
    if (result != kIOReturnSuccess)
    {
        printf("Error: IOServiceOpen() = %08x\n", result);
        return 1;
    }
    
    return kIOReturnSuccess;
}

kern_return_t SMCClose(io_connect_t conn)
{
    return IOServiceClose(conn);
}

kern_return_t SMCCall2(int index, SMCKeyData_t *inputStructure, SMCKeyData_t *outputStructure,io_connect_t conn)
{
    size_t   structureInputSize;
    size_t   structureOutputSize;
    structureInputSize = sizeof(SMCKeyData_t);
    structureOutputSize = sizeof(SMCKeyData_t);
    
    return IOConnectCallStructMethod(conn, index, inputStructure, structureInputSize, outputStructure, &structureOutputSize);
}

// Provides key info, using a cache to dramatically improve the energy impact of smcFanControl
kern_return_t SMCGetKeyInfo(UInt32 key, SMCKeyData_keyInfo_t* keyInfo, io_connect_t conn)
{
    SMCKeyData_t inputStructure;
    SMCKeyData_t outputStructure;
    kern_return_t result = kIOReturnSuccess;
    int i = 0;
    
    OSSpinLockLock(&g_keyInfoSpinLock);
    
    for (; i < g_keyInfoCacheCount; ++i)
    {
        if (key == g_keyInfoCache[i].key)
        {
            *keyInfo = g_keyInfoCache[i].keyInfo;
            break;
        }
    }
    
    if (i == g_keyInfoCacheCount)
    {
        // Not in cache, must look it up.
        memset(&inputStructure, 0, sizeof(inputStructure));
        memset(&outputStructure, 0, sizeof(outputStructure));
        
        inputStructure.key = key;
        inputStructure.data8 = SMC_CMD_READ_KEYINFO;
        
        result = SMCCall2(KERNEL_INDEX_SMC, &inputStructure, &outputStructure, conn);
        if (result == kIOReturnSuccess)
        {
            *keyInfo = outputStructure.keyInfo;
            if (g_keyInfoCacheCount < KEY_INFO_CACHE_SIZE)
            {
                g_keyInfoCache[g_keyInfoCacheCount].key = key;
                g_keyInfoCache[g_keyInfoCacheCount].keyInfo = outputStructure.keyInfo;
                ++g_keyInfoCacheCount;
            }
        }
    }
    
    OSSpinLockUnlock(&g_keyInfoSpinLock);
    
    return result;
}

kern_return_t SMCReadKey2(UInt32Char_t key, SMCVal_t *val,io_connect_t conn)
{
    kern_return_t result;
    SMCKeyData_t  inputStructure;
    SMCKeyData_t  outputStructure;
    
    memset(&inputStructure, 0, sizeof(SMCKeyData_t));
    memset(&outputStructure, 0, sizeof(SMCKeyData_t));
    memset(val, 0, sizeof(SMCVal_t));
    
    inputStructure.key = _strtoul(key, 4, 16);
    sprintf(val->key, key);
    
    result = SMCGetKeyInfo(inputStructure.key, &outputStructure.keyInfo, conn);
    if (result != kIOReturnSuccess)
    {
        return result;
    }
    
    val->dataSize = outputStructure.keyInfo.dataSize;
    _ultostr(val->dataType, outputStructure.keyInfo.dataType);
    inputStructure.keyInfo.dataSize = val->dataSize;
    inputStructure.data8 = SMC_CMD_READ_BYTES;
    
    result = SMCCall2(KERNEL_INDEX_SMC, &inputStructure, &outputStructure,conn);
    if (result != kIOReturnSuccess)
    {
        return result;
    }
    
    memcpy(val->bytes, outputStructure.bytes, sizeof(outputStructure.bytes));
    
    return kIOReturnSuccess;
}


double SMCGetTemperature()
{
    float c_temp;
    if (allSensors == nil) {
        allSensors = [[NSArray alloc] initWithObjects:@"TC0D",@"TCAH",@"TC0F",@"TC0H",@"TCBH",@"TC0P",nil];
    }
    
    SMCVal_t      val;
    
    for (NSString *sensor in allSensors) {
        SMCReadKey2((char*)[sensor UTF8String], &val,conn);
        c_temp= ((val.bytes[0] * 256 + val.bytes[1]) >> 2)/64;
        if (c_temp>0) {
            break;
        }
    }
    
	return c_temp;
}

int SMCGetFanSpeed(char *key)
{
    SMCVal_t val;
    kern_return_t result;
    
    result = SMCReadKey2(key, &val, conn);
    if (result == kIOReturnSuccess) {
        // read succeeded - check returned value
        if (val.dataSize > 0) {
            if (strcmp(val.dataType, DATATYPE_FPE2) == 0) {

                int intValue = (val.bytes[0] * 256 + val.bytes[1]) >> 2;
                return intValue;
            }
        }
    }
    // read failed
    return 0;
}


@implementation SystemCommands

// New method to run task as root. Authref stored on appdelegate, created once and reused each time this
// method is called
+ (BOOL) runTaskAsAdmin:(NSString *) path withAuthRef:(AuthorizationRef) authRef andArgs:(NSArray *) args {
    
    FILE *myCommunicationsPipe = NULL;
    
    int count = (int)[args count];
    
    char *myArguments[count+1];
    
    for (int i=0; i<[args count]; i++) {
        myArguments[i] = (char *)[(NSString *)[args objectAtIndex:i] UTF8String];
    }
    myArguments[count] = NULL;
    
    OSStatus resultStatus = AuthorizationExecuteWithPrivileges (authRef,
                                                   [path UTF8String], kAuthorizationFlagDefaults, myArguments,
                                                   &myCommunicationsPipe);
    if (resultStatus != errAuthorizationSuccess)
        NSLog(@"Error: %d", resultStatus);
    
    return YES;
}


// Deprecated. TODO: To be removed on next version.
+ (BOOL) runProcess:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription
                   asAdministrator:(BOOL) isAdministrator{
    
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"%@ %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script;
    if (isAdministrator) {
        script = [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    } else {
        script = [NSString stringWithFormat:@"do shell script \"%@\"", fullScript];
    }
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}

// Check if is 32 bits or not
+ (BOOL) is32bits {

    NSString * output = nil;
    NSString * processErrorDescription = nil;
    
    // kextstat |grep com.rugarciap.DisableTurboBoost
    
    [self runProcess:@"uname -m"
                                     withArguments:[NSArray arrayWithObjects:@"", nil]
                                            output:&output
                                  errorDescription:&processErrorDescription asAdministrator:NO];
    
    if ([output isEqualToString:@"x86_64"]) {
        return NO;
    }

    return YES;
    
}

// Check if the module is loaded (TBS disabled) or not (TBS Enabled)
+ (BOOL) isModuleLoaded  {
    
    NSString * output = nil;
    NSString * processErrorDescription = nil;

    // kextstat |grep com.rugarciap.DisableTurboBoost
    
    [self runProcess:@"kextstat | grep com.rugarciap.DisableTurboBoost"
                                     withArguments:[NSArray arrayWithObjects:@"", nil]
                                            output:&output
                                  errorDescription:&processErrorDescription asAdministrator:NO];

    NSLog(@"kextstat output: %@", output);
    
    if (output == nil) {
        return NO;
    } else {
        return YES;
    }

}

// Get the module path depending on arch
+ (NSString *) getModulePath:(BOOL) is32bits {
    NSString *modulePath;
    
    // Cargamos el módulo de 32 bits o no dependiendo de la ruta
    if (is32bits) {
        modulePath = [[NSBundle mainBundle] pathForResource:@"DisableTurboBoost.32bits" ofType:@"kext"];
    } else {
        modulePath = [[NSBundle mainBundle] pathForResource:@"DisableTurboBoost.64bits" ofType:@"kext"];
    }
    return modulePath;
    //return [modulePath stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
}

+ (BOOL) loadModuleWithAuthRef:(AuthorizationRef) authRef {
    
    BOOL is32bits = [self is32bits];
 
    NSString *modulePath = [self getModulePath:is32bits];
    
    return [self loadModuleWithPath:modulePath andAuthRef:authRef];
}


+ (BOOL) unLoadModuleWithAuthRef:(AuthorizationRef) authRef {
    
    BOOL is32bits = [self is32bits];
    
    NSString *modulePath = [self getModulePath:is32bits];
    
    return [self unloadModuleWithPath:modulePath andAuthRef:authRef];
}

+ (BOOL) loadModuleWithPath:(NSString *) pathToModule andAuthRef:(AuthorizationRef) authRef {
   
    NSString * processErrorDescription = nil;
    
    // sudo chown -R root:wheel %pathToModule; sudo kextutil -v %pathToModule
    [self runTaskAsAdmin:@"/usr/sbin/chown" withAuthRef:authRef andArgs:[NSArray arrayWithObjects:@"-R", @"root:wheel", [NSString stringWithFormat:@"%@", pathToModule], nil]];
    
    [self runTaskAsAdmin:@"/usr/bin/kextutil" withAuthRef:authRef andArgs:[NSArray arrayWithObjects:@"-v", [NSString stringWithFormat:@"%@", pathToModule], nil]];
    
    if (processErrorDescription != nil) {
        NSLog(@"Error loading module: %@", processErrorDescription);
    }
    return YES;

}

+ (BOOL) unloadModuleWithPath:(NSString *) pathToModule andAuthRef:(AuthorizationRef) authRef {
    
    NSString * processErrorDescription = nil;
    
    // sudo kextunload -v path
    [self runTaskAsAdmin:@"/sbin/kextunload" withAuthRef:authRef andArgs:[NSArray arrayWithObjects:@"-v",[NSString stringWithFormat:@"%@", pathToModule], nil]];
    
    if (processErrorDescription != nil) {
        NSLog(@"Error unloading module: %@", processErrorDescription);
    }
    
    return YES;
}

+ (float) readCurrentCpuTemp {
    SMCOpen(&conn);
    
    float temp = 0;

    temp = SMCGetTemperature();
    
    SMCClose(conn);
    
    return temp;
}

+ (int) readCurrentFanSpeed {
    SMCOpen(&conn);
    
    int fanSpeed = SMCGetFanSpeed(SMC_KEY_FAN0_RPM_CUR);
    
    if (fanSpeed < 1) {
        fanSpeed = SMCGetFanSpeed(SMC_KEY_FAN1_RPM_CUR);
    }
    
    if (fanSpeed < 1) {
        fanSpeed = -1;
    }
    
    SMCClose(conn);
    return fanSpeed;
}



@end
