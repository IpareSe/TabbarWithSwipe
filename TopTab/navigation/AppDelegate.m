//
//  AppDelegate.m
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 27/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import "AppDelegate.h"
#import "Language.h"
#import <GoogleMaps/GoogleMaps.h>
#import "ConfirmRequestVC.h"
#import "AppConstant.h"
#import "HomeVC.h"
#import "LoginVC.h"
#import "SharedClass.h"
#import <AFNetworking.h>
#import "TestFairy.h"
#import "ArrivingVC.h"
#import "PayPalMobile.h"
#import "WebserviceManager.h"
#import "SharedClass.h"
#import "AppConstant.h"
#import "DriverScheduleVC.h"
#import "ArrivedVC.h"
#import "EndTripVC.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface AppDelegate ()<CLLocationManagerDelegate>
{
    CLLocationManager * locationmanager;
    CLLocation *crnLoc;
    NSNumber *longitude;
    NSNumber *latitude;
    NSString *strMsg;
    NSString *Ptype;
    NSString *TripType;
    UIStoryboard *mainStoryboard;
    SliderContainerVC *rvc;
    
    //01/12/2016
    BOOL isUpdateAvailable;
    BOOL isAlertPresent;
    NSTimer *localnotiTimer;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Crashlytics class]]];
    
    // self.strIPAddress = @"52.29.84.196";
    self.strIPAddress = @"3.127.192.187";
    // self.strIPAddress = @"businesstaxiapp.com";
    
    self.portNum = 6878;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
     [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    
    self.internetReachable.reachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@" InternetConnection Says Reachable(%@)", reachability.currentReachabilityString];
        NSLog(@"%@", temp);
    };
    
    self.internetReachable.unreachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"InternetConnection Block Says Unreachable(%@)", reachability.currentReachabilityString];
        
        NSLog(@"%@", temp);
    };

    [self.internetReachable startNotifier];
    
    //[self VersionUpdateOnServerAPICall];

    [GMSServices provideAPIKey:@"AIzaSyD2iwaQlF4-EWS5NhrdUXhPDE6bPvaGFQQ"]; //Sajid New

    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"AZGXyxeGu-cnFg8k9HKVHmB7NeILMeQGQZn-fuJ8OSUwYddaSP42ZvQZAMwj5on8MoMRPjOscTO-Jjkj", PayPalEnvironmentSandbox : @"AU4JR3wWWFoKROv-VrIPW9mP-mVoVOhtWuOpvuIjgE_ARjIdFwEbr7iU_lPZdhjcxkztpwSVlZShQH2S"}];
    
    
    mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    rvc = (SliderContainerVC*)[mainStoryboard instantiateViewControllerWithIdentifier:@"SliderContainerVC"];
    self.window.rootViewController = rvc;
    

    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined )
    {
        //custom alert
        [self setCustomAlertForLocation];
    }else{
 
    }
