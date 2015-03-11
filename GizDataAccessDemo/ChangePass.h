//
//  ChangePass.h
//  GizDataAccessDemo-Debug
//
//  Created by GeHaitong on 15/2/10.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    kChangePassTypeModify,
    kChangePassTypeResetPhone,
    kChangePassTypeResetEmail
}ChangePassType;

@interface ChangePass : UIViewController

- (id)init NS_UNAVAILABLE;
- (id)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (id)initWithType:(ChangePassType)type;

@end
