//
//  LoginViewController.m
//  JYRACDemo
//
//  Created by Jolie_Yang on 2017/1/19.
//  Copyright © 2017年 China Industrial Bank. All rights reserved.
//

#import "LoginViewController.h"
#import "NetService.h"

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
        return [usernameValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    // 密码
    RACSignal *validPasswordSignal = [self.passwordTF.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidPassword:value]);
    }];
    RAC(self.passwordTF, backgroundColor) = [validPasswordSignal map:^id _Nullable(NSNumber *passwordValid) {
        return [passwordValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    // 登录按钮是否启用 叠加--combine, reduce中的参数是与signal一一对应。
    RACSignal *signInActiveSignal = [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal] reduce:^id (NSNumber *usernameValid, NSNumber *passwordValid){
        return @([usernameValid boolValue] && [passwordValid boolValue]);
    }];
    [signInActiveSignal subscribeNext:^(NSNumber *signUpActive) {
        self.signInButton.enabled = [signUpActive boolValue];
    }];
    
    //  登录事件
    RACSignal *signInSignal = [self.signInButton rac_signalForControlEvents:UIControlEventTouchDown];
    
}
//- (RACSignal *)signInServiceSignal {
//    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        [self.service signInWithUserName:self.usernameTF.text
//                                Password:self.passwordTF.text
//                               Completed:^(BOOL success) {
//                                   [subscriber sendNext:@[success]];
//                                   [subscriber sendCompleted];
//                               }];
//        return nil;
//    }];
//}
- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 3;
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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end