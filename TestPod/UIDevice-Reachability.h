//
//  UIDevice-Reachability.h
//  testSearchVC
//
//  Created by mifit on 15/9/1.
//  Copyright (c) 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SUPPORTS_UNDOCUMENTED_API   1

@interface UIDevice(Reachability)
/// 本机名字
+ (NSString *) hostname;

/// 连接的wifi名字
+ (NSString *) wifiName;

/// 连接的WiFi ip
+ (NSString *) localWiFiIPAddress;

/// 本机ip
+ (NSString *) localIPAddress;

/// ip网络公司
+ (NSString *) whatIsMyIpDotcom;

/// 是否连接到WLAN
+ (BOOL) activeWLAN;

+ (BOOL) addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address; // via Apple
+ (void) forceWWAN; // via Apple
+ (void) shutdownWWAN; // via Apple
@end