//
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        [application registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
  
    if ([[launchOptions allKeys] containsObject: UIApplicationLaunchOptionsRemoteNotificationKey])
    {
        NSDictionary *dic=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSDictionary *dictTemp =[dic valueForKey:@"aps"];
        
        if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"sentrequest"])
        {
        
            objShare.isFromNotification = YES;
            objShare.isBackgroundNotif = YES;
            strMsg = [dictTemp objectForKey:@"alert"];
            [[NSUserDefaults standardUserDefaults]setObject:dic forKey:@"checkNotification"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"userid"] forKey:@"CustomerId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"request_id"] forKey:@"RequestId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"car_id"] forKey:@"CarId"];
            

            int timer = (int)_timeLoader;
            NSLog(@"TIMER VALUE %d",timer);

        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"adminAssign"])
        {
            objShare.isFromNotificationSchedule = YES;
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"userid"] forKey:@"CustomerId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"request_id"] forKey:@"RequestId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"car_id"] forKey:@"CarId"];
        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"adminAssignNoAccept"])
        {
            objShare.isFromNotificationForNotAcceptAnyOne = YES;
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"userid"] forKey:@"CustomerId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"request_id"] forKey:@"RequestId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"car_id"] forKey:@"CarId"];
        }
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *comString;
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"changeLan"] == NULL)
    {
        //Nipa
        language = @"nl";
        comString = language;
        [[NSUserDefaults standardUserDefaults] setValue:comString forKey:@"changeLan"];
    }
    else
    {
        comString = [[NSUserDefaults standardUserDefaults]valueForKey:@"changeLan"];
    }
    
    if([comString isEqualToString:@"en"] ||
       [comString isEqualToString:@"en-us"] ||
       [comString isEqualToString:@"en-au"] ||
       [comString isEqualToString:@"en-nz"] ||
       [comString isEqualToString:@"en-za"] ||
       [comString isEqualToString:@"en-tt"] ||
       [comString isEqualToString:@"en-gb"] ||
       [comString isEqualToString:@"en-ca"] ||
       [comString isEqualToString:@"en-ie"] ||
       [comString isEqualToString:@"en-jm"] ||
       [comString isEqualToString:@"en-bz"] ||
       [comString isEqualToString:@"en-US"] ||
       [comString isEqualToString:@"en-IN"])
    {
        _bundle = [NSBundle bundleWithPath:[[ NSBundle mainBundle ] pathForResource:@"en" ofType:@"lproj"]];
        [defaults setObject:comString forKey:@"AppLanguage"];
    }
    else
    {
        _bundle = [NSBundle bundleWithPath:[[ NSBundle mainBundle ] pathForResource:@"nl" ofType:@"lproj"]];
        [defaults setObject:comString forKey:@"AppLanguage"];
    }

    
    [defaults synchronize];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    [self getLocation]; //Nipa
    
    
    if(UDUserId){
       
            [self MethodSetServerLanguageAPIcall];
            [self socketConnect];
            [self connectUserToSocket];
        }
    
    [self.window makeKeyAndVisible];
    
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    UILocalNotification *localNotif = [launchOptions
                                       objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token {
    
    NSString *strDeviceToken = [[[[token description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    [[NSUserDefaults standardUserDefaults] setObject:strDeviceToken forKey:@"DeviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"strDeviceToken >> %@",strDeviceToken);
    if(UDUserId){
        [self MethodUpdateDeviceTokenAPIcall];
    }
}
-(void)updateDeviceTokenValue{
    
    
}

#pragma mark Push Notification Receieved Method
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
//    
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{

    NSDictionary *dictTemp =[userInfo valueForKey:@"aps"];
    strMsg = [dictTemp objectForKey:@"alert"];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:userInfo forKey:@"checkNotification"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"usercancelrequest"])
        {
            if([[dictTemp valueForKey:@"is_future"]isEqualToString:@"1"])
            {
                TripType = @"future";
            }
            else
            {
                TripType = @"current";
            }
            Ptype = @"usercancelrequest";
            UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                         message:strMsg
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil, nil];
            [alert_notification show];
            
        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"adminAssign"])
        {
            
            Ptype = @"adminAssign";
            UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                         message:strMsg
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil, nil];
            [alert_notification show];

        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"adminAssignNoAccept"])
        {
            
            Ptype = @"adminAssignNoAccept";
            UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                         message:strMsg
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil, nil];
            [alert_notification show];
            
        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"Reminder"])
        {
            Ptype = @"Reminder";
            UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                         message:strMsg
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil, nil];
            [alert_notification show];
            
        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"login from other device"]){
            //12/12/2016
            Ptype = @"login from other device";
            UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                                         message:strMsg
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil, nil];
            [alert_notification show];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"userid"] forKey:@"CustomerId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"request_id"] forKey:@"RequestId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"car_id"] forKey:@"CarId"];
            
            NSLog(@"CustomerId : %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"CustomerId"]);
             NSLog(@"RequestId : %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"RequestId"]);
            
            NSLog(@"CustomerId : %@",[[NSUserDefaults standardUserDefaults]stringForKey:@"CustomerId"]);
            NSLog(@"RequestId : %@",[[NSUserDefaults standardUserDefaults]stringForKey:@"RequestId"]);
            if ([objShare isInternetConnected]) {
                [[WebserviceManager sharedInstance] GetUTCTimeAPI:nil withCompletion:^(BOOL isSuccess, NSDictionary *responce) {
                    if (isSuccess)
                    {
                        if ([[responce valueForKey:@"response_status"] integerValue] == 1)
                        {
                            strMsg = [dictTemp objectForKey:@"alert"];
                            NSString *strDate = [strMsg substringFromIndex: [strMsg length] - 19];
                            NSDate *dateServer = [self StringFromDate:strDate];
                            
                            NSString *strUTC = [responce valueForKey:@"server_utc_time"];
                            NSString *strdateTodayServer = [strUTC substringToIndex:19];
                            NSDate *dateTodayServer = [self StringFromDate:strdateTodayServer];
                            
                            NSTimeInterval distanceBetweenDates = [dateTodayServer timeIntervalSinceDate:dateServer];
                            NSLog(@"%f",distanceBetweenDates);
                            if(distanceBetweenDates >= 0 && distanceBetweenDates < 15)
                            {
                                _timeLoader= 15-distanceBetweenDates;
                            }
                            else
                            {
                                _timeLoader = 0;
                                
                                NSLog(@"%f",distanceBetweenDates);
                                
                                NSString *alertMsg = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_miss_accept_request", @"Localizable", [AppDel bundle], nil)];
                                
                                UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                                                             message:alertMsg
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"Ok"
                                                                                   otherButtonTitles:nil, nil];
                                [alert_notification show];
                                
                            }
                            int timer = (int)_timeLoader;
                            NSLog(@"%d",timer);
                            if(timer > 0 && timer <= 15)
                            {
                                UIViewController  *vc = [self visibleViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
                                if ([vc isKindOfClass:[SliderContainerVC class]]){
                                    
                                    SliderContainerVC  *vc1 = (SliderContainerVC *)vc;
                                    if([vc1.destinationViewController isKindOfClass:[UINavigationController class]]){
                                        UINavigationController  *nav = (UINavigationController *)vc1.destinationViewController;
                                        UIViewController  *vc2 = (UIViewController *)nav.viewControllers.lastObject;
                                        if ([vc2 isKindOfClass:[ConfirmRequestVC class]]){
                                            
                                        }else{
                                            [SharedClass objSharedClass].selectSettingsOption(1);
                                        }
                                        
                                    }else{
                                        [SharedClass objSharedClass].selectSettingsOption(1);
                                    }
                                }
                                else{
                                    if([vc isKindOfClass:[UIAlertController class]]){
                                        
                                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                            //Background Thread
                                            [vc dismissViewControllerAnimated:YES completion:nil];
                                            vc.view.userInteractionEnabled = true;
                                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                                //Run UI Updates
                                                [SharedClass objSharedClass].selectSettingsOption(1);
                                            });
                                        });
                                    }
                                    else{
                                        [SharedClass objSharedClass].selectSettingsOption(1);
                                    }
                                }
                            }
                        }
                        else
                        {
                            
                        }
                    }
                }];
            }
        }
    }
    else
    {
        if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"usercancelrequest"])
        {
            if([[dictTemp valueForKey:@"is_future"]isEqualToString:@"1"])
            {
                TripType = @"future";
            }
            else
            {
                TripType = @"current";
            }
            Ptype = @"usercancelrequest";
            UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                         message:strMsg
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil, nil];
            [alert_notification show];
        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"adminAssign"])
        {
            
            Ptype = @"adminAssign";
            [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo valueForKey:@"aps"] valueForKey:@"badge"] integerValue];
            
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"userid"] forKey:@"CustomerId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"request_id"] forKey:@"RequestId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"car_id"] forKey:@"CarId"];
            
            SliderContainerVC *Slider = (SliderContainerVC *)self.window.rootViewController;
            UIViewController *currentViewController = Slider.nav.visibleViewController;
            
            if (![currentViewController isKindOfClass:[ConfirmRequestVC class]] && ![currentViewController isKindOfClass:[ArrivingVC class]] && ![currentViewController isKindOfClass:[ArrivedVC class]] && ![currentViewController isKindOfClass:[EndTripVC class]]  )
            {
                [SharedClass objSharedClass].selectSettingsOption(2);
            }
        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"adminAssignNoAccept"])
        {
            
            Ptype = @"adminAssignNoAccept";
            [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo valueForKey:@"aps"] valueForKey:@"badge"] integerValue];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"userid"] forKey:@"CustomerId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"request_id"] forKey:@"RequestId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"car_id"] forKey:@"CarId"];
            
            [SharedClass objSharedClass].selectSettingsOption(3);
        }
        
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"Reminder"])
        {
            Ptype = @"Reminder";
            SliderContainerVC *Slider = (SliderContainerVC *)self.window.rootViewController;
            UIViewController *currentViewController = Slider.nav.visibleViewController;
            
            if (![currentViewController isKindOfClass:[ConfirmRequestVC class]] && ![currentViewController isKindOfClass:[ArrivingVC class]] && ![currentViewController isKindOfClass:[ArrivedVC class]] && ![currentViewController isKindOfClass:[EndTripVC class]]  )
            {
                [SharedClass objSharedClass].selectSettingsOption(2);
            }
            
        }
        else if([[dictTemp valueForKey:@"pushtype"] isEqualToString:@"login from other device"]){
            //12/12/2016
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"UserId"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [objShare.timerupdateUserlatLong invalidate];
            objShare.timerupdateUserlatLong = nil;
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            rvc = (SliderContainerVC*)[mainStoryboard instantiateViewControllerWithIdentifier:@"SliderContainerVC"];
            self.window.rootViewController = rvc;
            
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"userid"] forKey:@"CustomerId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"request_id"] forKey:@"RequestId"];
            [[NSUserDefaults standardUserDefaults] setObject:[dictTemp valueForKey:@"car_id"] forKey:@"CarId"];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo valueForKey:@"aps"] valueForKey:@"badge"] integerValue];
            
            NSLog(@"CustomerId : %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"CustomerId"]);
            NSLog(@"RequestId : %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"RequestId"]);
            
            NSLog(@"CustomerId : %@",[[NSUserDefaults standardUserDefaults]stringForKey:@"CustomerId"]);
            NSLog(@"RequestId : %@",[[NSUserDefaults standardUserDefaults]stringForKey:@"RequestId"]);
            if ([objShare isInternetConnected]) {
                [[WebserviceManager sharedInstance] GetUTCTimeAPI:nil withCompletion:^(BOOL isSuccess, NSDictionary *responce) {
                    if (isSuccess)
                    {
                        if ([[responce valueForKey:@"response_status"] integerValue] == 1)
                        {
                            strMsg = [dictTemp objectForKey:@"alert"];
                            NSString *strDate = [strMsg substringFromIndex: [strMsg length] - 19];
                            NSDate *dateServer = [self StringFromDate:strDate];
                            
                            NSString *strUTC = [responce valueForKey:@"server_utc_time"];
                            NSString *strdateTodayServer = [strUTC substringToIndex:19];
                            NSDate *dateTodayServer = [self StringFromDate:strdateTodayServer];
                            
                            NSTimeInterval distanceBetweenDates = [dateTodayServer timeIntervalSinceDate:dateServer];
                            NSLog(@"%f",distanceBetweenDates);
                            if(distanceBetweenDates >= 0 && distanceBetweenDates < 15)
                            {
                                _timeLoader= 15-distanceBetweenDates;
                            }
                            else
                            {
                                _timeLoader = 0;
                                
                                NSLog(@"%f",distanceBetweenDates);
                                
                                NSString *alertMsg = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_miss_accept_request", @"Localizable", [AppDel bundle], nil)];
                                
                                UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                                                             message:alertMsg
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"Ok"
                                                                                   otherButtonTitles:nil, nil];
                                [alert_notification show];
                                
                            }
                            int timer = (int)_timeLoader;
                            NSLog(@"%d",timer);
                            if(timer > 0 && timer <= 15)
                            {
                                UIViewController  *vc = [self visibleViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
                                if ([vc isKindOfClass:[SliderContainerVC class]]){
                                    
                                    SliderContainerVC  *vc1 = (SliderContainerVC *)vc;
                                    if([vc1.destinationViewController isKindOfClass:[UINavigationController class]]){
                                        UINavigationController  *nav = (UINavigationController *)vc1.destinationViewController;
                                        UIViewController  *vc2 = (UIViewController *)nav.viewControllers.lastObject;
                                        if ([vc2 isKindOfClass:[ConfirmRequestVC class]]){
                                            
                                        }else{
                                            [SharedClass objSharedClass].selectSettingsOption(1);
                                        }
                                        
                                    }else{
                                        [SharedClass objSharedClass].selectSettingsOption(1);
                                    }
                                }
                                else{
                                    if([vc isKindOfClass:[UIAlertController class]]){
                                        
                                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                            //Background Thread
                                            [vc dismissViewControllerAnimated:YES completion:nil];
                                            vc.view.userInteractionEnabled = true;
                                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                                //Run UI Updates
                                                [SharedClass objSharedClass].selectSettingsOption(1);
                                            });
                                        });
                                    }
                                    else{
                                        [SharedClass objSharedClass].selectSettingsOption(1);
                                    }
                                }
                            }
                        }
                        else
                        {
                            
                        }
                    }
                }];
            }

        }
        
    }
    // call reject req 
}

