//
//  NetService.m
//  JYRACDemo
//
//  Created by Jolie_Yang on 2017/1/19.
//  Copyright © 2017年 China Industrial Bank. All rights reserved.
//

#import "NetService.h"

@implementation NetService
- (void)signInWithUserName:(NSString *)username Password:(NSString *)password Completed:(ServiceResponse)completeBlock {
    
    float delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        BOOL success = [username isEqualToString:@"aaa"] && [password isEqualToString:@"aaa"];
        completeBlock(success);
    });
}
@end
