//
//  AppDelegate.m
//  IronK-RichPush
//
//  Created by Cheol-Young Kim on 2021/06/28.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // push
    // APNS에 디바이스를 등록한다.
    if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0){
        //Right, that is the point
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) categories:nil]];
        } else {
            // Fallback on earlier versions
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil]];
        }
    }else{
        //register to receive notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
    if (@available(iOS 10.0, *)) {
        [self setUserNotification];
    } else {
        // Fallback on earlier versions
    }
    
    return YES;
}

/**
 푸시 등록
 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

/**
 푸시 토큰
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *strDeviceToken;
    if (@available(iOS 13.0, *)) {
        strDeviceToken = [self hexadecimalStringFromData:deviceToken];
    }else{
        strDeviceToken = [[[[deviceToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    }
}

- (NSString *)hexadecimalStringFromData:(NSData *)data
{
  NSUInteger dataLength = data.length;
  if (dataLength == 0) {
    return nil;
  }

  const unsigned char *dataBuffer = (const unsigned char *)data.bytes;
  NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for (int i = 0; i < dataLength; ++i) {
    [hexString appendFormat:@"%02x", dataBuffer[i]];
  }
  return [hexString copy];
}

//GCM iOS 3 ~ 10까지 앱이 포그라운드 상태에서 푸시를 받은 경우
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}
//GCM Silent Notification 관련 "content-available": 1, "sound":""의 경우 이곳을 탄다. 여기서 type이 뭔지를 보고 badge를 늘린다.
//iOS 7+ 앱이 백그라운드거나 포그라운드 상태일 때 푸시를 받으면 해당 함수를 호출한다.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"[didReceiveRemoteNotification] Remote notification : %@",userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}

//iOS 10+ 푸시 알림 설정
- (void)setUserNotification API_AVAILABLE(ios(10.0)){
    
    // 요청 알림
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //사용자 알림을 사용하는 데 동의합니다
        }
        
        if( !error ){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
    }];
    
    // 프록시 설정 Delegate 연결
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    
    UNNotificationAction *unlocking = [UNNotificationAction actionWithIdentifier:@"unlocking"
                                                                           title:@"unlocking"
                                                                         options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction *destructive = [UNNotificationAction actionWithIdentifier:@"destructive"
                                                                             title:@"destructive"
                                                                           options:UNNotificationActionOptionDestructive];
    UNNotificationAction *foreground = [UNNotificationAction actionWithIdentifier:@"foreground"
                                                                            title:@"foreground"
                                                                          options:UNNotificationActionOptionForeground];
    UNTextInputNotificationAction *input = [UNTextInputNotificationAction actionWithIdentifier:@"text" title:@"text" options:UNNotificationActionOptionAuthenticationRequired textInputButtonTitle:@"text_btn" textInputPlaceholder:@"placeholder"];
    
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"ceshi"
                                                                              actions:@[unlocking, destructive, foreground, input] intentIdentifiers:@[@""]
                                                                              options:UNNotificationCategoryOptionNone];
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:category]];
}

/// Foreground 상태일 때, ios 10 이상일때 푸시를 받은 경우
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(ios(10.0)){

    NSLog(@"[willPresentNotification] Remote notification : %@",notification.request.content.userInfo);

    completionHandler(UNNotificationPresentationOptionAlert);
}

//앱이 실행되어있는상태에서 푸쉬를 받고 푸쉬 알림을 클릭해서 앱에 다시 들어올경우
// iOS 10이상에서는 앱이 실행돼있거나 실행돼있지 않은 경우 모두 사용자가 푸시 클릭시 해당 메소드가 호출됨
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    
    NSLog(@"[didReceiveNotificationResponse] Remote notification : %@",response.notification.request.content.userInfo);
    
    completionHandler();
}

@end
