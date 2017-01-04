//
//  RetrieveAggregatedData.h
//  GizDataAccessDemo-Debug
//
//  Created by GeHaitong on 15/7/28.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RetrieveAggregatedData;

@protocol RetrieveAggregatedDataDelegate <NSObject>

- (void)retrieveAggregatedData:(RetrieveAggregatedData *)loadData didLoaded:(NSArray *)data result:(GizDataAccessErrorCode)result;

@end

@interface RetrieveAggregatedData : UIViewController

- (id)initWithDelegate:(id <RetrieveAggregatedDataDelegate>)delegate;

- (void)show;

@end
