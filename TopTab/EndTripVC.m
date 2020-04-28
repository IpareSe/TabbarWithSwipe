//
//  EndTripVC.m
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
// 8401606973

#import "EndTripVC.h"
#import "FareSummaryVC.h"
#import "AppConstant.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SharedClass.h"
#import <AFNetworking.h>
#import "ManualFareVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ArrivingUserInfoCell.h"
#import "ArrivinglocationCell.h"
#import "WebserviceManager.h"
#import "NSDictionary+RemoveNull.h"
#import "UserInfoCell.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)



@interface EndTripVC ()<CLLocationManagerDelegate,GMSMapViewDelegate>
{
    NSTimer* m_timer;
    UIButton *button;
    IBOutlet GMSMapView *mapView_;
    CLLocationManager * locationmanager;
    NSNumber *latitude;
    NSNumber *longitude;
    //NSNumber *ASIHTTPRequest.h;
    GMSMarker *marker;
    NSArray *routes;
    NSDate *dateToday;
    CLLocationCoordinate2D point,latlonsource,latlondestina;
    NSString *strPicklat,*strPicklon,*strDestlat,*strDestlon,*strTotalHoldTime,*strCurrLoc,*strDropoffAddress;
    NSDictionary  *dictResponse;
    IBOutlet NSLayoutConstraint *constantHeightTbl;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITableView *tblEndtrip;

    IBOutlet UIButton *btnManual;
    IBOutlet UIButton *btnAutomatic;
    IBOutlet UIView *viewAlert;
    IBOutlet UILabel *lblcallStatText;
    
    IBOutlet UIView *viewTrip;
    IBOutlet UITextField *textTripAmount;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UILabel *lblTripAmount;
    int dataCount;
    NSTimer  *timermeter;
    NSMutableArray  *arrDriverMeter;
    float  caldistance;
    float  distanceType;
    int increCount;
    NSTimer  *secondTimerMeter;
    int timeCalCount;
    int endtripAPITag;
}
@end

@implementation EndTripVC
@synthesize isHoldBtn,strPicklat,strPicklon,strPassenger,isDesAddress,strCarType,resminutes,resduration,reskillometers,strMaxPriceN,strMeterPriceN,isKillAPI;

- (void)viewDidLoad {
    [super viewDidLoad];
    strTotalHoldTime=@"0";
    objShare.isStartTime = YES;
    caldistance = 0;
    arrDriverMeter = [[NSMutableArray alloc]init];
    dataCount = 1;
    distanceType = 0;
    increCount = 1;
    
    [self setLanguage];
    [self callWebServiceforArrivingRequest];
    // Do any additional setup after loading the view.
    
    
}

-(void)setLanguage
{
    lblcallStatText.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_Prize_caluculationType",@"Localizable", [AppDel bundle], nil)];

    [_btnTrip setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_endtrip", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    
    if(isHoldBtn){
        
        _btnHold.tag=1;
        [_btnHold setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_Start_again", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
        
    }else{
        _btnHold.tag=0;
        [_btnHold setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_holdtrip", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];

    }
    
    self.lblTitle.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_tripStartedHeader", @"Localizable", [AppDel bundle], nil)];
    
    lblStatMeter.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_meterpricescreen", @"Localizable", [AppDel bundle], nil)];
    lblStatTime.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_timescreen", @"Localizable", [AppDel bundle], nil)];
    lblStatDistance.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_distancescreen", @"Localizable", [AppDel bundle], nil)];
    lblStatMax.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_maxtarrif", @"Localizable", [AppDel bundle], nil)];


    
    [btnAutomatic setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_automatic", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [btnManual setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_manual", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    
    textTripAmount.placeholder = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_Enter_Amount_placeholder", @"Localizable", [AppDel bundle], nil)];
    lblTripAmount.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_trip_amount",@"Localizable", [AppDel bundle], nil)];
    [btnSubmit setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_submit",@"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    
    
    
}
-(void)killAppMeterCalculation{

    NSTimeInterval myDateTimeInterval = [[NSUserDefaults standardUserDefaults] floatForKey:@"lastTimeInterval"];
//    NSLog(@"oldTimeInterval:%f",myDateTimeInterval);
    
    NSDate *myDate2 = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"myDateKey"];
    
    NSTimeInterval time = ([[NSDate new] timeIntervalSince1970]);
//    NSLog(@"currentTime:%f",time);
    
    NSTimeInterval distanceBetweenDates = [[NSDate date] timeIntervalSinceDate:myDate2];

    float oldtime = [[NSUserDefaults standardUserDefaults] doubleForKey:@"calTime"];
//    NSLog(@"oldtime:%f",oldtime);

    NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:time] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:myDateTimeInterval]];
//    NSLog(@"difference time Interval:%f",difference);
    NSInteger newTi = (NSInteger)distanceBetweenDates;
    NSInteger newseconds = newTi % 60;

    float seconds1 = resduration * 60;
    timeCalCount = oldtime + newseconds;
    lblValTime.text = [self timeFormatted:timeCalCount];

    
    lblValDistance.text = [NSString stringWithFormat:@"%.1f km", reskillometers];
    if(strMeterPriceN != nil){
        lblValMeter.text = [NSString stringWithFormat:@"€%@",strMeterPriceN];
    }
    if(strMaxPriceN != nil){
        lblValMax.text = [NSString stringWithFormat:@"%@",strMaxPriceN];;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(livemeterObserver:) name:@"livemeter" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endTripObserver:) name:@"endtrip" object:nil];
    
    [super viewWillAppear:YES];
    
    //06/02/2018
    [objShare locationUpdateMethod];
    if(isKillAPI){
        [self killAppMeterCalculation];
    }
    [self meterApiCall]; //18/10/2016
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)endTripObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self endTripRequestResponse:requestInfo];
}

