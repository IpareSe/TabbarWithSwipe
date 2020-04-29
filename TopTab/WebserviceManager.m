
#import "WebserviceManager.h"
#import <AFNetworking/AFNetworking.h>
#import "AppConstant.h"
#import "AppDelegate.h"
#import "NSDictionary+RemoveNull.h"


@implementation WebserviceManager

+(WebserviceManager*)sharedInstance
{
    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedObject = [[WebserviceManager alloc] init];
    });
    return _sharedObject;
}

-(void)DeleteNotificationAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"deletenotification") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];

}

-(void)EnableDisableNotificationAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"notificationonoff") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
-(void)PriceListAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"pricelist") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
}
-(void)HistoryAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"history") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];

}
-(void)HistoryDetailAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"driverhistorydetail") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
-(void)ChangePasswordAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"changepassword") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
-(void)SetServerLanguageAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"languageset") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
}
-(void)GetMeterPriceAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"livemeter") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}

-(void)ContactUsAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"contactus") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
}

-(void)NotificationCountAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"notificationcount") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
}

-(void)logoutAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion{
    
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"logout") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if(isSuceess){
            completion(YES,response);
        }else{
            completion(NO,nil);
        }
    }];
}

-(void)DriverScheduleAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"myschedule") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
}
-(void)StaticAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"staticpages") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}

-(void)GetUTCTimeAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"getutctime") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}

-(void)AccountingAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"accountingdriver") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
-(void)PaymentHistoryAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"paymenthistory") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
-(void)PointPriceListAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"creditpricelist") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
-(void)AddPointsAfterPurchase:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"addcreditpayment") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
-(void)UpdateDeviceToken:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"tokenupdate") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}


-(void)DeleteImageAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"deleteimages") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}


-(void)EditProfileAPIWithouImage:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"editprofile") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
}


-(void)EditProfileAPI:(NSDictionary *)dictData withImageData:(NSData *)imageData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL_WithImagePost:WEB_URL(@"editprofile") withParam:dictData withImageData:imageData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}



-(void)Versionupdate:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"versionupdate") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
-(void)addImageAPI:(NSDictionary *)dictData withArrImageData:(NSMutableArray *)arrimageData withtype:(NSString *)type withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL_WithImagePostForAddImage:WEB_URL(@"addimages") withParam:dictData withArrImageData:arrimageData withtype:type withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}




+(void)postMethodWebserviceWithURL_WithImagePostForAddImage:(NSString*)strUrl withParam:(NSDictionary*)dictParam withArrImageData:(NSMutableArray *)arrimageData withtype:(NSString*)type withCompletion:(void(^)(BOOL isSuceess,NSDictionary*response))completion
{
    NSLog(@"Request: %@", strUrl);
    NSLog(@"Param: %@", dictParam);
    //[MySharedObj ShowLoading];
    NSDate *date = [NSDate new];
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    [dateformatter setDateFormat:@"yyyyMMdd"];
    NSString *strName = [dateformatter stringFromDate:date];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager POST:strUrl parameters:dictParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[arrimageData objectAtIndex:0] name:type fileName:[NSString stringWithFormat:@"%@.jpg",strName] mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        //  [MySharedObj hideLoading];
        completion(YES,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //   [MySharedObj hideLoading];
        completion(NO,nil);
        
    }];
    [op start];
    
}



+(void)postMethodWebserviceWithURL:(NSString*)strUrl withParam:(NSDictionary*)dictParam withCompletion:(void(^)(BOOL isSuceess,NSDictionary*response))completion
{
    //[MySharedObj showLoadingWithText:@"Loading"];
    NSLog(@"Request: %@", strUrl);
    NSLog(@"Param: %@", dictParam);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:strUrl parameters:dictParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //[objShare hideLoading];
        NSLog(@"Response: %@", responseObject);
        completion(YES,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //[objShare hideLoading];
        completion(NO,nil);
        
    }];
}

+(void)postMethodWebserviceWithURL_WithImagePost:(NSString*)strUrl withParam:(NSDictionary*)dictParam withImageData:(NSData *)imageData withCompletion:(void(^)(BOOL isSuceess,NSDictionary*response))completion
{
    NSLog(@"Request: %@", strUrl);
    NSLog(@"Param: %@", dictParam);
    //[MySharedObj ShowLoading];
    NSDate *date = [NSDate new];
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    [dateformatter setDateFormat:@"yyyyMMdd"];
    NSString *strName = [dateformatter stringFromDate:date];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager POST:strUrl parameters:dictParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"profilepic" fileName:[NSString stringWithFormat:@"%@.jpg",strName] mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
      //  [MySharedObj hideLoading];
        completion(YES,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
     //   [MySharedObj hideLoading];
        completion(NO,nil);
    }];
    [op start];
    
}


+(void)getMethodWebserviceWithURL:(NSString*)strUrl withParam:(NSDictionary*)dictParam withCompletion:(void(^)(BOOL isSuceess,NSArray *response))completion
{
    NSLog(@"Request: %@", strUrl);
    NSLog(@"Param: %@", dictParam);
  //  [MySharedObj ShowLoading];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.responseSerializer = responseSerializer;
    [manager GET:strUrl parameters:dictParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
      //  [MySharedObj hideLoading];
        NSLog(@"Response: %@", responseObject);
        completion(YES,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"GetMethod error : %@",error);
      //  [MySharedObj hideLoading];
        completion(NO,nil);
    }];
}
//-(void)LoginAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"login") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//
//-(void)SignUpAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"usersignup") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//-(void)ForgotPasswordAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"forgotpassword") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//
//-(void)ViewProfileAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"viewprofile") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//-(void)EditProfileAPI:(NSDictionary *)dictData withImageData:(NSData *)imageData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL_WithImagePost:WEB_URL(@"editprofile") withParam:dictData withImageData:imageData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)NewBookingAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"newbooking") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//-(void)TimeDistanceAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:@"https://maps.googleapis.com/maps/api/directions/json" withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//-(void)BookingRequestAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"bookingrequest") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//
//-(void)MaxFareAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"getmaxfare") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//

//
//-(void)ContactUsAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"contactus") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//}
//-(void)ChangePasswordAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"changepassword") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}

//
//-(void)RateAndReviewAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"rateandreview") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//
//-(void)ReviewDetailAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"reviewdetail") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)DeleteHistoryAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"deletehistory") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)EstimateAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"estimation") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)GetAllDriverAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"getalldriver") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)CancelTripAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"usercancel") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)NotificationAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"notification") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)DriverForUserTripAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"drivertouser") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)SetServerLanguageAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"languageset") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)InvoiceAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"invoice") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}
//-(void)NotificationCountAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
//{
//    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"notificationcount") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
//        if (isSuceess) {
//            completion(YES,response);
//        }else
//            completion(NO,nil);
//    }];
//
//}

-(void)getdriverridestatusAPI:(NSDictionary *)dictData withCompletion:(void(^)(BOOL isSuccess, NSDictionary* strMessresponceage))completion
{
    [WebserviceManager postMethodWebserviceWithURL:WEB_URL(@"getridestatus") withParam:dictData withCompletion:^(BOOL isSuceess, NSDictionary *response) {
        if (isSuceess) {
            completion(YES,response);
        }else
            completion(NO,nil);
    }];
    
}
@end

