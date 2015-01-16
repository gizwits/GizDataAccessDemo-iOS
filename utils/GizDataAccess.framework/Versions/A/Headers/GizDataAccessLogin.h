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
 * 匿名登录回调
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
 * @see 触发函数：[GizDataAccessLogin loginAnonymous]
 *
 */
- (void)gizDataAccessDidLogin:(GizDataAccessLogin *)login uid:(NSString *)uid token:(NSString *)token result:(GizDataAccessErrorCode)result message:(NSString *)message;

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
 * 匿名登录。系统会自动生成一个用户名，登录成功就会生成对应的 uid 和 token
 *
 * @see 对应的回调接口：[GizDataAccessLoginDelegate gizDataAccessDidLogin:uid:token:result:message:]
 *
 */
- (void)loginAnonymous;

@end