- (void)livemeterObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self livemeterRequestResponse:requestInfo];
}

-(void)livemeterRequestResponse:(NSDictionary *)responce
{
    if ([[responce valueForKey:@"response_status"] integerValue] == 1)
    {
        NSDictionary *resDict = [responce dictionaryRemoveNullValue:[[responce valueForKey:@"data"] objectAtIndex:0]];
        
        float distanceVal = [[resDict valueForKey:@"distance"]doubleValue];
        
        lblValMeter.text = [NSString stringWithFormat:@"€%.02f",[[resDict valueForKey:@"total_meter_price"] doubleValue]];
        lblValMax.text = [NSString stringWithFormat:@"%.02f",[[resDict valueForKey:@"max_fare_price"]doubleValue]];
        //                        NSLog(@"distanceVal:%f",distanceVal);
        lblValDistance.text = [NSString stringWithFormat:@"%.1f km",[[resDict valueForKey:@"distance"]doubleValue]];
    }
    else
    {
    }
}

-(void)endTripRequestResponse:(NSDictionary *)responseObject
{
//    NSLog(@"%@",responseObject);
    if([[responseObject objectForKey:@"response_status"] integerValue]==1)
    {
        [objShare hideLoading];
        [timermeter invalidate];
        timermeter = nil;
        objShare.isStartTime = NO;
        if(endtripAPITag == 1)
        {
            [secondTimerMeter invalidate];
            secondTimerMeter = nil;
        }
        else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"coordinates_start"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"RequestId"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //05/06/2017 Nipa
        [SharedClass objSharedClass].isCurrentTripOn = false;
        
        FareSummaryVC *rvc = (FareSummaryVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"FareSummaryVC"];
        rvc.dictFareSummary=[responseObject mutableCopy];
        [self.navigationController pushViewController:rvc animated:YES];
    }
    else{
        [objShare hideLoading];
        DisplayAlertWithTitle(responseObject[@"message"], APP_NAME)
    }
    
}
#pragma mark Meter Calculation Method
-(void)meterApiCall{
    [self liveMeterAPICall];
    timermeter = [
                  NSTimer scheduledTimerWithTimeInterval:10.0f
                  target:self
                  selector:@selector(liveMeterAPICall)
                  userInfo:nil
                  repeats:YES
                  ];
    
    secondTimerMeter = [
                        NSTimer scheduledTimerWithTimeInterval:1.0f
                        target:self
                        selector:@selector(timeCalculationMethod)
                        userInfo:nil
                        repeats:YES
                        ];

}

