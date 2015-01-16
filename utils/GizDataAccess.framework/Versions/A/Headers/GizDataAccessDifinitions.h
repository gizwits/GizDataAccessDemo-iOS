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

/**
 GizDataAccessErrorCode枚举，描述了SDK提供的所有错误码定义。
 */
typedef NS_ENUM(NSInteger, GizDataAccessErrorCode)
{
    /**
     无错误
     */
    kGizDataAccessErrorNone              = 0,
    /**
     Product Key 非法
     */
    kGizDataAccessErrorInvalidProductKey = 9002,
    /**
     App ID 非法
     */
    kGizDataAccessErrorInvalidAppID      = 9003,
    /**
     Token 非法
     */
    kGizDataAccessErrorInvalidToken      = 9004,
    /**
     Token 过期
     */
    kGizDataAccessErrorTokenExpired      = 9006,
    /**
     服务器错误
     */
    kGizDataAccessErrorServer            = 9008,
    /**
     数据格式错误
     */
    kGizDataAccessErrorFormInvalid       = 9015,
    /**
     其他情况
     */
    kGizDataAccessErrorOtherwise         = 9999
};

#endif
