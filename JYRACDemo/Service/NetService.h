//
//  NetService.h
//  JYRACDemo
//
//  Created by Jolie_Yang on 2017/1/19.
//  Copyright © 2017年 China Industrial Bank. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ServiceResponse)(BOOL);

@interface NetService : NSObject

- (void)signInWithUserName:(NSString *)username Password:(NSString *)password Completed:(ServiceResponse)completeBlock;
@end