-(void)timeCalculationMethod{
    timeCalCount = timeCalCount + 1;

    dispatch_async(dispatch_get_main_queue(), ^{
        lblValTime.text = [self timeFormatted:timeCalCount];
        NSTimeInterval time = ([[NSDate new] timeIntervalSince1970]);
//        NSLog(@"lastTime:%f",time);
        NSDate *myDate = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:myDate forKey:@"myDateKey"];
        [[NSUserDefaults standardUserDefaults]setDouble:time forKey:@"lastTimeInterval"];
        [[NSUserDefaults standardUserDefaults]setDouble:timeCalCount forKey:@"calTime"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    });
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

-(CLLocation*) cLLocationFromString:(NSString*)string
{
    NSArray *coordinates = [string componentsSeparatedByString:@","];
    CGFloat latitude1  = [[coordinates objectAtIndex:0] doubleValue];
    CGFloat longitude1 = [[coordinates objectAtIndex:1] doubleValue];
    return [[CLLocation alloc]  initWithLatitude:latitude1 longitude:longitude1];
}

-(void)liveMeterAPICall{
    
    NSLog(@"Destionation latlong:%@ %@", strDestlat, strDestlon);

    CLLocationDistance totalKilometers = reskillometers;
    
    if (objShare.arrNewLatlong.count > 1) {
        for (int i = 0; i < objShare.arrNewLatlong.count; i++) // <-- count - 1
        {
            if(i+1<objShare.arrNewLatlong.count){
                
                NSString *str = [NSString stringWithFormat:@"%@,%@",[[objShare.arrNewLatlong objectAtIndex:i]valueForKey:@"prevLat"],[[objShare.arrNewLatlong objectAtIndex:i]valueForKey:@"prevLong"]];
                
                NSString *str1 = [NSString stringWithFormat:@"%@,%@",[[objShare.arrNewLatlong objectAtIndex:i+1]valueForKey:@"prevLat"],[[objShare.arrNewLatlong objectAtIndex:i+1]valueForKey:@"prevLong"]];
                
                
//                NSString *str = @"52.072496,4.280216";
//                NSString *str1 = @"52.072496,4.280216";
                
//                NSString *str = [NSString stringWithFormat:@"%@,%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"MeterScreenCurrentLocationLat"],[[NSUserDefaults standardUserDefaults]valueForKey:@"MeterScreenCurrentLocationLon"]];
//                
//                NSString *str1 = [NSString stringWithFormat:@"%@,%@",strPicklat,strPicklon];
                
                
                
                CLLocation *loc1 = [self cLLocationFromString:str];
                CLLocation *loc2 = [self cLLocationFromString:str1];
                CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
                CLLocationDistance kilometers = distance / 1000.0;
                totalKilometers += kilometers;
                
//                NSLog(@"OldLocation = %@\n",str);
//                NSLog(@"New Location = %@\n",str1);
                //NSLog(@"Calculated Kilometers Inside Loop= %@\n",totalKilometers);
            }
            //NSLog(@"Calculated Total Kilometers= %@\n",totalKilometers);
        }
        
        float minutes = timeCalCount / 60.0;
        
        if ([objShare isInternetConnected])
        {
            NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
            [dictParameter setObject:strPicklat forKey:@"pick_lat"];
            [dictParameter setObject:strPicklon forKey:@"pick_lon"];
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"isOutSideHagArea"] != nil){
                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"isOutSideHagArea"] isEqualToString:@"true"]){
                    [dictParameter setObject:[NSString stringWithFormat:@"%@",strDestlat] forKey:@"dest_lat"];
                    [dictParameter setObject:[NSString stringWithFormat:@"%@",strDestlon] forKey:@"dest_lon"];
                }else{
                    [dictParameter setObject:[NSString stringWithFormat:@"%@",[[objShare.arrNewLatlong lastObject]valueForKey:@"prevLat"]] forKey:@"dest_lat"];
                    [dictParameter setObject:[NSString stringWithFormat:@"%@",[[objShare.arrNewLatlong lastObject]valueForKey:@"prevLong"]] forKey:@"dest_lon"];
                }
            }else{
                [dictParameter setObject:[NSString stringWithFormat:@"%@",[[objShare.arrNewLatlong lastObject]valueForKey:@"prevLat"]] forKey:@"dest_lat"];
                [dictParameter setObject:[NSString stringWithFormat:@"%@",[[objShare.arrNewLatlong lastObject]valueForKey:@"prevLong"]] forKey:@"dest_lon"];
            }
            
                   
//                [dictParameter setObject:@"52.072496" forKey:@"pick_lat"];
//                [dictParameter setObject:@"4.280216" forKey:@"pick_lon"];
//                [dictParameter setObject:@"52.072496" forKey:@"dest_lat"];
//                [dictParameter setObject:@"4.280216" forKey:@"dest_lon"];
            [dictParameter setObject:strPassenger forKey:@"passangers"];
            [dictParameter setObject:[NSString stringWithFormat:@"%.2f",totalKilometers] forKey:@"distance"];
            [dictParameter setObject:strCarType forKey:@"car_type"];
            [dictParameter setObject:[NSString stringWithFormat:@"%.2f",minutes] forKey:@"distance_time"];
            [dictParameter setObject:RequestId forKey:@"requestid"];
            if(strTotalHoldTime)
            {
                [dictParameter setObject:RequestId forKey:@"requestid"];
                [dictParameter setObject:strTotalHoldTime forKey:@"hold_time"];
            }
            
            if([AppDel.mainSocket isConnected])
            {
                [dictParameter setObject:@"livemeter" forKey:Socket_Request_Type];
                [dictParameter setObject:UDUserId forKey:Socket_Requester_Id];
                AppDel.dicSocketSend = [NSMutableDictionary new];
                AppDel.dicSocketSend = [dictParameter mutableCopy];
                [AppDel sendRequest];
                return;
            }
            
            [[WebserviceManager sharedInstance] GetMeterPriceAPI:dictParameter withCompletion:^(BOOL isSuccess, NSDictionary *responce) {
                if (isSuccess) {
                    [self livemeterRequestResponse:responce];
                    
                }
                else{
                }
            }];
        }
    }else{
    }
    return;
    
}

