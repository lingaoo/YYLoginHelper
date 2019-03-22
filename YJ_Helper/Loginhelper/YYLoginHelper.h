//
//  YYLoginHelper.h
//  YYLoginHelper
//
//  Created by soso on 2018/11/28.
//  Copyright © 2018年 com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SVProgressHUD.h>

#import "YYCountDown.h"

#import "YYUserModel.h"

#import <AVOSCloud.h>

#import <TZImagePickerController.h>


@interface YYLoginHelper : NSObject

@property (strong, nonatomic)  YYCountDown *countDown;


/* (大部分方法含SVProgreeHUD提示) */

/// 登录 
+(void)loginActionWithMobile:(NSString *)mobile paswd:(NSString *)paswd VC:(UIViewController *)vc;

/// 注册
+(void)registerActionWithMobile:(NSString *)mobile paswd:(NSString *)paswd code:(NSString *)code VC:(UIViewController *)vc;

/// 找回密码
+(void)forgetPasswordWithSmscode:(NSString *)smscode password:(NSString *)password finishBlock:(void(^)(BOOL successs,NSError *error))finishBlock;

/// 获取验证码
-(void)getSmsCodeWithMobile:(NSString *)mobile countDownBlock:(void(^)(NSInteger count))block;

/// 获取协议URL
+(void)loadLCURLQueryWithClassName:(NSString *)name key:(NSString *)key Block:(void(^)(NSString *url))block;

/// 意见反馈 (自动建表)
+(void)loadLCFeedbackWithContent:(NSString *)content viewController:(UIViewController *)vc;

/// 修改nick
+(void)loadEidtNickWith:(NSString *)nickStr;

/// 修改头像 (记住修改Info.plist)
+(void)loadAvatarWith:(UIViewController *)vc block:(void(^)(NSString *imgUrl))block;

/// 获取用户详细信息
+(void)loadUserDescModelBlock:(void(^)(BOOL success, YYUserModel *model))block;





@end
