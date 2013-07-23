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

static io_connect_t conn;

UInt32 _strtoul(char *str, int size, int base)
{
    UInt32 total = 0;
    int i;
    
    for (i = 0; i < size; i++)
    {
        if (base == 16)
            total += str[i] << (size - 1 - i) * 8;
        else
            total += (unsigned char) (str[i] << (size - 1 - i) * 8);
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

kern_return_t SMCOpen(void)
{
    kern_return_t result;
    mach_port_t   masterPort;
    io_iterator_t iterator;
    io_object_t   device;
    
    result = IOMasterPort(MACH_PORT_NULL, &masterPort);
    
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
    
    result = IOServiceOpen(device, mach_task_self(), 0, &conn);
    IOObjectRelease(device);
    if (result != kIOReturnSuccess)
    {
        printf("Error: IOServiceOpen() = %08x\n", result);
        return 1;
    }
    
    return kIOReturnSuccess;
}

kern_return_t SMCClose()
{
    return IOServiceClose(conn);
}


kern_return_t SMCCall(int index, SMCKeyData_t *inputStructure, SMCKeyData_t *outputStructure)
{
    size_t   structureInputSize;
    size_t   structureOutputSize;
    
    structureInputSize = sizeof(SMCKeyData_t);
    structureOutputSize = sizeof(SMCKeyData_t);
    
#if MAC_OS_X_VERSION_10_5
    return IOConnectCallStructMethod( conn, index,
                                     // inputStructure
                                     inputStructure, structureInputSize,
                                     // ouputStructure
                                     outputStructure, &structureOutputSize );
#else
    return IOConnectMethodStructureIStructureO( conn, index,
                                               structureInputSize, /* structureInputSize */
                                               &structureOutputSize,   /* structureOutputSize */
                                               inputStructure,        /* inputStructure */
                                               outputStructure);       /* ouputStructure */
#endif
    
}

kern_return_t SMCReadKey(UInt32Char_t key, SMCVal_t *val)
{
    kern_return_t result;
    SMCKeyData_t  inputStructure;
    SMCKeyData_t  outputStructure;
    
    memset(&inputStructure, 0, sizeof(SMCKeyData_t));
    memset(&outputStructure, 0, sizeof(SMCKeyData_t));
    memset(val, 0, sizeof(SMCVal_t));
    
    inputStructure.key = _strtoul(key, 4, 16);
    inputStructure.data8 = SMC_CMD_READ_KEYINFO;
    
    result = SMCCall(KERNEL_INDEX_SMC, &inputStructure, &outputStructure);
    if (result != kIOReturnSuccess)
        return result;
    
    val->dataSize = outputStructure.keyInfo.dataSize;
    _ultostr(val->dataType, outputStructure.keyInfo.dataType);
    inputStructure.keyInfo.dataSize = val->dataSize;
    inputStructure.data8 = SMC_CMD_READ_BYTES;
    
    result = SMCCall(KERNEL_INDEX_SMC, &inputStructure, &outputStructure);
    if (result != kIOReturnSuccess)
        return result;
    
    memcpy(val->bytes, outputStructure.bytes, sizeof(outputStructure.bytes));
    
    return kIOReturnSuccess;
}

double SMCGetTemperature(char *key)
{
    SMCVal_t val;
    kern_return_t result;
    
    result = SMCReadKey(key, &val);
    if (result == kIOReturnSuccess) {
        // read succeeded - check returned value
        if (val.dataSize > 0) {
            if (strcmp(val.dataType, DATATYPE_SP78) == 0) {
                // convert fp78 value to temperature
                int intValue = (val.bytes[0] * 256 + val.bytes[1]) >> 2;
                return intValue / 64.0;
            }
        }
    }
    // read failed
    return 0.0;
}

int SMCGetFanSpeed(char *key)
{
    SMCVal_t val;
    kern_return_t result;
    
    result = SMCReadKey(key, &val);
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
    
    return [modulePath stringByReplacingOccurrencesOfString:@" " withString:@"\\\\ "];
}

+ (BOOL) loadModule {
    
    BOOL is32bits = [self is32bits];
 
    NSString *modulePath = [self getModulePath:is32bits];
    
    return [self loadModuleWithPath:modulePath];
}


+ (BOOL) unLoadModule {
    BOOL is32bits = [self is32bits];
    
    NSString *modulePath = [self getModulePath:is32bits];
    
    return [self unloadModuleWithPath:modulePath];
}

+ (BOOL) loadModuleWithPath:(NSString *) pathToModule {
   
    NSString * output = nil;
    NSString * processErrorDescription = nil;
    
    // sudo chown -R root:wheel %pathToModule; sudo kextutil -v %pathToModule
    NSString *loadCommand = [NSString stringWithFormat:@"chown -R root:wheel %@;kextutil -v", pathToModule] ;
    
    
    BOOL success = [self runProcess:loadCommand
                                     withArguments:[NSArray arrayWithObjects:pathToModule, nil]
                                            output:&output
                                  errorDescription:&processErrorDescription asAdministrator:YES];
    NSLog(@"Loading module output: %@", output);
    if (processErrorDescription != nil) {
        NSLog(@"Error loading module: %@", processErrorDescription);
    }
    return success;

}

+ (BOOL) unloadModuleWithPath:(NSString *) pathToModule {
    
    NSString * output = nil;
    NSString * processErrorDescription = nil;
    
    // sudo kextunload -v path    
    BOOL success = [self runProcess:@"kextunload -v"
                                     withArguments:[NSArray arrayWithObjects:pathToModule, nil]
                                            output:&output
                                  errorDescription:&processErrorDescription asAdministrator:YES];
    NSLog(@"Unloading module output: %@", output);
    if (processErrorDescription != nil) {
        NSLog(@"Error unloading module: %@", processErrorDescription);
    }
    
    return success;
}

+ (float) readCurrentCpuTemp {
    SMCOpen();
    
    float temp = 0;

    temp = SMCGetTemperature(SMC_KEY_CPU_TEMP_1);
    if (temp < 1) {
        temp = SMCGetTemperature(SMC_KEY_CPU_TEMP_1);
    }
    if (temp < 1) {
        temp = SMCGetTemperature(SMC_KEY_CPU_TEMP_2);
    }

    if (temp < 1) {
        temp = SMCGetTemperature(SMC_KEY_CPU_TEMP_3);
    }
    
    if (temp < 1) {
        temp = -1;
    }

    SMCClose();
    
    return temp;
}

+ (int) readCurrentFanSpeed {
    SMCOpen();
    
    int fanSpeed = SMCGetFanSpeed(SMC_KEY_FAN0_RPM_CUR);
    
    if (fanSpeed < 1) {
        fanSpeed = SMCGetFanSpeed(SMC_KEY_FAN1_RPM_CUR);
    }
    
    if (fanSpeed < 1) {
        fanSpeed = -1;
    }
    
    SMCClose();
    return fanSpeed;
}



@end