-(NSMutableDictionary *) MethodGetNearestDriverArrivingTimecall:(NSString *)str_dest str_origin:(NSString *)str_origin
{
    NSMutableDictionary *returnDictionary = [NSMutableDictionary new];
    NSString *sensor = @"sensor=false";
    NSString *parameters = [NSString stringWithFormat:@"%@&%@&%@",str_origin,str_dest,sensor];
    NSString *output =@"json";
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/%@?%@&mode=driving",output,parameters];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                  {
                      NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                      NSError* error;
                      NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                      if(!error)
                      {
                          if(![[json objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"])
                          {
                              if(![[json objectForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"])
                              {
                                  NSArray *arrroutes = [json objectForKey:@"routes"];
                                  NSDictionary *temp1 = [arrroutes objectAtIndex:0];
                                  NSArray *arrlegs = [temp1 objectForKey:@"legs"];
                                  NSDictionary *temp2 = [arrlegs objectAtIndex:0];
                                  NSString *duration = [[temp2 objectForKey:@"duration"] valueForKey:@"text"];
                                  NSString *distance = [[temp2 objectForKey:@"distance"] valueForKey:@"text"];
                                  [returnDictionary setObject:duration forKey:@"NDduration"];
                                  [returnDictionary setObject:distance forKey:@"NDdistance"];
                              }
                              
                          }
                      }
                      
                  });
    return returnDictionary;
}

-(void)displayMap
{
    locationmanager=[[CLLocationManager alloc]init];
    locationmanager.delegate=self;
    locationmanager.desiredAccuracy=kCLLocationAccuracyBest;
    
//    locationmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationmanager.allowsBackgroundLocationUpdates = YES;
    locationmanager.pausesLocationUpdatesAutomatically = NO;
    
    if(IS_OS_8_OR_LATER) {
        [locationmanager requestAlwaysAuthorization];
    }
    [locationmanager startUpdatingLocation];
    [locationmanager startMonitoringSignificantLocationChanges];
    NSDictionary *dict= [[NSUserDefaults standardUserDefaults]objectForKey:@"coordinates"];
    latitude=[dict objectForKey:@"lat"];
    longitude=[dict objectForKey:@"lon"];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[latitude floatValue]
                                                            longitude:[longitude floatValue]zoom:16];

    mapView_.camera = camera;
    mapView_.myLocationEnabled = YES;
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.delegate = self;
    
    [self.view bringSubviewToFront:button];
    [self.view bringSubviewToFront:_viewAddressInfo];

    //GET PATH
    _coordinates = [NSMutableArray new];
    _routeController = [LRouteController new];
    
}

-(float)getDistanceInKm:(CLLocationCoordinate2D )newLocation fromLocation:(CLLocationCoordinate2D )oldLocation
{
    float lat1,lon1,lat2,lon2;
    
    lat1 = newLocation.latitude  * M_PI / 180;
    lon1 = newLocation.longitude * M_PI / 180;
    
    lat2 = oldLocation.latitude  * M_PI / 180;
    lon2 = oldLocation.longitude * M_PI / 180;
    
    float R = 6371; // km
    float dLat = lat2-lat1;
    float dLon = lon2-lon1;
    float a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
    float c = 2 * atan2(sqrt(a), sqrt(1-a));
    float d = R * c;
//    NSLog(@"Kms-->%f",d);
    return d;
}

- (IBAction)manualTapGestureClicked:(UITapGestureRecognizer *)sender {
    viewTrip.hidden = true;
}

#pragma mark WebServices
-(void)CallWebserviceTripAmountForEndTrip
{
    endtripAPITag = 1;
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    
    strDestlat = [NSString stringWithFormat:@"%f",objShare.applatitude];
    strDestlon = [NSString stringWithFormat:@"%f",objShare.applongitude];
//    [self getAddressFromLatLon:objShare.applatitude withLongitude:objShare.applongitude];
    
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    if(CustomerId)
    {
        [dictParameter setObject:CustomerId forKey:@"userid"];
    }
    if(RequestId)
    {
        [dictParameter setObject:RequestId forKey:@"request_id"];
    }
    [dictParameter setObject:textTripAmount.text forKey:@"price"];
    [dictParameter setObject:@"1" forKey:@"is_manual"];
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
    
    [dictParameter setObject:strDestlat forKey:@"dest_lat"];
    [dictParameter setObject:strDestlon forKey:@"dest_lon"];
    
    if([AppDel.mainSocket isConnected])
    {
        [dictParameter setObject:@"endtrip" forKey:Socket_Request_Type];
        [dictParameter setObject:UDUserId forKey:Socket_Requester_Id];
        AppDel.dicSocketSend = [NSMutableDictionary new];
        AppDel.dicSocketSend = [dictParameter mutableCopy];
        [AppDel sendRequest];
        return;
    }
    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@endtrip",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endTripRequestResponse:responseObject];
     }
    
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [objShare hideLoading];
         DisplaySimpleAlert(TRY_AGAIN_MSG)
     }];

}



