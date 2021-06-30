//
//  NotificationService.m
//  NotificationServiceExtension
//
//  Created by Cheol-Young Kim on 2021/06/28.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    self.bestAttemptContent.body = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.body];
    
    NSError *error;
    
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"image" URL:[[NSBundle mainBundle] URLForResource:@"KANGCHEOLE_BANNER" withExtension:@"png"] options:nil error:&error];
    
    if (error) {
        NSLog(@"Notification Extension Error : %@",error);
    } else {
        self.bestAttemptContent.attachments = @[attachment];
    }
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
