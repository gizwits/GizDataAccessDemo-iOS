//
//  GizDataAccessLogin.h
//  GizDataAccess
//
//  Created by xpg on 14/12/30.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GizDataAccess/GizDataAccessDifinitions.h>

@class GizDataAccessLogin;

/**
 GizDataAccessLoginDelegate是GizDataAccessLogin类的委托协议，为APP开发者处理用户登录结果提供委托函数。
 */
@protocol GizDataAccessLoginDelegate <NSObject>
@optional

/**
 *
 * 登录回调
 *
 * @param login 当前登录实例
 *
 * @param uid 登录成功后得到的id，如果失败则为nil
 *
 * @param token 登录成功后得到的token（用户鉴权令牌），如果失败则为nil
 *
 * @param result 登录结果，成功或失败。详情参考 GizDataAccessErrorCode 定义
 *
 * @param message 错误信息，成功为 "Success"
 *
 * @see 触发函数：
 * [GizDataAccessLogin loginAnonymous]，
 * [GizDataAccessLogin login:password:]，
 * [GizDataAccessLogin loginWithThirdAccountType:uid:token:]
 *
 */
- (void)gizDataAccess:(GizDataAccessLogin *)login didLogin:(NSString *)uid token:(NSString *)token result:(GizDataAccessErrorCode)result message:(NSString *)message;

/**
 *
 * 注册回调
 *
 * @param login 当前登录实例
 *
 * @param uid 登录成功后得到的id，如果失败则为nil
 *
 * @param token 登录成功后得到的token（用户鉴权令牌），如果失败则为nil
 *
 * @param result 登录结果，成功或失败。详情参考 GizDataAccessErrorCode 定义
 *
 * @param message 错误信息，成功为 "Success"
 *
 * @see 触发函数：
 * [GizDataAccessLogin registerUser:password:code:accountType:]
 *
 */
- (void)gizDataAccess:(GizDataAccessLogin *)login didRegisterUser:(NSString *)uid token:(NSString *)token result:(GizDataAccessErrorCode)result message:(NSString *)message;

/**
 *
 * 获取验证码回调
 *
 * @param login 当前登录实例
 *
 * @param result 登录结果，成功或失败。详情参考 GizDataAccessErrorCode 定义
 *
 * @param message 错误信息，成功为 "Success"
 *
 * @see 触发函数：
 * [GizDataAccessLogin requestSendVerifyCode:]
 *
 */
- (void)gizDataAccess:(GizDataAccessLogin *)login didRequestSendVerifyCode:(GizDataAccessErrorCode)result message:(NSString *)message;

/**
 *
 * 修改/重置密码的回调
 *
 * @param login 当前登录实例
 *
 * @param result 登录结果，成功或失败。详情参考 GizDataAccessErrorCode 定义
 *
 * @param message 错误信息，成功为 "Success"
 *
 * @see 触发函数：
 * [GizDataAccessLogin changeUserPassword:oldPassword:newPassword:]
 * [GizDataAccessLogin resetPassword:code:newPassword:]
 *
 */
- (void)gizDataAccess:(GizDataAccessLogin *)login didChangeUserPassword:(GizDataAccessErrorCode)result message:(NSString *)message;

/**
 *
 * 修改实名用户为手机或邮箱用户
 *
 * @param login 当前登录实例
 *
 * @param result 登录结果，成功或失败。详情参考 GizDataAccessErrorCode 定义
 *
 * @param message 错误信息，成功为 "Success"
 *
 * @see 触发函数：
 * [GizDataAccessLogin changeUserInfo:username:code:accountType:]
 *
 */
- (void)gizDataAccess:(GizDataAccessLogin *)login didChangeUserInfo:(GizDataAccessErrorCode)result message:(NSString *)message;

/**
 *
 * 转换匿名用户为实名用户（第三方账号除外）
 *
 * @param login 当前登录实例
 *
 * @param result 登录结果，成功或失败。详情参考 GizDataAccessErrorCode 定义
 *
 * @param message 错误信息，成功为 "Success"
 *
 * @see 触发函数：
 * [GizDataAccessLogin transAnonymousUser:username:password:code:accountType:]
 *
 */
- (void)gizDataAccess:(GizDataAccessLogin *)login didTransAnonymousUser:(GizDataAccessErrorCode)result message:(NSString *)message;

@end