//01/12/2016

- (UIViewController *)visibleViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        
        return [self visibleViewController:lastViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        
        return [self visibleViewController:selectedViewController];
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[SliderContainerVC class]])
    {
        SliderContainerVC *tabBarController = (SliderContainerVC *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = [[tabBarController.nav viewControllers] lastObject];
        return [self visibleViewController:selectedViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    
    return [self visibleViewController:presentedViewController];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 999){
        [self getLocation];
        if (IS_OS_8_OR_LATER)
        {
            UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
            
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
        
    }
    else if(alertView.tag == 1777){
        //01/12/2016
        if(buttonIndex == 0){
            isUpdateAvailable = false;
            NSString *iTunesLink = @"https://itunes.apple.com/us/app/holland-taxi-driver/id1076221896?ls=1&mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        }else{
            //            NSLog(@"Not now");
            NSDate *currentDate = [NSDate date];
            NSDate *sevenDaysAgo = [currentDate dateByAddingTimeInterval:7*24*60*60];
            NSLog(@"7 days ago: %@", sevenDaysAgo);
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"updateVersionDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            isUpdateAvailable = false;
        }
        [[NSUserDefaults standardUserDefaults] setBool:isUpdateAvailable forKey:@"isUpdateAvailable"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        SliderContainerVC *Slider = (SliderContainerVC *)self.window.rootViewController;
        UIViewController *currentViewController = Slider.nav.visibleViewController;
        
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([Ptype isEqualToString:@"usercancelrequest"])
        {
            if([title isEqualToString:@"Ok"])
            {
                [SharedClass objSharedClass].selectSettingsOption(0);
            }
        }
        else if([Ptype isEqualToString:@"adminAssign"])
        {
            if([title isEqualToString:@"Ok"])
            {
                if (![currentViewController isKindOfClass:[ConfirmRequestVC class]] && ![currentViewController isKindOfClass:[ArrivingVC class]] && ![currentViewController isKindOfClass:[ArrivedVC class]] && ![currentViewController isKindOfClass:[EndTripVC class]]  )
                {
                    [SharedClass objSharedClass].selectSettingsOption(2);
                }
            }
        }
        else if([Ptype isEqualToString:@"adminAssignNoAccept"])
        {
            if([title isEqualToString:@"Ok"])
            {
                [SharedClass objSharedClass].selectSettingsOption(3);

            }
        }
        else if([Ptype isEqualToString:@"Reminder"])
        {
            if([title isEqualToString:@"Ok"])
            {
                if (![currentViewController isKindOfClass:[ConfirmRequestVC class]] && ![currentViewController isKindOfClass:[ArrivingVC class]] && ![currentViewController isKindOfClass:[ArrivedVC class]] && ![currentViewController isKindOfClass:[EndTripVC class]]  )
                {
                   
                    /*DriverScheduleVC *rvc1 = (DriverScheduleVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriverScheduleVC"];
                    if([rvc.nav isKindOfClass:[UINavigationController class]])
                    {
                        [rvc.nav pushViewController:rvc1 animated:YES];
                    }
                    else{
                        [rvc.navigationController pushViewController:rvc1 animated:YES];
                    }*/
                    [SharedClass objSharedClass].selectSettingsOption(2);

                }
            }
        }
        
        else if([Ptype isEqualToString:@"login from other device"]){
            //12/12/2016
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"UserId"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [objShare.timerupdateUserlatLong invalidate];
            objShare.timerupdateUserlatLong = nil;
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            rvc = (SliderContainerVC*)[mainStoryboard instantiateViewControllerWithIdentifier:@"SliderContainerVC"];
            self.window.rootViewController = rvc;
        }

        else
        {
            
        }

    }
    
}
-(NSDate *)StringFromDate:(NSString *)DateLocal
{
    NSString *dateStr = DateLocal;
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [dateFormatter1 dateFromString:dateStr];
    if(IS_IPHONE_6P)
    {
        date1 = [date1 dateByAddingTimeInterval:0];
    }
    else
    {
        date1 = [date1 dateByAddingTimeInterval:0];
    }
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date1];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date1];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;

    NSDate *dateDestination = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date1] ;
    return dateDestination;
}