-(void)callWebServiceForHoldCar:(NSString *)holdTime Flag:(NSString *)HorR
{
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    [dictParameter setObject:HorR forKey:@"hold_status"];
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
    
    if(CustomerId) {
        [dictParameter setObject:CustomerId forKey:@"userid"];
    }
    if(RequestId){
        [dictParameter setObject:RequestId forKey:@"request_id"];
    }

    [dictParameter setObject:holdTime forKey:@"hold_time"];
    
    [objShare callWebservice:@"holdtime" inputParameters:dictParameter completion:^(id response)
     {
         strTotalHoldTime=[response valueForKey:@"total_hold_time"];
     }];
}
-(void)callWebserviceforDrawpath
{
    marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([strPicklat floatValue],[strPicklon floatValue]);
    marker.icon=[UIImage imageNamed:@"Drivercar_icon_4s.png"];
    marker.map = mapView_;
    
    _markerStart = [GMSMarker new];
   // _markerStart.position = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
    _markerStart.title = @"Start";
    _markerStart.icon=[UIImage imageNamed:@"user-pin.png"];
    
    _markerFinish = [GMSMarker new];
    _markerFinish.title = @"Finish";
    _markerFinish.icon=[UIImage imageNamed:@"user-pin.png"];
    
    [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[strPicklat floatValue] longitude:[strPicklon floatValue]]];
    [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[strDestlat floatValue] longitude:[strDestlon floatValue]]];
    [_routeController getPolylineWithLocations:_coordinates travelMode:TravelModeDriving andCompletitionBlock:^(GMSPolyline *polyline, NSError *error) {
        if (error)
        {
            NSLog(@"%@", error);
        }
        else if (!polyline)
        {
            NSLog(@"No route");
            [_coordinates removeAllObjects];
        }
        else
        {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([strPicklat floatValue],[strPicklon floatValue]);
            _markerStart.position = coord;
            _markerStart.map = mapView_;
            CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([strDestlat floatValue],[strDestlon floatValue]);
            _markerFinish.position = coord1;
            _markerFinish.map = mapView_;
            CLLocation *l1=[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
            CLLocation *l2=[[CLLocation alloc] initWithLatitude:28.6139 longitude:77.2090];
//            [self getDistanceInKm:l1 fromLocation:l2]; //Nipa
            float distance = [self getDistanceInKm:coord fromLocation:coord1];
//            NSLog(@"distance:%f",distance);
            
            
        }
    }];
}

-(void)callWebServiceforArrivingRequest
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
    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@arrivingscreen",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
     
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                              NSLog(@"%@",responseObject);
                                              [objShare hideLoading];

                                              NSDictionary *replacedDict =[responseObject dictionaryByReplacingNullsWithStrings];
//                                              NSLog(@"DicParam...%@",replacedDict);
                                              dictResponse = replacedDict;
                                              responseObject = replacedDict;
//
                                              
                                              if([[responseObject objectForKey:@"response_status"] integerValue]==1)
                                              {
                                                  _lblSource.text=[responseObject objectForKey:@"pickup_address"];
                                                  _lblDestination.text=[responseObject objectForKey:@"destination_address"];
                                                  _lblPhoneText.text=[responseObject objectForKey:@"mobile"];
                                                  //28/12/2016
                                                  //dataCount = 7; //6
                                                  if([[responseObject objectForKey:@"Type trip"]isEqualToString:@""])
                                                  {
                                                      dataCount = 7;
                                                  }
                                                  else
                                                  {
                                                      dataCount = 8;
                                                  }
                                                  strPicklat=[[responseObject objectForKey:@"pickup_latlong"]valueForKey:@"lat"];
                                                  strPicklon=[[responseObject objectForKey:@"pickup_latlong"]valueForKey:@"lon"];
                                                  if([[[responseObject objectForKey:@"destination_latlong"] valueForKey:@"lat"]isEqualToString:@""]){
                                                      isDesAddress = NO;
                                                      strDestlat = [NSString stringWithFormat:@"%f",objShare.applatitude];
                                                      strDestlon = [NSString stringWithFormat:@"%f",objShare.applongitude];
                                                      
                                                  }else{
                                                      [objShare hideLoading];
                                                      isDesAddress = YES;
                                                      strDestlat=[[responseObject objectForKey:@"destination_latlong"]valueForKey:@"lat"];
                                                      strDestlon=[[responseObject objectForKey:@"destination_latlong"]valueForKey:@"lon"];
                                                  }


                                                  dispatch_async(dispatch_get_main_queue(), ^(void){
                                                      //Run UI Updates
                                                      [tblEndtrip reloadData];
                                                      tblEndtrip.userInteractionEnabled = YES;
                                                      [tblEndtrip updateConstraintsIfNeeded];
                                                      [tblEndtrip layoutIfNeeded];
                                                      constantHeightTbl.constant = tblEndtrip.contentSize.height + 10;
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          constantHeightTbl.constant = tblEndtrip.contentSize.height + 10;
                                                      });
                                                  });
                                              
                                              }
                                              else {
                                                  [objShare hideLoading];
                                                  DisplayAlert(@"Your Email Address Not Registered.")
                                              }
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              [objShare hideLoading];
                                              DisplaySimpleAlert(TRY_AGAIN_MSG)

                                          }];
    //[op start];
}

