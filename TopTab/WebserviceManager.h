//
//  WebserviceManager.h
//  Vidicons
//
//  Created by SOTSYS157 on 05/02/15.
//  Copyright (c) 2015 Space-O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>


@interface WebserviceManager : NSObject

//@property (nonatomic,strong) NSString *strApiVersion;
//@property (nonatomic,strong) NSString *strApiKey;
//

+(WebserviceManager*)sharedInstance;

//-(void)LoginAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)SignUpAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)ForgotPasswordAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)ViewProfileAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)EditProfileAPI:(NSDictionary *)dictData withImageData:(NSData *)imageData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)NewBookingAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)TimeDistanceAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)MaxFareAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)BookingRequestAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)EditProfileAPIWithouImage:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)PriceListAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
;
//-(void)ContactUsAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
//-(void)ChangePasswordAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)HistoryAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)HistoryDetailAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)ChangePasswordAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)SetServerLanguageAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)NotificationCountAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)DriverScheduleAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)StaticAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)GetUTCTimeAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)AccountingAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)addImageAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)DeleteImageAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)PaymentHistoryAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)PointPriceListAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)AddPointsAfterPurchase:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)UpdateDeviceToken:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)logoutAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;

-(void)EditProfileAPI:(NSDictionary *)dictData withImageData:(NSData *)imageData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;



-(void)addImageAPI:(NSDictionary *)dictData withArrImageData:(NSMutableArray *)arrimageData withtype:(NSString *)type withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;


-(void)DeleteNotificationAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;
-(void)EnableDisableNotificationAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;

-(void)ContactUsAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;

-(void)GetMeterPriceAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;

-(void)Versionupdate:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;

-(void)getdriverridestatusAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion;

@end

