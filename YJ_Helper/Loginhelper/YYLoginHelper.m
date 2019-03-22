//
//  YYLoginHelper.m
//  YYLoginHelper
//
//  Created by soso on 2018/11/28.
//  Copyright © 2018年 com.cn. All rights reserved.
//

#import "YYLoginHelper.h"

typedef void(^CountDownBlock)(NSInteger count);

@interface YYLoginHelper ()
{
    
}

@property (nonatomic, copy) CountDownBlock countBlock;

@end

@implementation YYLoginHelper


+(void)loginActionWithMobile:(NSString *)mobile paswd:(NSString *)paswd VC:(UIViewController *)vc {
    
    NSString *mobileString = mobile;
    NSString *passwordString = paswd;
    
    if(mobileString.length < 11) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    
    if(mobileString.length==0){
        [SVProgressHUD showErrorWithStatus:@"请输入账号"];
        return;
    }
    if(passwordString.length==0){
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }
    
    [SVProgressHUD show];
    [AVUser logInWithUsernameInBackground:mobileString password:passwordString block:^(AVUser * _Nullable user, NSError * _Nullable error) {
        if(error){
            if(error.code==211 || error.code==210){
                //[MBProgressHUD showText:@"账号未注册"];
                [SVProgressHUD showErrorWithStatus:@"账号或密码不正确"];
            }else{
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }else{
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [vc dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }];
    
    
}


+(void)registerActionWithMobile:(NSString *)mobile paswd:(NSString *)paswd code:(NSString *)code VC:(UIViewController *)vc {
    
    /// 手机号
    NSString *mobileString = mobile;
    /// 密码
    NSString *passwordString = paswd;
    /// 验证码
    NSString *codeString = code;
    
    if (mobileString.length==0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
        return;
    }else if(passwordString.length==0){
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }else if(codeString.length==0){
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    }
    [AVUser signUpOrLoginWithMobilePhoneNumberInBackground:mobileString smsCode:codeString password:passwordString block:^(AVUser * _Nullable user, NSError * _Nullable error) {
        if(!error){
            AVUser *user = [AVUser currentUser];
            AVObject *todo =[AVObject objectWithClassName:@"_User" objectId:user.objectId];
            // 修改属性
            NSString *nickName = [self getRandomStringWithNum:9];
            [todo setObject:nickName forKey:@"nickName"];
            [todo setObject:@"" forKey:@"avatar"];
            // 保存到云端
            [todo saveInBackground];
            [SVProgressHUD showSuccessWithStatus:@"注册成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *present = vc.presentingViewController;
                while (YES) {
                    if (present.presentingViewController) {
                        present = present.presentingViewController;
                    }else{
                        break;
                    }
                }
                [present dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            
        }
    }];
}

/// 随机昵称
+ (NSString *)getRandomStringWithNum:(NSInteger)num {
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < num; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    return string;
}

+(void)forgetPasswordWithSmscode:(NSString *)smscode password:(NSString *)password finishBlock:(void(^)(BOOL successs,NSError *error))finishBlock{
    
    if(smscode.length <= 0 ) {
        [SVProgressHUD showErrorWithStatus:@"请先获取验证码"];
        return;
    }
    
    if(password.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请先输入密码"];
        return;
        
    }
    [AVUser resetPasswordWithSmsCode:smscode newPassword:password block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"设置成功"];
        }else{
            [SVProgressHUD showSuccessWithStatus:error.localizedDescription];
        }
        if(finishBlock) finishBlock(succeeded,error);
    }];
    
    
}

-(void)getSmsCodeWithMobile:(NSString *)mobile countDownBlock:(void(^)(NSInteger count))block{
    self.countDown = [[YYCountDown alloc] init];
    self.countBlock = block;
    [self getSmscode];
}

+(void)loadLCURLQueryWithClassName:(NSString *)name key:(NSString *)key Block:(void(^)(NSString *url))block{
    AVQuery *DateQuery = [AVQuery queryWithClassName:name];
    [DateQuery getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
        if(error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return ;
        }
        NSString *protocolUrl = ((AVFile *)[object objectForKey:key]).url;
        if(block)
            block(protocolUrl);
    }];
    
}


+(void)loadLCFeedbackWithContent:(NSString *)content viewController:(UIViewController *)vc {
    [self loadLCFeedbackWithContent:content finishBlock:^(BOOL success, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [vc.navigationController popViewControllerAnimated:YES];
        });
    }];
    
}