-(BOOL)isTimeIn24h{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    return is24h;
}

/*
-(void)callWebServiceforRejectRequest
{
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    //dataImgPic = UIImagePNGRepresentation(_imgProfle.image);
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    if(CustomerId)
    {
        [dictParameter setObject:CustomerId forKey:@"userid"];
    }
    if(RequestId)
    {
        [dictParameter setObject:RequestId forKey:@"request_id"];
    }
//    if(CarId)
//    {
//        [dictParameter setObject:CarId forKey:@"car_id"];
//    }
    NSString *lang;
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"AppLanguage" ]  isEqualToString:@"nl"])
    {
        lang = @"dutch";
    }
    else
    {
        lang = @"english";
        
    }
    [dictParameter setObject:lang forKey:@"language"];
    [dictParameter setObject:@"503" forKey:@"status"];
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@rejectrequest",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
     
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                              NSLog(@"%@",responseObject);
                                             if([[responseObject objectForKey:@"response_status"] integerValue]==1)
                                              {
                                                  [objShare hideLoading];
                                                  DisplaySimpleAlert(@"Cancel Request..")
                                                }
                                              else {
                                                  [objShare hideLoading];
                                                  //    DisplayAlert(@"Your Email Address Not Registered.")
                                              }
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              [objShare hideLoading];
                                              DisplaySimpleAlert(TRY_AGAIN_MSG)
                                          }];
    //[op start];

}
*/

-(void)setCustomAlertForLocation
{
    UIAlertView *alertLocation = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                            message:@"The app collect and send location data to servers to display driver location to passenger.Passenger can also track driver location before 15 min of trip starts and also helps passenger to find driver while pickup for trip."
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil, nil];
    alertLocation.tag = 999;
    [alertLocation show];
}



