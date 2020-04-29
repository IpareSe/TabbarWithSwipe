#import <Foundation/Foundation.h>
#import "NetConnection.h"
#import "KWLoadingView.h"
#import <CoreLocation/CoreLocation.h>
#import "AppConstant.h"
#import "BackgroundTaskManager.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface SharedClass : NSObject<CLLocationManagerDelegate>
{
    
}
//05/06/2017 Nipa
@property (nonatomic)BOOL isCurrentTripOn;

@property (nonatomic, strong) NSString *UserID;
@property (nonatomic,strong) KWLoadingView *loadingView;
@property (nonatomic)CLLocationCoordinate2D coordinate;
@property (nonatomic,copy)CLLocationManager *locationManager;
@property (nonatomic)BOOL isFromTwitter;
@property (nonatomic)BOOL isFromNotification,isBackgroundNotif, isFromNotificationSchedule,isFromNotificationForNotAcceptAnyOne;
@property (strong, nonatomic) NSTimer *timerupdateUserlatLong;
@property (strong, nonatomic)NSMutableArray     *arrLatLong;
@property (assign, nonatomic)float applongitude;
@property (assign, nonatomic)float applatitude;
@property (assign, nonatomic)float appangle;
@property (strong, nonatomic)NSMutableArray  *arrNewLatlong;
@property (readwrite)BOOL isStartTime;

@property (nonatomic) NSTimer *timerNew;
@property (nonatomic) NSTimer * delay10Seconds;
@property (nonatomic) BackgroundTaskManager * bgTask;

@property (nonatomic, assign) BOOL isOutSideHagArea;


+(SharedClass *)objSharedClass;
@property (nonatomic,copy) void (^selectSettingsOption)(NSInteger index);

-(NSString *)isAppRunningOniPhone5:(NSString *)strNib;
-(UIColor*)colorWithHexString:(NSString*)hex;

-(BOOL)isNetworkReachable;

-(void)showLoadingWithText:(NSString*)loadingText;
-(void)setupLoadingIndicator:(NSString*)loadingText didError:(BOOL)error;
-(void)hideLoading;
-(void)quickHide;
-(void)callWebservice:(NSString *)strUrl inputParameters:(NSMutableDictionary *)dictParameter completion:(void(^)(id response))completion;
-(void)callGetWebService:(NSString *)strUrl inputParameters:(NSMutableDictionary *)dictParameter completion:(void(^)(id response))completion;

-(float)lblDescriptionHeight:(NSString *)strDesc;
-(UIView *)setTagInView:(NSString *)strTags;
- (BOOL)isInternetConnected;
-(BOOL)isValidEmailAddress:(NSString *)checkString;


-(void)locationUpdateMethod;
-(void)latLongUpdateToServerMethod;
-(void)startLocationTracking;


@end