/// 意见反馈 (Block自定义处理)
+(void)loadLCFeedbackWithContent:(NSString *)content finishBlock:(void (^)(BOOL, NSError *))finishBlock {
    if(content.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
        return;
    }

    AVUser *user = [AVUser currentUser];
    AVObject *todo = [AVObject objectWithClassName:@"Feedback"];
    [todo setObject:content forKey:@"content"];
    if (user.username.length>=1){
        [todo setObject:user.mobilePhoneNumber forKey:@"mobile"];
    }
    [SVProgressHUD show];
    [todo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"提交成功"];
        }else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        
        if(finishBlock)
            finishBlock(succeeded,error);
        
    }];

}

+(void)loadEidtNickWith:(NSString *)nickStr {
    AVUser *user =  [AVUser currentUser];
    if (user.username.length==0) {
        NSLog(@"ERROR:您未登录");
        return;
    }
    AVObject *userobj =[AVObject objectWithClassName:@"_User" objectId:user.objectId];
    [userobj setObject:nickStr forKey:@"nickName"];
    [userobj saveInBackground];
}

+(void)loadAvatarWith:(UIViewController *)vc block:(void(^)(NSString *imgUrl))block{
    AVUser *user =  [AVUser currentUser];
    if (user.username.length==0) {
        NSLog(@"ERROR:您未登录");
        return;
    }

    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.title = @"选择图片";
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage *image = photos[0];
        NSData *data = UIImageJPEGRepresentation(image , 0.5);
        AVFile *file = [AVFile fileWithData:data name:@"avatar.png"];
        [file uploadWithCompletionHandler:^(BOOL succeeded, NSError *error) {
            AVObject *userobj =[AVObject objectWithClassName:@"_User" objectId:user.objectId];
            [userobj setObject:file.url forKey:@"avatar"];
            [userobj saveInBackground];
            if(block)
                block(file.url);
        }];
        
    }];
    [vc presentViewController:imagePickerVc animated:YES completion:nil];
}

+(void)loadUserDescModelBlock:(void (^)(BOOL success, YYUserModel * model))block {
    
    AVUser *user =  [AVUser currentUser];
    if (user.username.length==0) {
        NSLog(@"ERROR:您未登录");
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"" object:nil];
        return;
    }

    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:user.objectId block:^(AVObject *object, NSError *error) {
        YYUserModel *model = [[YYUserModel alloc] init];
        NSString *avatar = [object objectForKey:@"avatar"];
        NSString *nickName = [object objectForKey:@"nickName"];
        NSString *mobile =  user.mobilePhoneNumber;
        NSString *username = user.username;

        model.username = username;
        model.avatar = avatar;
        model.mobilePhoneNumber = mobile;
        model.nickName = nickName;
        
        if(block)
            block(error==NO,model);
        
    }];
    
}

#pragma mark - 倒计时方法
-(void)getSmscode {
    NSTimeInterval aMinutes = 60;
    [self startWithStartDate2:[NSDate date] finishDate:[NSDate dateWithTimeIntervalSinceNow:aMinutes]];
}

-(void)startWithStartDate2:(NSDate *)strtDate finishDate:(NSDate *)finishDate{
    __weak __typeof(self) weakSelf= self;
    [self.countDown countDownWithStratDate:strtDate finishDate:finishDate completeBlock:^(NSInteger day, NSInteger hour, NSInteger minute, NSInteger second) {
        NSInteger totoalSecond =day*24*60*60+hour*60*60 + minute*60+second;
        
        if(weakSelf.countBlock)
            weakSelf.countBlock(totoalSecond);
    }];
}


@end