-(void)getLocation
{
    [objShare startLocationTracking];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if(newLocation.coordinate.latitude != oldLocation.coordinate.latitude && newLocation.coordinate.longitude != oldLocation.coordinate.longitude)
    {
        CLLocation *myLoc= newLocation;
//        NSLog(@"%f %f", myLoc.coordinate.latitude,myLoc.coordinate.longitude);
        // [locationmanager stopUpdatingLocation];
        
        
        objShare.applatitude = myLoc.coordinate.latitude;
        objShare.applongitude = myLoc.coordinate.longitude;
        objShare.appangle = myLoc.course;
        
        NSMutableDictionary *dict= [NSMutableDictionary new];
        [dict setObject:[NSString stringWithFormat:@"%f",objShare.applatitude] forKey:@"lat"];
        [dict setObject:[NSString stringWithFormat:@"%f",objShare.applongitude] forKey:@"lon"];
        [dict setObject:[NSString stringWithFormat:@"%f",objShare.appangle] forKey:@"course"];
        [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"coordinates"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
    
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    [locationmanager stopUpdatingLocation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Local Notification Fire after 4 Minutes (60*4)
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"UDDriverOnlineOfflineStatus"] isEqualToString:@"1"])
    {
        localnotiTimer = [NSTimer scheduledTimerWithTimeInterval:60.00*4 target:self selector:@selector(notificationSchedule) userInfo:nil repeats:TRUE];
        
//            localnotiTimer = [NSTimer scheduledTimerWithTimeInterval:10.00 target:self selector:@selector(notificationSchedule) userInfo:nil repeats:TRUE];
        
    }

}


-(void)notificationSchedule
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification* localNotification = [[UILocalNotification alloc]init];
    localNotification.fireDate = [NSDate date];
    
    
    localNotification.alertBody = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"BackgroundLocalNotificationText", @"Localizable", [AppDel bundle], nil)];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"Local Notification Reminder Fire...");

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Invalidate Timer For Local Notification which started when app enter in Background MANTHAN 12/oct/2017
    if (localnotiTimer)
    {
        [localnotiTimer invalidate];
    }
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if(UDUserId){
        if ([self.mainSocket isDisconnected])
        {
            [self socketConnect];
            [self connectUserToSocket];
        }
        
        // 05/06/2017 Nipa
        if([SharedClass objSharedClass].isCurrentTripOn){
            if(RequestId){
                [rvc killFlowAPICall:true];
            }
        }
       
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //01/12/2016
    [self CheckInternetConnecivity];
    NSLog(@"ISUPDATEAVAILABLE:%d",[[NSUserDefaults standardUserDefaults]boolForKey:@"isUpdateAvailable"]);
    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"isUpdateAvailable"]){
        NSDate *myDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"updateVersionDate"];
        if(myDate != nil){
            isAlertPresent = false;
            NSTimeInterval howLong = [[NSDate date] timeIntervalSinceDate:myDate];
            float days = howLong / 86400;
            NSLog(@"days:%f",days);
            if(days >= 7){
                if(!isAlertPresent){
                    isAlertPresent = true;
                    if([self needsUpdate])
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_version_alert", @"Localizable", [AppDel bundle], nil)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
                        [alertView setTag:1777];
                        [alertView show];
                    }
                  
                }
            }
        }else{
            if(!isAlertPresent){
                isAlertPresent = true;
                if([self needsUpdate])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_version_alert", @"Localizable", [AppDel bundle], nil)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
                    [alertView setTag:1777];
                    [alertView show];
                }
            }
        }
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if(UDUserId){
    [self socketDisconnect];
    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)VersionUpdateOnServerAPICall
{
    NSString  *strVersion = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    if ([objShare isInternetConnected])
    {
        NSString *lang;
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"AppLanguage" ]  isEqualToString:@"nl"])
        {
            lang = @"dutch";
        }
        else
        {
            lang = @"english";
        }
        
        NSMutableDictionary  *dictParameter = [[NSMutableDictionary alloc]init];
        [dictParameter setObject:@"2" forKey:@"user_type"];
        [dictParameter setObject:strVersion forKey:@"version"];
        [dictParameter setObject:lang forKey:@"language"];
        
        //NSLog(@"DicParam...%@",dictParam);
        
        [[WebserviceManager sharedInstance] Versionupdate:dictParameter withCompletion:^(BOOL isSuccess, NSDictionary *responce)
         {
             if (isSuccess)
             {
                 if ([[responce valueForKey:@"response_status"] integerValue] == 1)
                 {
                     
                 }
                 else
                 {
                     isUpdateAvailable = true;
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:responce[@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
                     [alertView setTag:1777];
                     [alertView show];
                 }
             }
             else
             {
                 //DisplayAlertWithTitle(TRY_AGAIN_MSG, APP_NAME);
             }
         }];
    }else
    {
        //DisplayAlert(NET_MSG);
    }
    
}

-(BOOL) needsUpdate{
    if ([objShare isInternetConnected])
    {
        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appID = infoDictionary[@"CFBundleIdentifier"];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
        NSData* data = [NSData dataWithContentsOfURL:url];
        NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([lookup[@"resultCount"] integerValue] == 1){
            NSString* appStoreVersion = lookup[@"results"][0][@"version"];
            NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
            float intappStoreVersion = [NSString stringWithFormat:@"%@",appStoreVersion].floatValue;
            float intcurrentVersion = [NSString stringWithFormat:@"%@",currentVersion].floatValue;
            if (intcurrentVersion < intappStoreVersion){
                NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
                return YES;
            }
        }
    }
    return NO;
}