- (void) getAddressFromLatLon:(double)latitude1 withLongitude:(double)longitude1
{
//    NSLog(@"%f %f", latitude1, longitude1);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    CLLocation  *bestLocation = [[CLLocation alloc]initWithLatitude:latitude1 longitude:longitude1];
    
    [geocoder reverseGeocodeLocation:bestLocation
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error){
             [objShare hideLoading];
//             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         [objShare hideLoading];
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSString *FormattedAddressLines = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         strDropoffAddress = [NSString stringWithFormat:@"%@",FormattedAddressLines];
     }];
}


-(void)timeDistanceFromLonLatAPIcall{
    
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    NSDictionary *dictTrip=[[NSUserDefaults standardUserDefaults] objectForKey:@"coordinates_start"];
    
    
    NSString *str_origin = [NSString stringWithFormat:@"origin=%@,%@",strPicklat,strPicklon];
    NSString *str_dest = [NSString stringWithFormat:@"destination=%@,%@",strDestlat, strDestlon];

    NSString *sensor = @"sensor=false";
    NSString *parameters = [NSString stringWithFormat:@"%@&%@&%@",str_origin,str_dest,sensor];
    NSString *output =@"json";
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/%@?%@",output,parameters];
    
    NSLog(@"URL ------> %@",url);
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            // do work here
            if(data==nil)
            {
                [objShare hideLoading];
                DisplaySimpleAlert(TRY_AGAIN_MSG)
            }
            else
            {
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSArray *arrroutes = [json objectForKey:@"routes"];
                NSString *duration;
                NSString *distance;
                if([arrroutes count] > 0){
                    NSDictionary *temp1 = [arrroutes objectAtIndex:0];
                    NSArray *arrlegs = [temp1 objectForKey:@"legs"];
                    NSDictionary *temp2 = [arrlegs objectAtIndex:0];
                    duration = [[temp2 objectForKey:@"duration"] valueForKey:@"text"];
                    distance = [[temp2 objectForKey:@"distance"] valueForKey:@"text"];
                }else{
                    duration = @"0.00";
                    distance = @"0.00";
                }
            
//                NSLog(@"DURATION DISTANCE--------------->>>>> %@ --- %@",duration,distance);
                [objShare hideLoading];
                [self CallWebserviceForTripDuration:duration distance:distance];
            }
        });

       
    });
}

-(void)CallWebserviceForTripDuration:(NSString *)duration distance:(NSString *)distance
{
    endtripAPITag = 2;
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    strDestlat = [NSString stringWithFormat:@"%f",objShare.applatitude];
    strDestlon = [NSString stringWithFormat:@"%f",objShare.applongitude];
    
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    if(CustomerId)
    {
        [dictParameter setObject:CustomerId forKey:@"userid"];
    }
    if(RequestId)
    {
        [dictParameter setObject:RequestId forKey:@"request_id"];
    }
    [dictParameter setObject:duration forKey:@"distance_time"];
    [dictParameter setObject:distance forKey:@"distance_km"];
    [dictParameter setObject:@"0" forKey:@"is_manual"];
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
    if(strTotalHoldTime)
    {
        [dictParameter setObject:strTotalHoldTime forKey:@"hold_time"];
    }

    [dictParameter setObject:strDestlat forKey:@"dest_lat"];
    [dictParameter setObject:strDestlon forKey:@"dest_lon"];
    
    if([AppDel.mainSocket isConnected])
    {
        [dictParameter setObject:@"endtrip" forKey:Socket_Request_Type];
        [dictParameter setObject:UDUserId forKey:Socket_Requester_Id];
        AppDel.dicSocketSend = [NSMutableDictionary new];
        AppDel.dicSocketSend = [dictParameter mutableCopy];
        [AppDel sendRequest];
        return;
    }

    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@endtrip",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
    success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endTripRequestResponse:responseObject];
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [objShare hideLoading];
         DisplaySimpleAlert(TRY_AGAIN_MSG)
     }];

}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{

    NSDictionary *dictTrip=[[NSUserDefaults standardUserDefaults] objectForKey:@"coordinates_start"];
    CLLocation *myLoc= newLocation;
    latitude = [NSNumber numberWithDouble:myLoc.coordinate.latitude];
    longitude = [NSNumber numberWithDouble:myLoc.coordinate.longitude];
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:oldLocation.coordinate.latitude longitude:oldLocation.coordinate.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.latitude];
    CLLocationDistance distance = ([loc2 distanceFromLocation:loc1]) * 0.000621371192;
    marker.position = CLLocationCoordinate2DMake([latitude floatValue],[longitude floatValue]);
    marker.rotation=myLoc.course;
    [mapView_ animateToLocation:myLoc.coordinate];
    [[NSUserDefaults standardUserDefaults]setValue:latitude forKey:@"MeterScreenCurrentLocationLat"];
    [[NSUserDefaults standardUserDefaults]setValue:latitude forKey:@"MeterScreenCurrentLocationLon"];
}

