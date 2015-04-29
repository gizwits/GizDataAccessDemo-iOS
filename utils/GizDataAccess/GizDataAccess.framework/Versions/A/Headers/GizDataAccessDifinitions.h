//
//  GizDataAccessDifinitions.h
//  GizDataAccess
//
//  Created by xpg on 14/12/30.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#ifndef GizDataAccess_GizDataAccessDifinitions_h
#define GizDataAccess_GizDataAccessDifinitions_h

#define GIZ_ERRORMSG_SUCCESS        @"Success"
#define GIZ_ERRORMSG_FAILED         @"Failed"

/**
 * GizDataAccessErrorCode枚举，描述了SDK提供的所有错误码定义。
 */
typedef NS_ENUM(NSInteger, GizDataAccessErrorCode)
{
    /**
     * 无错误
     */
    kGizDataAccessErrorNone                      = 0,
    /**
     * 连接失败
     */
    kGizDataAccessErrorConnectionFailed          = 8001,
    /**
     * 连接超时
     */
    kGizDataAccessErrorConnectionTimeout         = 8002,
    /**
     * 参数错误
     */
    kGizDataAccessErrorInvalidParameters         = 8003,
    /**
     * Product Key 非法
     */
    kGizDataAccessErrorInvalidProductKey         = 9002,
    /**
     * App ID 非法
     */
    kGizDataAccessErrorInvalidAppID              = 9003,
    /**
     * Token 非法
     */
    kGizDataAccessErrorInvalidToken              = 9004,
    /**
     * 用户不存在
     */
    kGizDataAccessErrorUserNotExists             = 9005,
    /**
     * Token 过期
     */
    kGizDataAccessErrorTokenExpired              = 9006,
    /**
     * 服务器错误
     */
    kGizDataAccessErrorServer                    = 9008,
    /**
     * 手机验证码过期
     */
    kGizDataAccessErrorCodeExpired               = 9009,
    /**
     * 手机验证码错误
     */
    kGizDataAccessErrorCodeInvalid               = 9010,
    /**
     * 数据格式错误
     */
    kGizDataAccessErrorFormInvalid               = 9015,
    /**
     * 手机号不可用
     */
    kGizDataAccessErrorPhoneUnavaliable          = 9018,
    /**
     * 用户名不可用
     */
    kGizDataAccessErrorUsernameUnavaliable       = 9019,
    /**
     * 用户名或密码错误
     */
    kGizDataAccessErrorUsernameOrPasswordError   = 9020,
    /**
     * 其他情况
     */
    kGizDataAccessErrorOtherwise                 = 9999
};

/**
 GizDataAccessThirdAccountType枚举，描述了SDK提供的所有第三方账号类型的定义。
 */
typedef NS_ENUM(NSInteger, GizDataAccessThirdAccountType)
{
    /**
     * 使用新浪账号登陆
     */
    kGizDataAccessThirdAccountTypeSINA           = 0,
    /**
     * 使用百度账号登陆
     */
    kGizDataAccessThirdAccountTypeBAIDU,
    /**
     * 使用 QQ 账号登陆
     */
    kGizDataAccessThirdAccountTypeQQ
};

/**
 * GizDataAccessAccountType枚举，描述了SDK提供的所有支持账号类型的定义。
 */
typedef NS_ENUM(NSInteger, GizDataAccessAccountType)
{
    /**
     * 普通账号
     */
    kGizDataAccessAccountTypeNormal = 0,
    /**
     * 手机账号
     */
    kGizDataAccessAccountTypePhone,
    /**
     * 邮箱账号
     */
    kGizDataAccessAccountTypeEmail
};

#endif
