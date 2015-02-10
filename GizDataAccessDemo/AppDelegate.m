/**
 * AppDelegate.m
 *
 * Copyright (c) 2014~2015 Xtreme Programming Group, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "AppDelegate.h"
//#import "AutoLogin.h"
#import "Login.h"
#import <GizDataAccess/GizDataAccess.h>

NSString *_token = nil;
NSArray *_datas = nil;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Init SDK
    [GizDataAccess startWithAppID:@"7a9a7b387df64979ac67518fb0b6649e"];
//    [GizDataAccess setDataAccessDomainName:@"apiv4.iotsdk.com"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    self.navCtrl = [[UINavigationController alloc] initWithRootViewController:[[Login alloc] init]];
//    self.navCtrl = [[UINavigationController alloc] initWithRootViewController:[[AutoLogin alloc] init]];
    self.navCtrl.navigationBar.translucent = NO;
    self.window.rootViewController = self.navCtrl;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Properties
- (MBProgressHUD *)hud
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.window];
    if(nil == hud)
    {
        hud = [[MBProgressHUD alloc] initWithWindow:self.window];
        [self.window addSubview:hud];
    }
    return hud;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)gizDataAccessDidSaveData:(GizDataAccessSource *)source result:(GizDataAccessErrorCode)result message:(NSString *)message
{
    NSLog(@"Save data result: %@ message: %@", @(result), message);
}

- (void)gizDataAccessDidLoadData:(GizDataAccessSource *)source data:(NSArray *)data result:(GizDataAccessErrorCode)result errorMessage:(NSString *)message
{
    NSLog(@"Receive data: %@, result: %@ message: %@", data, @(result), message);
}

@end
