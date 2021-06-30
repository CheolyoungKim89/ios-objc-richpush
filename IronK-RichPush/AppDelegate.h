//
//  AppDelegate.h
//  IronK-RichPush
//
//  Created by Cheol-Young Kim on 2021/06/28.
//

#import <UIKit/UIKit.h>

////IOS10
#if __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

////IOS10
#if __IPHONE_10_0
@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>
////

#else
@interface AppDelegate : UIResponder <UIApplicationDelegate>
////
#endif
////

@property (strong, nonatomic) UIWindow * window;

@end