-(void)MethodUpdateDeviceTokenAPIcall
{
    if ([objShare isInternetConnected])
    {
        NSDictionary *dictParam = [[NSDictionary alloc]initWithObjectsAndKeys: [[NSUserDefaults standardUserDefaults] valueForKey:@"UserId"],@"userid",[[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"],@"token",[NSDate date] ,@"current_time",nil];
        
//        NSLog(@"UPDATE TOKEN DicParam...%@",dictParam);
        [[WebserviceManager sharedInstance] UpdateDeviceToken:dictParam withCompletion:^(BOOL isSuccess, NSDictionary *responce)
         {
             if (isSuccess)
             {
                 if ([[responce valueForKey:@"response_status"] integerValue] == 1)
                 {
//                     NSLog(@"RESPONSE FOR UPDATE TOKEN - %@",responce);
                     [[NSUserDefaults standardUserDefaults] setValue:[responce valueForKey:@"sitter"] forKey:@"carSitter"];
                 }
                 else
                 {
                     //DisplayAlertWithTitle(responce[@"message"], APP_NAME);
                 }
             }
             else
             {
                 //DisplayAlertWithTitle(TRY_AGAIN_MSG, APP_NAME);
             }
         }];
    }else
    {
        DisplayAlert(NET_MSG);
    }
}

-(void)MethodSetServerLanguageAPIcall
{
    if ([objShare isInternetConnected])
    {
        NSString *lang;
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"AppLanguage" ]  isEqualToString:@"nl"])
        {
            lang = @"dutch";
        }
        else
        {
            lang = @"english";
            
        }
        
        NSDictionary *dictParam = [[NSDictionary alloc]initWithObjectsAndKeys: [[NSUserDefaults standardUserDefaults] valueForKey:@"UserId"],@"user_id",lang,@"language", nil];
        
        //NSLog(@"DicParam...%@",dictParam);
        
        [[WebserviceManager sharedInstance] SetServerLanguageAPI:dictParam withCompletion:^(BOOL isSuccess, NSDictionary *responce)
         {
             if (isSuccess)
             {
                 if ([[responce valueForKey:@"response_status"] integerValue] == 1)
                 {
                     //suucess
//                     NSLog(@"ServerLanguage set From AppDelegate");
                 }
                 else
                 {
                     DisplayAlertWithTitle(responce[@"message"], APP_NAME);
                 }
             }
             else
             {
                 //DisplayAlertWithTitle(TRY_AGAIN_MSG, APP_NAME);
             }
         }];
    }else
        DisplayAlert(NET_MSG);
}


-(void)CheckInternetConnecivity
{
    [self hidePopup];
    
    if (![objShare isInternetConnected])
    {
        self.lblPopup = nil;
        [self showPopup:NET_MSG];
    }
}


//- (void)reachabilityChanged:(NSNotification *)notification
//{
//    if ([notification.object isKindOfClass:Reachability.class])
//    {
//        [self logReachabilityStatus];
//    }
//}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if (reach == self.internetReachable)
    {
        if([reach isReachable])
        {
            NSString * temp = [NSString stringWithFormat:@"InternetConnection Notification Says Reachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
            if (![self.mainSocket isConnected])
            {
                [self socketConnect];
            }
            else
            {
                [self.mainSocket readDataWithTimeout:-1 tag:0];
            }

        }
        else
        {
            NSString * temp = [NSString stringWithFormat:@"InternetConnection Notification Says Unreachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
        }
    }
    
}

//- (void)logReachabilityStatus
//{
//    NSString *hostStatus = self.hostReachable.currentReachabilityStatus ? @"up" : @"down";
//    NSString *internetStatus = self.internetReachable.currentReachabilityStatus ? @"up" : @"down";
//    
//    if ([hostStatus isEqualToString:@"down"])
//    {
//        [self showPopup:NET_MSG];
//    }
//    else if ([hostStatus isEqualToString:@"up"])
//    {
//        [self hidePopup];
//        
//        if ([self.mainSocket isDisconnected])
//        {
//            [self socketConnect];
//        }
//    }
//    
//    if ([internetStatus isEqualToString:@"down"])
//    {
//        [self showPopup:NET_MSG];
//    }
//    else if ([internetStatus isEqualToString:@"up"])
//    {
//        if (![self.mainSocket isConnected])
//        {
//            [self socketConnect];
//        }
//        else
//        {
//            [self.mainSocket readDataWithTimeout:-1 tag:0];
//        }
//        
//        [self.lblPopup removeFromSuperview];
//        [self hidePopup];
//    }
//}


- (void)showPopup:(NSString *)strMessage
{
    UIWindow* appWin = self.window;
    
    if (self.lblPopup == nil)
    {
        self.lblPopup = [[UILabel alloc]initWithFrame:CGRectMake(0, appWin.frame.size.height-50, appWin.frame.size.width, 50)];
        self.lblPopup.backgroundColor = [UIColor lightGrayColor] ;
        self.lblPopup.textColor = [UIColor whiteColor];
        self.lblPopup.textAlignment=NSTextAlignmentCenter;
        self.lblPopup.text = [NSString stringWithFormat:@"  %@", strMessage];
        [appWin addSubview:self.lblPopup];
    }
}

- (void)hidePopup
{
    if (self.lblPopup!= nil)
    {
        [self.lblPopup removeFromSuperview];
        self.lblPopup = nil;
    }
}

#pragma mark - Socket Connections and Delegate
- (void) socketConnect
{
    if (![objShare isInternetConnected])
    {
        return;
    }
    
    NSString *userid = UDUserId;
    
    if ([userid isEqualToString:@""] || userid == nil || [userid isEqualToString:@"(null)"])
    {
        return;
    }
    
    if (![self.mainSocket isConnected])
    {
        self.mainSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        @try
        {
            //NSLog(@"Host : %@ Port : %@",[APP_CONFIG objectForKey:HOST],[APP_CONFIG objectForKey:PORT]);
            
            NSError *error;
            
            [self.mainSocket connectToHost:self.strIPAddress onPort:self.portNum error:&error];
            
            if (socketTimer == nil)
            {
                socketTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(pingToServer) userInfo:nil repeats:true];
            }
        }
        @catch (NSException *exception)
        {
            [self socketConnect];
        }
    }
}

