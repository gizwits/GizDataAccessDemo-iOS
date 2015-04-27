//
//  GizDataAccessSource.h
//  GizDataAccess
//
//  Created by xpg on 14/12/30.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GizDataAccess/GizDataAccessDifinitions.h>

@class GizDataAccessSource;

/**
 GizDataAccessSourceDelegate是GizDataAccessSource类的委托协议，为APP开发者处理蓝牙数据上传下载结果提供委托函数。
 */
@protocol GizDataAccessSourceDelegate <NSObject>
@optional

/**
 *
 * 上传数据到服务器回调
 *
 * @param source 当前GizDataAccessSource实例
 *
 * @param result 数据上传结果，成功或失败。详情参考 GizDataAccessErrorCode 定义
 *
 * @param message 数据上传结果描述，成功为 "Success"
 *
 * @see 触发函数：[GizDataAccessSource loadData:productKey:deviceSN:startTime:endTime:limit:skip:]
 *
 */
- (void)gizDataAccess:(GizDataAccessSource *)source didSaveData:(GizDataAccessErrorCode)result message:(NSString *)message;

/**
 *
 * 从服务器获取数据回调
 *
 * @param source 当前GizDataAccessSource实例
 *
 * @param data 获取到的数据。如果获取失败则为nil
 *
 * @param result 数据获取结果，成功或失败。详情参考 GizDataAccessErrorCode 定义
 *
 * @param message 数据获取结果描述，成功为 "Success"
 *
 * @note data数据类型：@[
 *     @"attrs" : {
 *          [dynamic_keys] : [dynamic_values],
 *          ...
 *     },
 *     @"uid" : [uid],
 *     @"sn" : [sn],
 *     @"ts" : [ts],
 *     @"product_key" : [product_key]
 * ]
 *
 * @see 触发函数：[GizDataAccessSource saveData:productKey:deviceSN:data:]
 *
 */
- (void)gizDataAccess:(GizDataAccessSource *)source didLoadData:(NSArray *)data result:(GizDataAccessErrorCode)result errorMessage:(NSString *)message;

@end

/**
 GizDataAccessSource类为APP开发者提供蓝牙数据上传和获取的函数。
 
 蓝牙数据上传及获取，应在用户登录token有效期内进行，并指定蓝牙设备类型和识别码。蓝牙数据上传时需要设置数据的产生时间，蓝牙数据获取时可以获取指定时间段的数据条目。
 */
@interface GizDataAccessSource : NSObject

- (id)init NS_UNAVAILABLE;

/**
 *
 * 初始化GizDataAccessSource类实例。只有类实例初始化的时候，才可以设置相应的回调
 *
 * @param delegate 使用此类方法相应的回调
 *
 */
- (id)initWithDelegate:(id<GizDataAccessSourceDelegate>)delegate;

/**
 * 上传蓝牙数据到机智云服务器。
 * 此接口只支持成功上传一条数据，如果APP有多条数据需要上传，应通过多次接口调用完成。
 *
 * @param token 用户登录回调给的对应字符串
 *
 * @param productKey 蓝牙设备类型唯一识别码
 *
 * @param deviceSN 蓝牙设备序列号
 *
 * @param data 自定义属性，对应的格式为标准JSON。JSON对象与蓝牙数据点应相一致，如果不一致，则会上传失败。一个JSON对象表示一条数据，如果传入多个JSON对象，则只有第一个JSON对象能够上传成功。
 *
 * @note data示例：@[
 *   @{@"ts": [timestamp],
 *         @"attrs": @{
 *            [dynamic_keys]: [dynamic_values], ...
 *         }
 *      }
 *   ]
 *
 * @see 对应的回调接口：[GizDataAccessSourceDelegate gizDataAccess:didSaveData:message:]
 *
 */
- (void)saveData:(NSString *)token productKey:(NSString *)productKey deviceSN:(NSString *)deviceSN data:(NSArray *)data;

/**
 * 从机智云服务器获取蓝牙数据，接口参数为获取数据的条件。如果APP希望获取从 开始时间 之后的所有数据，将 截止时间 设置为晚于 最新数据的产生时间 即可。如果APP希望获取 截止时间 之前的所有数据，将 开始时间 设置为早于 最早数据的产生时间 即可。
 *
 * @param token 用户登录回调给的对应字符串
 *
 * @param productKey 蓝牙设备类型唯一识别码
 *
 * @param deviceSN 蓝牙设备序列号
 *
 * @param startTime 开始时间（以格林威治标准时间 1970年1月1日00:00:00.000 为准的时间戳）。整数0为 格林威治标准时间，正整数为晚于 格林威治标准时间 的时间，负整数为早于 格林威治标准时间 的时间。
 *
 * @param endTime 截止时间（以格林威治标准时间 1970年1月1日00:00:00.000 为准的时间戳）。整数0为 格林威治标准时间，正整数为晚于 格林威治标准时间 的时间，负整数为早于 格林威治标准时间 的时间。
 *
 * @param limit 限制最大获取条数，应指定为大于等于0的数。如果指定为0，则最多返回20条数据，如果指定负数，则获取失败。
 *
 * @param skip 从头开始跳过几条数据，应指定为大于等于0的数。如果指定负数，则获取失败。
 *
 * @see 对应的回调接口：[GizDataAccessSourceDelegate gizDataAccess:didLoadData:result:errorMessage:]
 *
 */
- (void)loadData:(NSString *)token productKey:(NSString *)productKey deviceSN:(NSString *)deviceSN startTime:(int64_t)startTime endTime:(int64_t)endTime limit:(NSInteger)limit skip:(NSInteger)skip;

@end
