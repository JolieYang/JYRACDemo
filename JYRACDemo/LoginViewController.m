//
//  LoginViewController.m
//  JYRACDemo
//
//  Created by Jolie_Yang on 2017/1/19.
//  Copyright © 2017年 China Industrial Bank. All rights reserved.
//

#import "LoginViewController.h"
#import "NetService.h"
#import "AppDelegate.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLB;

@property (nonatomic, strong) NetService *service;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.service = [NetService new];
    
    [self setup];
}

- (void)setup {
    self.errorLB.hidden = YES;
    
    // 用户名
    RACSignal *validUsernameSignal = [self.usernameTF.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidUsername:value]);
    }];
    RAC(self.usernameTF, backgroundColor) = [validUsernameSignal map:^id _Nullable(NSNumber *usernameValid) {
        return [usernameValid boolValue] ? [UIColor whiteColor] : [UIColor yellowColor];
    }];
    
    // 密码
    RACSignal *validPasswordSignal = [self.passwordTF.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidPassword:value]);
    }];
    RAC(self.passwordTF, backgroundColor) = [validPasswordSignal map:^id _Nullable(NSNumber *passwordValid) {
        return [passwordValid boolValue] ? [UIColor whiteColor] : [UIColor yellowColor];
    }];
    
    // 登录按钮是否启用 叠加--combine, reduce中的参数是与signal一一对应。
    RACSignal *signInActiveSignal = [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
                                                      reduce:^id (NSNumber *usernameValid, NSNumber *passwordValid){
                                                        return @([usernameValid boolValue] && [passwordValid boolValue]);}];
    [signInActiveSignal subscribeNext:^(NSNumber *signUpActive) {
        self.signInButton.enabled = [signUpActive boolValue];
    }];
    
    //  登录事件
    [[[[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside]
    doNext:^(__kindof UIControl * _Nullable x) {
        self.signInButton.enabled = NO;
        self.errorLB.hidden = YES;
    }]
    flattenMap:^__kindof RACSignal * _Nullable(__kindof UIControl * _Nullable value) {
        return [self signInServiceSignal];
    }]
    subscribeNext:^(NSNumber *signInSuccess) {
        self.signInButton.enabled = YES;
        BOOL success = [signInSuccess boolValue];
        self.errorLB.hidden = success;
        if (success) {
            NSLog(@"跳转到主页");
            [[NSUserDefaults standardUserDefaults] setBool:success forKey:LOGIN_SUCCESS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            AppDelegate *pDelegate = [UIApplication sharedApplication].delegate;
            pDelegate.window.rootViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"HomeViewController"];
        }
    }];
}


- (RACSignal *)signInServiceSignal {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.service signInWithUserName:self.usernameTF.text
                                Password:self.passwordTF.text
                               Completed:^(BOOL success) {
                                   [subscriber sendNext:@(success)];
                                   [subscriber sendCompleted];
                               }];
        return nil;
    }];
}
- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 2;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 2;
}


#pragma mark Learing Track
- (void)usernameVersion1 {
    // 过滤--filter
    [[self.usernameTF.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return value.length > 3;
    }]
    subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@", x);
    }];
}
- (void)usernameVersion2 {
    RACSignal *usernameSignal = self.usernameTF.rac_textSignal;
    RACSignal *filterUsername = [usernameSignal filter:^BOOL(NSString *name) {
        return name.length > 3;
    }];
    [filterUsername subscribeNext:^(NSString *x) {
        NSLog(@"%@",x);
    }];
}
- (RACSignal *)usernameVersion3 {
    // 转换--map
    RACSignal *validUsernameSignal = [self.usernameTF.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        // ps : @() 返回类型需将BOOL类型转化为NSNumber
        return @([self isValidUsername:value]);
    }];
    return validUsernameSignal;
}
- (void)usernameVersion4 {
    RACSignal *validUsernameSignal = [self usernameVersion3];
    [[validUsernameSignal map:^id _Nullable(NSNumber *usernameValid) {
        return [usernameValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }]
    subscribeNext:^(UIColor *color) {
        self.usernameTF.backgroundColor = color;
    }];
}
- (void)usernameVersion5 {
    RACSignal *validUsernameSignal = [self usernameVersion3];
    [RAC(self.usernameTF, backgroundColor) = validUsernameSignal map:^id _Nullable(NSNumber *usernameValid) {
        return [usernameValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
}

- (void)signInButtonVersion1 {
    [[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"button clicked");
    }];
}
- (void)signInButtonVersion2 {
    [[[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside]
    // 将登陆信号转换为登陆服务的信号
    map:^id _Nullable(__kindof UIControl * _Nullable value) {
        return [self signInServiceSignal];
    }]
    subscribeNext:^(id  _Nullable x) {// 返回的结果不是登陆结果的信号
        NSLog(@"Sign In Result:%@", x);
    }];
}
// 解决方案1： 在外部信号的subscribeNext block中对内部信号进行订阅信号。
- (void)signInButtonVersion3 {
    [[[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside]
      doNext:^(__kindof UIControl * _Nullable x) {
          self.signInButton.enabled = NO;
          self.errorLB.hidden = YES;
          
      }]
     subscribeNext:^(__kindof UIControl * _Nullable x) {
         [[self signInServiceSignal] subscribeNext:^(NSNumber *signInSuccess) {
             self.signInButton.enabled = YES;
             BOOL success = [signInSuccess boolValue];
             self.errorLB.hidden = success;
             if (success) {
                 NSLog(@"跳转到主页");
             }
         }];
     }];
}
// 解决方案2:通过flattenMap将订阅数据转换为Block中的值
- (void)signInButtonVersion4 {
    [[[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside]
      flattenMap:^id _Nullable(__kindof UIControl * _Nullable value) {
          return [self signInServiceSignal];
      }]
     subscribeNext:^(id  _Nullable x) {// 返回的结果是登陆结果的信号
         NSLog(@"Sign In Result:%@", x);
     }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end