-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude1 = 0, longitude1 = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude1];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude1];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude=latitude1;
    center.longitude = longitude1;
//    NSLog(@"View Controller get Location Logitute : %f",center.latitude);
//    NSLog(@"View Controller get Location Latitute : %f",center.longitude);
    return center;
}

#pragma mark Button Clicked Method
- (IBAction)btnSubmitClicked:(UIButton *)sender {
    
    if([textTripAmount.text length] == 0){
        DisplayAlertWithTitle([NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_tripAmount", @"Localizable", [AppDel bundle], nil)], APP_NAME);
        return;
    }
    [self CallWebserviceTripAmountForEndTrip];
}
- (IBAction)btnBackPopupClicked:(UIButton *)sender {
    viewAlert.hidden = true;
}

- (IBAction)btnAutoManuClicked:(UIButton *)sender {
    
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == 0){
        [self timeDistanceFromLonLatAPIcall];

    }else{
        viewTrip.hidden = false;
    }
    viewAlert.hidden = true;
}


- (IBAction)btnHoldPressed:(id)sender {
    NSString *tempHorR;
    NSString *strHoldTime;
    if(_btnHold.tag==0)
    {
        _btnHold.tag=1;
        [_btnHold setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_Start_again", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
        dateToday = [NSDate date];
        strHoldTime = @"";
        tempHorR = @"1";
    }
    else
    {
        _btnHold.tag=0;
        [_btnHold setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_holdtrip", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
//        NSLog(@"%@",dateToday);
        NSDate *date2 = [NSDate date];
        NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:dateToday];
        int numberOfDays = secondsBetween / 60;
        if(numberOfDays<1)
        {
            numberOfDays=1;
        }
        strHoldTime = [NSString stringWithFormat:@"%d",numberOfDays];
        tempHorR = @"2";
    }
    [self callWebServiceForHoldCar:strHoldTime Flag:tempHorR];
}



- (IBAction)btnEndTripPressed:(id)sender {
    viewAlert.hidden = false;
}

#pragma mark UITableView Method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataCount;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0){
        ArrivingUserInfoCell *cell = (ArrivingUserInfoCell *) [tableView dequeueReusableCellWithIdentifier:@"ArrivingUserInfoCell"];
        if (cell == nil){
            cell = [[ArrivingUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ArrivingUserInfoCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSURL *imageURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"driver_image"]];
        [cell.imgUser sd_setImageWithURL:imageURL];
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height /2;
        cell.imgUser.layer.masksToBounds = YES;
        cell.lblName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"driver_name"];
        cell.lblLocation.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurLocation"];
        cell.viewRating.allowsHalfStars = true;
        cell.viewRating.value = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ratting"] floatValue];
        
        NSURL *carURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"car_image"]];
        [cell.imgCar sd_setImageWithURL:carURL];
        
        if (dictResponse != nil){
            if(![[dictResponse valueForKey:@"car_type"] isEqual:[NSNull null]]){
                cell.lblCar.text = [dictResponse valueForKey:@"car_type"];
            }
            
        }else{
            cell.lblCar.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"car_type"];
        }
        
        NSShadow * shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor whiteColor];
        shadow.shadowOffset = CGSizeMake(1, 1);
        
        NSDictionary * textAttributes =
        @{ NSForegroundColorAttributeName : [UIColor blackColor],
           NSShadowAttributeName          : shadow,
           NSFontAttributeName            : [UIFont boldSystemFontOfSize:14] };
        
        cell.lblNumberPlate.attributedText = [[NSAttributedString alloc] initWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"car_number"]
                                                                             attributes:textAttributes];
        
        cell.lblNumberPlate.layer.borderWidth = 1.0f;
        cell.lblNumberPlate.layer.borderColor = [UIColor blackColor].CGColor;
        return cell;
        
    }
    else if (indexPath.row == 1){
        UserInfoCell *cell = (UserInfoCell *) [tableView dequeueReusableCellWithIdentifier:@"UserInfoCell"];
        if (cell == nil){
            cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserInfoCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(dictResponse != nil){
            NSURL *imgUserUrl = [NSURL URLWithString:[dictResponse valueForKey:@"passenger_image"]];
            [cell.imgUser sd_setImageWithURL:imgUserUrl];
            cell.lblName.text = [dictResponse valueForKey:@"passenger"];
            //01/12/2016
            cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height /2;
            cell.imgUser.layer.masksToBounds = YES;
            cell.imgUser.layer.borderWidth = 2.0f;
            cell.imgUser.layer.borderColor=[textColor(81,81,80)CGColor];
        }
        return cell;
    }

    else{
        ArrivinglocationCell *cell = (ArrivinglocationCell *) [tableView dequeueReusableCellWithIdentifier:@"ArrivinglocationCell"];
        if (cell == nil){
            cell = [[ArrivinglocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ArrivinglocationCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.row == 2){
            if (dictResponse != nil){
                cell.lblName.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_pick_up_time", @"Localizable", [AppDel bundle], nil)];
                cell.imgUser.image = [UIImage imageNamed:@"timeImg"];
                NSString *gmtDateString = [dictResponse valueForKey:@"pickup_time"];
                NSDateFormatter *df = [NSDateFormatter new];
                [df setDateFormat: @"dd MMM yyyy HH:mm:ssZZZZZ"];
//                df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                df.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                NSDate *mydate = [df dateFromString:gmtDateString];
                df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
                NSString *languageID = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppLanguage"];
                NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:languageID];
                [df setLocale:locale];
                [df setDateFormat: @"dd MMM yyyy HH:mm"];
                NSString *localDateString = [df stringFromDate:mydate];
                cell.lblLocation.text = localDateString;
            }
        }
        else if(indexPath.row == 3){
            if (dictResponse != nil){
                cell.lblName.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_pick_up_location", @"Localizable", [AppDel bundle], nil)];
                cell.imgUser.image = [UIImage imageNamed:@"map-pin.png"];
                cell.lblLocation.text = [dictResponse valueForKey:@"pickup_address"];
            }
        }else if(indexPath.row == 4){
            if (dictResponse != nil){
                cell.lblName.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_drop_off", @"Localizable", [AppDel bundle], nil)];
                cell.imgUser.image = [UIImage imageNamed:@"flag-black-icon.png"];
                cell.lblLocation.text = [dictResponse valueForKey:@"destination_address"];
            }
        }
        else{
            if (dataCount == 7){
                if(indexPath.row == 5){
                    if (dictResponse != nil){
                        cell.lblName.text = @"Contact";
                        cell.imgUser.image = [UIImage imageNamed:@"call-icon.png"];
                        cell.lblLocation.text = [dictResponse valueForKey:@"mobile"];
                    }
                }else if(indexPath.row == 6){
                    if (dictResponse != nil){
                        cell.lblName.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"cell_msg_comment", @"Localizable", [AppDel bundle], nil)];
                        cell.imgUser.image = [UIImage imageNamed:@"comment-icon.png"];
                        cell.lblLocation.text = [dictResponse valueForKey:@"comment"];
                    }
                }
                
            }
            else{
                if(indexPath.row == 5){
                    if (dictResponse != nil){
                        //cell.lblName.text = @"Contact";
                        cell.lblName.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_type", @"Localizable", [AppDel bundle], nil)];
                        cell.imgUser.image = [UIImage imageNamed:@"user@2x.png"];
                        cell.lblLocation.text = [[dictResponse valueForKey:@"Type trip"] isEqualToString:@"Cash/credit card"] ? [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_cash_credit_card", @"Localizable", [AppDel bundle], nil)] : [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_on_account", @"Localizable", [AppDel bundle], nil)];
                    }
                }else if(indexPath.row == 6){
                    if (dictResponse != nil){
                        cell.lblName.text = @"Contact";
                        cell.imgUser.image = [UIImage imageNamed:@"call-icon.png"];
                        cell.lblLocation.text = [dictResponse valueForKey:@"mobile"];
                    }
                }else if(indexPath.row == 7){
                    if (dictResponse != nil){
                        cell.lblName.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"cell_msg_comment", @"Localizable", [AppDel bundle], nil)];
                        cell.imgUser.image = [UIImage imageNamed:@"comment-icon.png"];
                        cell.lblLocation.text = [dictResponse valueForKey:@"comment"];
                    }
                }
            }
        }
//        else if(indexPath.row == 5){
//            if (dictResponse != nil){
//                cell.lblName.text = @"Contact";
//                cell.imgUser.image = [UIImage imageNamed:@"call-icon.png"];
//                cell.lblLocation.text = [dictResponse valueForKey:@"mobile"];
//            }
//        }
//        //28/12/2016
//        else if(indexPath.row == 6){
//            if (dictResponse != nil){
//                cell.lblName.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"cell_msg_comment", @"Localizable", [AppDel bundle], nil)];
//                cell.imgUser.image = [UIImage imageNamed:@"comment-icon.png"];
//                cell.lblLocation.text = [dictResponse valueForKey:@"comment"];
//            }
//        }
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        return 104;
    }else if(indexPath.row == 1){
        return 64;
    }
    else{
        return UITableViewAutomaticDimension;
    }
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 1){
        return 64;
    }else{
        return UITableViewAutomaticDimension;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
