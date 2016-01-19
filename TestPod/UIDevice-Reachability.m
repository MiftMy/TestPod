//
//  UIDevice-Reachability.m
//  testSearchVC
//
//  Created by mifit on 15/9/1.
//  Copyright (c) 2015年 mifit. All rights reserved.
//
#include <unistd.h>
#include <sys/sysctl.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <ifaddrs.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "wwanconnect.h"

#import "UIDevice-Reachability.h"

@implementation UIDevice(Reachability)
+ (NSString *)wifiName{
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

+ (NSString *) hostname{
    char baseHostName[256];
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '\0';
    
#if !TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#else
    return [NSString stringWithFormat:@"%s", baseHostName];
#endif
}

// Direct from Apple. Thank you Apple
+ (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address{
    if (!IPAddress || ![IPAddress length]) {
        return NO;
    }
    
    memset((char *) address, sizeof(struct sockaddr_in), 0);
    address->sin_family = AF_INET;
    address->sin_len = sizeof(struct sockaddr_in);
    
    int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
    if (conversionResult == 0) {
        NSAssert1(conversionResult != 1, @"Failed to convert the IP address string into a sockaddr_in: %@", IPAddress);
        return NO;
    }
    
    return YES;
}

+ (NSString *) getIPAddressForHost: (NSString *) theHost{
    struct hostent *host = gethostbyname([theHost UTF8String]);
    
    if (host == NULL) {
        herror("resolv");
        return NULL;
    }
    
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    //NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0])];
    NSString *addressString = [NSString stringWithUTF8String:inet_ntoa(*list[0])];
    return addressString;
}

#if ! defined(IFT_ETHER)
#define IFT_ETHER 0x6   // Ethernet CSMACD
#endif

// Matt Brown's get WiFi IP addy solution
// Author gave permission to use in Cookbook under cookbook license
// http://mattbsoftware.blogspot.com/2009/04/how-to-get-ip-address-of-iphone-os-v221.html
+ (NSString *) localWiFiIPAddress{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"]) { // found the WiFi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

// Return the local IP address
+ (NSString *) localIPAddress{
    struct hostent *host = gethostbyname([[self hostname] UTF8String]);
    if (host == NULL)
    {
        herror("resolv");
        return nil;
    }
    else {
        struct in_addr **list = (struct in_addr **)host->h_addr_list;
        return [NSString stringWithUTF8String:inet_ntoa(*list[0])];
        //return [NSString stringWithCString:inet_ntoa(*list[0])];
    }
    return nil;
}

+ (NSString *) whatIsMyIpDotcom{
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://www.whatismyip.com/automation/n09230945.asp"];
    NSString *ip = [NSString stringWithContentsOfURL:ipURL encoding:1 error:&error];
    if (!ip) return [error localizedDescription];
    return ip;
}

+ (BOOL) activeWLAN{
    return ([self localWiFiIPAddress] != nil);
}

#pragma mark Forcing WWAN connection

MyStreamInfoPtr myInfoPtr;

static void myClientCallback(void *refCon){
    int  *val = (int*)refCon;
    printf("myClientCallback entered - value from refCon is %d\n", *val);
}

+ (void) forceWWAN{
    int value = 0;
    myInfoPtr = (MyStreamInfoPtr) StartWWAN(myClientCallback, &value);
    if (myInfoPtr)
    {
        printf("Started WWAN\n");
    }
    else
    {
        printf("Failed to start WWAN\n");
    }
}

+ (void) shutdownWWAN{
    if (myInfoPtr) StopWWAN((MyInfoRef) myInfoPtr);
}
@end