/**
 GizDataAccessLogin类为APP开发者提供登录机智云的函数。
 
 我们提供匿名登录方式登录到机智云，这种方式不需要输入用户名密码，使APP的用户登录过程更简单。
 */
@interface GizDataAccessLogin : NSObject

- (id)init NS_UNAVAILABLE;

/**
 *
 * 初始化GizDataAccessLogin类实例。只有在类实例初始化时才能设置相应的回调，才可以得到用户登录的结果
 *
 * @param delegate 使用此类方法相应的回调
 *
 * @return GizDataAccessLogin类实例
 *
 */
- (id)initWithDelegate:(id<GizDataAccessLoginDelegate>)delegate;

/**
 *
 * 向指定的手机号发送验证码
 *
 * @param phone 手机号
 *
 */
- (void)requestSendVerifyCode:(NSString *)phone;

/**
 *
 * 使用用户名、密码注册普通用户
 *
 * @param username      用户名，可以是手机号、邮箱和其他
 * @param password      密码
 * @param code          如果用户名是手机，则输入验证码
 * @param accountType   账号类型
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccess:didRegisterUser:token:result:message:]
 *
 */
- (void)registerUser:(NSString *)username password:(NSString *)password code:(NSString *)code accountType:(GizDataAccessAccountType)accountType;

/**
 *
 * 匿名登录。系统会自动生成一个用户名，登录成功就会生成对应的 uid 和 token
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccess:didLogin:token:result:message:]
 *
 */
- (void)loginAnonymous;

/**
 *
 * 第三方用户登录。使用已注册好的第三方用户和密码，用第三方 SDK 获取到相应的 uid, token 即可登录
 *
 * @param thirdAccountType  第三方账号类型，目前支持新浪、百度、QQ
 * @param uid               通过第三方 SDK 得到的用户 id
 * @param token             通过第三方 SDK 得到的用户 token
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccess:didLogin:token:result:message:]
 *
 */
- (void)loginWithThirdAccountType:(GizDataAccessThirdAccountType)thirdAccountType uid:(NSString *)uid token:(NSString *)token;

/**
 *
 * 用户登录
 *
 * @param username 用户名，可以使用普通用户、手机用户、邮箱用户登录
 * @param password 密码
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccess:didLogin:token:result:message:]
 *
 */
- (void)login:(NSString *)username password:(NSString *)password;

/**
 *
 * 修改密码
 *
 * @param token         登录成功后得到的token（用户鉴权令牌）
 * @param oldPassword   旧密码
 * @param newPassword   新密码
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccess:didChangeUserPassword:message:]
 *
 */
- (void)changeUserPassword:(NSString *)token oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

/**
 *
 * 重置手机或邮箱用户密码
 *
 * @param username      只能是手机号或者邮箱
 * @param code          用户类型是手机时，需要输入手机验证码
 * @param newPassword   用户类型是手机时，需要输入新密码
 * @param accountType   账号类型
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccess:didChangeUserPassword:message:]
 *
 */
- (void)resetPassword:(NSString *)username code:(NSString *)code newPassword:(NSString *)newPassword accountType:(GizDataAccessAccountType)accountType;

/**
 *
 * 修改实名用户为手机用户
 *
 * @param token         登录成功后得到的token（用户鉴权令牌）
 * @param username      用户名，只能是手机号和邮箱
 * @param code          用户类型是手机时，填写手机验证码
 * @param accountType   账号类型
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccess:didChangeUserInfo:message:]
 *
 */
- (void)changeUserInfo:(NSString *)token username:(NSString *)username code:(NSString *)code accountType:(GizDataAccessAccountType)accountType;

/**
 * 转换匿名用户为实名用户（第三方账号除外）
 *
 * @param token         登录成功后得到的token（用户鉴权令牌）
 * @param username      用户名，可以是手机号、邮箱、普通用户名
 * @param password      密码
 * @param code          用户类型是手机时，填写手机号码
 * @param accountType   账号类型。该接口 kGizDataAccessAccountTypeNormal 包含邮箱的方法，所以 kGizDataAccessAccountTypeEmail 不适用于这个接口
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccess:didTransAnonymousUser:message:]
 *
 */
- (void)transAnonymousUser:(NSString *)token username:(NSString *)username password:(NSString *)password code:(NSString *)code accountType:(GizDataAccessAccountType)accountType;

@end
