//
//  CustomPluginRegistrant.m
//  Runner
//
//  Created by dfg on 2020/12/2.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "CustomPluginRegistrant.h"
#import "GloableCookie.h"

@implementation CustomPluginRegistrant
+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    [GloableCookie registerWithRegistrar:[registry registrarForPlugin:@"GloableCookie"]];
}
@end