-(void)pingToServer
{
    if ([self.mainSocket isConnected])
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setValue:@"hi" forKey:@"request_type"];
        
        NSString *strJson = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        strJson = [strJson stringByAppendingString:@"\n"];
        
        NSData *dtSend = [strJson dataUsingEncoding:NSUTF8StringEncoding];
        
        if (dtSend != nil)
        {
            [self.mainSocket writeData:dtSend withTimeout:-1 tag:0];
        }
    }
}

- (void)sendRequest
{
    if ([self.mainSocket isConnected])
    {
        @try
        {
            NSString *userid = UDUserId;
            
            if ([userid isEqualToString:@""] || userid == nil || [userid isEqualToString:@"(null)"])
            {
                //dont send request to socket connect
            }
            else
            {
                //NSLog(@"Dictionary to Send : %@",self.dicSocketSend);
                
                NSError *error;
                NSData *dtJson = [NSJSONSerialization dataWithJSONObject:self.dicSocketSend options:NSJSONWritingPrettyPrinted error:&error];
                NSString *strJson = [[NSString alloc]initWithData:dtJson encoding:NSUTF8StringEncoding];
                strJson = [strJson stringByAppendingString:@"\n"];
                NSData *dtSend = [strJson dataUsingEncoding:NSUTF8StringEncoding];
                
              //  NSLog(@"Json String : %@",strJson);
                
                if (dtSend != nil)
                {
                    [self.mainSocket writeData:dtSend withTimeout:-1 tag:0];
                }
            }
        }
        @catch (NSException *exception)
        {
            
        }
    }
}

- (void)socketDisconnect
{
    [self disconnectUserToSocket];
    [self.mainSocket disconnect];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self.mainSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self.mainSocket performBlock:^{
        [self.mainSocket enableBackgroundingOnSocket];
    }];
    if(UDUserId)
    {
        [self connectUserToSocket];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    if (data != nil)
    {
        if (self.dicSocketReceive == nil)
            self.dicSocketReceive = [NSMutableDictionary dictionary];
        
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         //NSLog(@"Socket response jsonString: %@",jsonString);
        NSData *jsondata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        self.dicSocketReceive = [NSJSONSerialization JSONObjectWithData:jsondata options:0 error:nil];
        
        if (self.dicSocketReceive == nil)
        {
            if ([self.mainSocket isDisconnected])
            {
                [self socketConnect];
                if(UDUserId)
                {
                    [self connectUserToSocket];
                }
            }
        }
        [objShare hideLoading];
        
        NSLog(@"Socket responseNipa : %@",self.dicSocketReceive);

        if (![[self.dicSocketReceive valueForKey:@"request_type"]isEqualToString:@"driverlatlong"])
        {
            NSLog(@"Socket response : %@",self.dicSocketReceive);
        }
        if ([[self.dicSocketReceive valueForKey:@"request_type"]isEqualToString:@"acceptrequest"])
        {
            NSLog(@"MANTHAN RECEIEVED NEW REQ = %@",self.dicSocketReceive);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"acceptrequest" object:nil userInfo:self.dicSocketReceive];
        }
        if ([[self.dicSocketReceive valueForKey:@"request_type"]isEqualToString:@"driverarrivednotify"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"driverarrivednotify" object:nil userInfo:self.dicSocketReceive];
        }
        if ([[self.dicSocketReceive valueForKey:@"request_type"]isEqualToString:@"rejectrequest"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"rejectrequest" object:nil userInfo:self.dicSocketReceive];
        }
        if ([[self.dicSocketReceive valueForKey:@"request_type"]isEqualToString:@"arrived"])
        {
             NSLog(@"MANTHAN arrived RECEIEVED NEW REQ = %@",self.dicSocketReceive);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"arrived" object:nil userInfo:self.dicSocketReceive];
        }
        if ([[self.dicSocketReceive valueForKey:@"request_type"]isEqualToString:@"starttrip"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"starttrip" object:nil userInfo:self.dicSocketReceive];
        }
        if ([[self.dicSocketReceive valueForKey:@"request_type"]isEqualToString:@"endtrip"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"endtrip" object:nil userInfo:self.dicSocketReceive];
        }
        if ([[self.dicSocketReceive valueForKey:@"request_type"]isEqualToString:@"livemeter"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"livemeter" object:nil userInfo:self.dicSocketReceive];
        }
        
        strMsg = [self.dicSocketReceive objectForKey:@"message"];
        if ([[self.dicSocketReceive valueForKey:@"pushtype"]isEqualToString:@"sentrequest"])
        {
            if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
            {
                [self scheduleLocalNotification:self.dicSocketReceive];
            }
            else{
                [self GotoAcceptRejectScreen:self.dicSocketReceive];
            }
        }
        if ([[self.dicSocketReceive valueForKey:@"pushtype"]isEqualToString:@"usercancelrequest"])
        {
            if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
            {
                [self scheduleLocalNotification:self.dicSocketReceive];
            }
            else{
                UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                             message:strMsg
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"Ok"
                                                                   otherButtonTitles:nil, nil];
                [alert_notification show];
                [self usercancelrequest:self.dicSocketReceive];
            }
        }
    }
    
    [self.mainSocket readDataWithTimeout:-1 tag:0];
}

