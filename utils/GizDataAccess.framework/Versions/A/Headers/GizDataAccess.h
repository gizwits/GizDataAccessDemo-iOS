//
//  GizDataAccess.h
//  GizDataAccess
//
//  Created by xpg on 14/12/30.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GizDataAccess/GizDataAccessLogin.h>
#import <GizDataAccess/GizDataAccessSource.h>

/**
 GizDataAccess类为APP开发者提供了蓝牙数据接入SDK的入口函数。
 */
@interface GizDataAccess : NSObject

/**
 * 获取sdk版本号
 *
 * @return sdk版本号
 */
+ (NSString *)version;

- (id)init NS_UNAVAILABLE;

/**
 *
 * 使用 appid 初始化SDK。开发者的APP必须使用此入口函数初始化SDK，否则蓝牙数据无法接入机智云。
 *
 * @param appid APP开发者在机智云 site.gizwits.com 创建设备时分配的 Application ID
 *
 * @return GizDataAccess单例对象
 *
 */
+ (instancetype)startWithAppID:(NSString *)appid;

#ifdef __INTERNAL_TESTAPI__
/*
 * 设置数据接入域名
 *
 * @param apiName 数据接入的域名
 *
 * @discussion 默认的域名是 api.gizwits.com
 *
 */
+ (void)setDataAccessDomainName:(NSString *)apiName;
#endif

@end