-(void)scheduleLocalNotification:(NSDictionary * )localDicSocketReceive
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
    notification.alertBody = [localDicSocketReceive valueForKey:@"message"];
    if(localDicSocketReceive != nil)
    {
        notification.userInfo = localDicSocketReceive;
    }
    if ([[self.dicSocketReceive valueForKey:@"pushtype"]isEqualToString:@"sentrequest"])
    {
        notification.soundName = @"Sound-1.mp3";//UILocalNotificationDefaultSoundName;
    }
    else
    {
        notification.soundName = UILocalNotificationDefaultSoundName;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    strMsg = [notification.userInfo objectForKey:@"message"];
    NSLog(@"%@",strMsg);
    if ([[notification.userInfo valueForKey:@"pushtype"]isEqualToString:@"sentrequest"])
    {
        [self GotoAcceptRejectScreen:notification.userInfo];
    }
    if ([[notification.userInfo valueForKey:@"pushtype"]isEqualToString:@"usercancelrequest"])
    {
        [self usercancelrequest:notification.userInfo];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

-(void)usercancelrequest:(NSDictionary *)localdicSocketReceive
{
    if([[localdicSocketReceive valueForKey:@"is_future"]isEqualToString:@"1"])
    {
        TripType = @"future";
    }
    else
    {
        TripType = @"current";
    }
    Ptype = @"usercancelrequest";
    [SharedClass objSharedClass].selectSettingsOption(0);
}

-(void)GotoAcceptRejectScreen:(NSDictionary *)localdicSocketReceive
{
    [[NSUserDefaults standardUserDefaults]setObject:localdicSocketReceive forKey:@"checkNotification"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:[localdicSocketReceive valueForKey:@"userid"] forKey:@"CustomerId"];
    [[NSUserDefaults standardUserDefaults] setObject:[localdicSocketReceive valueForKey:@"request_id"] forKey:@"RequestId"];
    [[NSUserDefaults standardUserDefaults] setObject:[localdicSocketReceive valueForKey:@"car_id"] forKey:@"CarId"];

    if ([objShare isInternetConnected]) {
        [[WebserviceManager sharedInstance] GetUTCTimeAPI:nil withCompletion:^(BOOL isSuccess, NSDictionary *responce) {
            if (isSuccess)
            {
                if ([[responce valueForKey:@"response_status"] integerValue] == 1)
                {
                    strMsg = [localdicSocketReceive objectForKey:@"message"];
                    NSString *strDate = [strMsg substringFromIndex: [strMsg length] - 19];
                    NSDate *dateServer = [self StringFromDate:strDate];
                    
                    NSString *strUTC = [responce valueForKey:@"server_utc_time"];
                    NSString *strdateTodayServer = [strUTC substringToIndex:19];
                    NSDate *dateTodayServer = [self StringFromDate:strdateTodayServer];
                    
                    NSTimeInterval distanceBetweenDates = [dateTodayServer timeIntervalSinceDate:dateServer];
                    NSLog(@"%f",distanceBetweenDates);
                    if(distanceBetweenDates >= 0 && distanceBetweenDates < 15)
                    {
                        _timeLoader= 15-distanceBetweenDates;
                    }
                    else
                    {
                        _timeLoader = 0;
                        
                        NSLog(@"%f",distanceBetweenDates);
                        
                        NSString *alertMsg = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_miss_accept_request", @"Localizable", [AppDel bundle], nil)];
                        
                        UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                                                     message:alertMsg
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"Ok"
                                                                           otherButtonTitles:nil, nil];
                        [alert_notification show];
                        
                    }
                    int timer = (int)_timeLoader;
                    NSLog(@"%d",timer);
                    if(timer > 0 && timer <= 15)
                    {
                        UIViewController  *vc = [self visibleViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
                        if ([vc isKindOfClass:[SliderContainerVC class]]){
                            
                            SliderContainerVC  *vc1 = (SliderContainerVC *)vc;
                            if([vc1.destinationViewController isKindOfClass:[UINavigationController class]]){
                                UINavigationController  *nav = (UINavigationController *)vc1.destinationViewController;
                                UIViewController  *vc2 = (UIViewController *)nav.viewControllers.lastObject;
                                if ([vc2 isKindOfClass:[ConfirmRequestVC class]]){
                                    
                                }else{
                                    [SharedClass objSharedClass].selectSettingsOption(1);
                                }
                                
                            }else{
                                [SharedClass objSharedClass].selectSettingsOption(1);
                            }
                        }
                        else{
                            if([vc isKindOfClass:[UIAlertController class]]){
                                
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    //Background Thread
                                    [vc dismissViewControllerAnimated:YES completion:nil];
                                    vc.view.userInteractionEnabled = true;
                                    dispatch_async(dispatch_get_main_queue(), ^(void){
                                        //Run UI Updates
                                        [SharedClass objSharedClass].selectSettingsOption(1);
                                    });
                                });
                            }
                            else{
                                [SharedClass objSharedClass].selectSettingsOption(1);
                            }
                        }
                    }
                    else{
                        
                    }

                }
                else
                {
                  
                }
            }
        }];

    }
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if ([err description] != nil)
    {
        if ([self.mainSocket isDisconnected])
        {
            [socketTimer invalidate];
            socketTimer = nil;
            [self socketConnect];
        }
    }
}

-(void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    [socketTimer invalidate];
    socketTimer = nil;

    [self socketConnect];
    [self.mainSocket readDataWithTimeout:-1 tag:0];
}

-(void)connectUserToSocket
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:@"connect" forKey:@"request_type"];
    [dict setValue:UDUserId forKey:@"userid"];
    
    NSString *strJson = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    //strJson = [strJson stringByAppendingString:@"\n"];
    
    NSData *dtSend = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    
    if (dtSend != nil)
    {
        [AppDel.mainSocket writeData:dtSend withTimeout:-1 tag:0];
    }
}

-(void)disconnectUserToSocket
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:@"disconnect" forKey:@"request_type"];
    [dict setValue:UDUserId forKey:@"userid"];
    
    NSString *strJson = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSData *dtSend = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    
    if (dtSend != nil)
    {
        [AppDel.mainSocket writeData:dtSend withTimeout:-1 tag:0];
    }
}


@end
