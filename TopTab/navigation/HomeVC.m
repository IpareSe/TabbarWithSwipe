
#import "HomeVC.h"
#import "SliderContainerVC.h"
#import "NotificationVC.h"
#import "AppConstant.h"
#import "ConfirmRequestVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>
#import "ArrivingVC.h"
#import "SharedClass.h"
#import "RejectRequestVC.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "WebserviceManager.h"
#import "HCSStarRatingView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ConfirmRequestVC.h"
#import <SDWebImage/SDWebImageDownloader.h>

#define RadiansToDegrees(radians)(radians * 180.0/M_PI)
#define DegreesToRadians(degrees)(degrees * M_PI / 180.0)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface HomeVC ()<CLLocationManagerDelegate,GMSMapViewDelegate>
{
    CLLocationManager * locationmanager;
    GMSMapView *mapView_;
    GMSMarker *marker;
    NSTimer* m_timer;
    NSNumber *longitude;
    NSNumber *latitude;
    NSString *strCurrLoc;
    NSArray *routes;
    CLLocationCoordinate2D point;
    UITextView *txtDesc;
    BOOL flag;
    bool type;
    GMSCameraPosition *camera;
    float direction;
    NSMutableArray *points;
    float driverUpdateLocationTimer;
    BOOL flagForOfline;
    IBOutlet HCSStarRatingView *viewRating;
    NSTimer *timerDriverHome;
    NSMutableArray  *arrDriverTrackingHome;

    IBOutlet UILabel *lblAppCount;
}

@end

@implementation HomeVC

@synthesize coordinate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLanguage];
    if (![AppDel.mainSocket isConnected])
    {
        [AppDel socketConnect];
        [AppDel connectUserToSocket];
    }

    driverUpdateLocationTimer = 10.0; // Timer Variable to update DRIVER LOCATION
    objShare.isBackgroundNotif = NO;
    flag = true;
    
    arrDriverTrackingHome = [[NSMutableArray alloc]init];
    
    _imgUser.layer.cornerRadius = _imgUser.frame.size.height /2;
    _imgUser.layer.masksToBounds = YES;
    _imgUser.layer.borderWidth = 3.0f;
    _imgUser.layer.borderColor=[textColor(81,81,80)CGColor];
    

    //01/12/2016

    
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDriverInfo:) name:@"UpdateDriverInfo" object:nil];
    
    [super viewWillAppear:YES];
    //12/12/2016
    [self displayMap];

    if([objShare isNetworkReachable])
    {
#pragma  mark **** found issue of tik tik not work
        [self CallAPIForDriverInformation];
    }
    else
    {
        DisplaySimpleAlert([NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_network_not_found", @"Localizable", [AppDel bundle], nil)])

    }
}

-(void)updateDriverInfo:(NSNotification *)notification
{
    NSMutableDictionary *dict = [notification object];
    _lblLocation.text = [dict objectForKey:@"address"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
    [timerDriverHome invalidate];
    timerDriverHome = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //01/12/2016
   

}

-(void)setLanguage
{
    self.lblHome.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_home", @"Localizable", [AppDel bundle], nil)];
    
}

-(void)displayMap
{
    
    NSDictionary *dict= [[NSUserDefaults standardUserDefaults]objectForKey:@"coordinates"];
    latitude=[dict objectForKey:@"lat"];
    longitude=[dict objectForKey:@"lon"];
    
    [self getCurrentLocation:latitude and:longitude];
    
    camera = [GMSCameraPosition cameraWithLatitude:[latitude floatValue]
                                         longitude:[longitude floatValue]zoom:16];
    
    
    //23/11/2016 live
    if(isiPad){
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH, WINDOW_HEIGHT - 160) camera:camera];

    }else{
        if(IS_IPHONE_5)
        {
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH,380) camera:camera];
        }
        else if(IS_IPHONE_6P)
        {
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH,550) camera:camera];
        }
        else if(IS_IPHONE_4)
        {
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH,300) camera:camera];
        }
        else
        {
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH,480) camera:camera];
        }
    }
    
    mapView_.myLocationEnabled = YES;
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.delegate = self;
    [self.view addSubview: mapView_];

    marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
    
    
    NSString *catString = [[NSUserDefaults standardUserDefaults]stringForKey:@"car_category"].lowercaseString;
    if(catString){
        if([catString isEqualToString:@"car"]){
            marker.icon=[UIImage imageNamed:@"trackcar"];
        }else if([catString isEqualToString:@"van"]){
            marker.icon=[UIImage imageNamed:@"trackvan"];
        }else if([catString isEqualToString:@"business +"]){
            marker.icon=[UIImage imageNamed:@"trackcar"];
        }else if([catString isEqualToString:@"electric car"]){
            marker.icon=[UIImage imageNamed:@"gcar"];
        }
    }
    
    
    //hitendra set image with url from backend
    NSURL *urlMarker = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults]stringForKey:@"vCarCatImage"]];
    [[SDWebImageManager sharedManager]  downloadImageWithURL:urlMarker
                                                     options:(SDWebImageHighPriority)
                                                    progress:nil
                                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                       if (image) {
                                                         //  NSLog(@"Image update to url := %@",urlMarker.absoluteString);
                                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                               marker.icon = image;
                                                           }];
                                                       }
                                                   }];
    
    marker.groundAnchor = CGPointMake(0.5, 0.5);
    marker.flat = YES;
    marker.map = mapView_;

    //12/12/2016
#pragma mark *** timer call to start update driver location Solved Start Call from Arriving screen and ended At Start Trip
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
    //06/02/2018
    if(userId != nil){
        [objShare latLongUpdateToServerMethod]; //Nipa 20/10/2016
    } // 04/10/2016 Nipa
    if(timerDriverHome)
    {
        [timerDriverHome invalidate];
        timerDriverHome = nil;
    }
    timerDriverHome = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                       target:self
                                                     selector:@selector(liveDriverTrackingMethod)
                                                     userInfo:nil
                                                      repeats:YES];
    [timerDriverHome fire];
    
}

-(void)liveDriverTrackingMethod{
    NSMutableDictionary  *tempDict = [[NSMutableDictionary alloc]init];
    [tempDict setObject:[NSString stringWithFormat:@"%f",objShare.applatitude] forKey:@"prevLat"];
    [tempDict setObject:[NSString stringWithFormat:@"%f",objShare.applongitude] forKey:@"prevLong"];
    [tempDict setObject:[NSString stringWithFormat:@"%f",objShare.appangle] forKey:@"angel"];
    [arrDriverTrackingHome addObject:tempDict];
    if([arrDriverTrackingHome count] > 1) {
        [CATransaction begin];
        [CATransaction setAnimationDuration: 3.0];
        NSMutableDictionary *prevdict = [arrDriverTrackingHome objectAtIndex:[arrDriverTrackingHome count] - 2];
        double prevLat = [[prevdict valueForKey:@"prevLat"] doubleValue];
        double prevLon = [[prevdict valueForKey:@"prevLong"] doubleValue];
        
        NSString *catString = [[NSUserDefaults standardUserDefaults]stringForKey:@"car_category"].lowercaseString;
        if(catString){
            if([catString isEqualToString:@"car"]){
                marker.icon=[UIImage imageNamed:@"trackcar"];
            }else if([catString isEqualToString:@"van"]){
                marker.icon=[UIImage imageNamed:@"trackvan"];
            }else if([catString isEqualToString:@"business +"]){
                marker.icon=[UIImage imageNamed:@"trackcar"];
            }else if([catString isEqualToString:@"electric car"]){
                marker.icon=[UIImage imageNamed:@"gcar"];
            }
        }
        
        //hitendra set image with url from backend
        NSURL *urlMarker = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults]stringForKey:@"vCarCatImage"]];
        [[SDWebImageManager sharedManager]  downloadImageWithURL:urlMarker
                                                         options:(SDWebImageHighPriority)
                                                        progress:nil
                                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                           if (image) {
                                                             //  NSLog(@"Image update to url := %@",urlMarker.absoluteString);
                                                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                   marker.icon = image;
                                                               }];
                                                           }
                                                       }];
        
        //12/12/2016
        if(prevLat > 0){
            [mapView_ animateToLocation:CLLocationCoordinate2DMake(prevLat,prevLon)];
            marker.map = mapView_;
            marker.position = CLLocationCoordinate2DMake(prevLat,prevLon);
            NSMutableDictionary *curDict = [arrDriverTrackingHome lastObject];
            double curangle = [[curDict valueForKey:@"angel"] doubleValue];
            marker.rotation = curangle;
        }
        [CATransaction commit];
    }
}

-(void)getCurrentLocation:(NSString *)Passedlat and:(NSString*)Passedlon
{

    latitude = Passedlat;
    longitude = Passedlon;
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(
                                                              [latitude floatValue],[longitude floatValue]);
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:coord.latitude longitude:coord.longitude]; //insert your coordinates
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks,NSError *error) {
                  if (!error) {
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      
                      if(placemark.subLocality == nil || placemark.subLocality == (id)[NSNull null]){
                          _lblLocation.text=[NSString stringWithFormat:@"%@,%@",placemark.name,placemark.locality];
                          
                      }else{
                          _lblLocation.text=[NSString stringWithFormat:@"%@,%@,%@",placemark.name,placemark.subLocality,placemark.locality];
                      }
                      
                      [[NSUserDefaults standardUserDefaults]setObject:_lblLocation.text forKey:@"CurLocation"];
                      NSLog(@"CurLocation Home2 : %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"CurLocation"]);
                      [[NSUserDefaults standardUserDefaults]synchronize];
                  }
                  else {
                      NSLog(@"Error in getCurrentLocation = %@",error.description);
                  }
              }
     ];
}

-(void)callWebserviceforSwichMode:(NSString *)status
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
    
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
        NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
        [dictParameter setObject:UDUserId forKey:@"driver_userid"];
        [dictParameter setObject:status forKey:@"status"];
        [dictParameter setObject:lang forKey:@"language"];
        [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@gooffline",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        }
        success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if([[responseObject objectForKey:@"response_status"] integerValue]==1)
             {
                 if([status isEqualToString:@"1"]) //online
                 {
                     [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"UDDriverOnlineOfflineStatus"];
                     
                     _btnOffline.selected=0;
                     [AppDel socketConnect];
                     [AppDel connectUserToSocket];
                     //06/02/2018
                     [objShare latLongUpdateToServerMethod];
                 }
                 else // ofline
                 {
                     [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"UDDriverOnlineOfflineStatus"];
                     [AppDel socketDisconnect];
                     [objShare.timerupdateUserlatLong invalidate];
                     objShare.timerupdateUserlatLong = nil;
                     _btnOffline.selected=1;
                 }
                 [objShare hideLoading];
             }
             else
             {
                 [objShare hideLoading];
             }
         }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [objShare hideLoading];
          DisplaySimpleAlert(TRY_AGAIN_MSG)
      }];
}
#pragma  mark **** found issue of tik tik not work

-(void)CallAPIForDriverInformation
{
  // [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    if (!isSetDestination) {
        NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
//        NSLog(@"%@",UDUserId);
        [dictParameter setObject:UDUserId forKey:@"userid"];
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

//        if([AppDel.mainSocket isConnected])
//        {
//            [dictParameter setObject:@"getalldriver" forKey:Socket_Request_Type];
//            AppDel.dicSocketSend = [NSMutableDictionary new];
//            AppDel.dicSocketSend = [dictParameter mutableCopy];
//            [AppDel sendRequest];
//            return;
//        }
        
        [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@getdriverdetail",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        }
        success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
           // [objShare hideLoading];
            if(![self.lblLocation.text isEqualToString:@""])
            {
                [[NSUserDefaults standardUserDefaults]setObject:_lblLocation.text forKey:@"CurLocation"];
                NSLog(@"CurLocation Home1 : %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"CurLocation"]);
            }
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"driver_image"] forKey:@"driver_image"];
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"driver_name"] forKey:@"driver_name"];
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"ratting"] forKey:@"ratting"];
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"car_image"] forKey:@"car_image"];
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"car_number"] forKey:@"car_number"];
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"car_id"] forKey:@"CarId"];
            
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"car_type"] forKey:@"car_type"];
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"car_category"]  forKey:@"car_category"];
            [[NSUserDefaults standardUserDefaults]setObject:[responseObject valueForKey:@"vCarCatImage"]  forKey:@"vCarCatImage"];
            
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            NSString *catString = [[NSUserDefaults standardUserDefaults]stringForKey:@"car_category"].lowercaseString;
            if(catString){
                if([catString isEqualToString:@"car"]){
                    marker.icon=[UIImage imageNamed:@"trackcar"];
                }else if([catString isEqualToString:@"van"]){
                    marker.icon=[UIImage imageNamed:@"trackvan"];
                }else if([catString isEqualToString:@"business +"]){
                    marker.icon=[UIImage imageNamed:@"trackcar"];
                }else if([catString isEqualToString:@"electric car"]){
                    marker.icon=[UIImage imageNamed:@"gcar"];
                }
            }

            
            //hitendra set image with url from backend
            NSURL *urlMarker = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults]stringForKey:@"vCarCatImage"]];
            [[SDWebImageManager sharedManager]  downloadImageWithURL:urlMarker
                                                             options:(SDWebImageHighPriority)
                                                            progress:nil
                                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                               if (image) {
                                                                 //  NSLog(@"Image update to url := %@",urlMarker.absoluteString);
                                                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                       marker.icon = image;
                                                                   }];
                                                               }
                                                           }];
            
            
            _lblDriverName.text=[responseObject valueForKey:@"driver_name"];
            
            NSURL *imageURL = [NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] valueForKey:@"MyUserProfile"] valueForKey:@"profilepic"]];
            self.imgUser.contentMode = UIViewContentModeScaleAspectFill;
            [self.imgUser sd_setImageWithURL:imageURL];
            
            NSURL *carURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"car_image"]];
            [imgCar sd_setImageWithURL:carURL];
            lblCar.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"car_type"];
            //            lblNumberPlate.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"car_number"];
            
            NSShadow * shadow = [[NSShadow alloc] init];
            shadow.shadowColor = [UIColor whiteColor];
            shadow.shadowOffset = CGSizeMake(1, 1);
            
            NSDictionary * textAttributes =
            @{ NSForegroundColorAttributeName : [UIColor blackColor],
               NSShadowAttributeName          : shadow,
               NSFontAttributeName            : [UIFont boldSystemFontOfSize:14] };
            
            lblNumberPlate.attributedText = [[NSAttributedString alloc] initWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"car_number"]
                                                                            attributes:textAttributes];
            
            lblNumberPlate.layer.borderWidth = 1.0f;
            lblNumberPlate.layer.borderColor = [UIColor blackColor].CGColor;
            
            viewRating.allowsHalfStars = true;
            viewRating.value = [[responseObject valueForKey:@"ratting"] floatValue];
            if([[responseObject valueForKey:@"ofline_online_status"]integerValue]==2)
            {
                _btnOffline.selected=1; // offline
                [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"UDDriverOnlineOfflineStatus"];
            }
            else
            {
                _btnOffline.selected=0; // online
                [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"UDDriverOnlineOfflineStatus"];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //[objShare hideLoading];
            DisplaySimpleAlert(TRY_AGAIN_MSG)
        }];
    }
    
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
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil])
            {
                [scanner scanDouble:&longitude1];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude=latitude1;
    center.longitude = longitude1;

    return center;
}



#pragma mark *** timer call to start update driver location
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0)
        return;
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    CGFloat radians = -theHeading / 180.0 * M_PI;
    CGFloat angle = RADIANS_TO_DEGREES(radians);
    [mapView_ animateToBearing:theHeading]; //Nipa
//    marker.rotation = theHeading;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    NSMutableDictionary *dict= [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithDouble:currentLocation.coordinate.latitude]  forKey:@"lat"];
    [dict setObject:[NSNumber numberWithDouble:currentLocation.coordinate.longitude] forKey:@"lon"];
    [dict setObject:[NSNumber numberWithDouble:currentLocation.course] forKey:@"course"];
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"coordinates"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSString *str1 = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    NSString *str2 = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    [self getCurrentLocation:str1 and:str2];
    
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.5];
    marker.rotation = currentLocation.course;
    marker.position = currentLocation.coordinate;
    [CATransaction commit];
    CLLocation *locationManager = [CLLocation new];
    
}
- (IBAction)btnclicked:(UIButton *)sender {
    ArrivingVC *rvc1 = (ArrivingVC*)[self.storyboard instantiateViewControllerWithIdentifier: @"ArrivingVC"];
    [self.navigationController pushViewController:rvc1 animated:YES];
    
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
   
    CLLocation *myLoc= newLocation;
//    NSLog(@"%f %f", myLoc.coordinate.latitude,myLoc.coordinate.longitude);
    latitude = [NSNumber numberWithDouble:myLoc.coordinate.latitude];
    longitude = [NSNumber numberWithDouble:myLoc.coordinate.longitude];
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:oldLocation.coordinate.latitude longitude:oldLocation.coordinate.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.latitude];
    CLLocationDistance distance = ([loc2 distanceFromLocation:loc1]) * 0.000621371192;
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0];
    [mapView_ animateToLocation:myLoc.coordinate];
    [CATransaction commit];
    // NSLog(@"distance:%f",distance);
    if (marker)
    {
        marker.map = nil;
        marker = nil;
    }
    marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
    marker.groundAnchor = CGPointMake(0.5, 0.5);
    marker.flat = YES;
    marker.map = mapView_;
}

-(NSString *)GetTravelTime
{
    NSString *strUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=%@", 23.2200, 72.6800, [latitude floatValue] ,[longitude floatValue], @"DRIVING"];
    NSURL *url = [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    NSString *strtravelTime=@"";
    if(jsonData != nil)
    {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *arrDistance=[result objectForKey:@"routes"];
        NSMutableArray *arrLeg=[[arrDistance objectAtIndex:0]objectForKey:@"legs"];
        NSMutableDictionary *dictleg=[arrLeg objectAtIndex:0];
        strtravelTime=[[dictleg valueForKey:@"distance"]valueForKey:@"text"];
    }
    return strtravelTime;
}

-(NSString *)GetDistance
{
    NSString *strUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=%@", 23.2200, 72.6800, [latitude floatValue] ,[longitude floatValue], @"DRIVING"];
    NSURL *url = [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    NSString *strDistance=@"";
    if(jsonData != nil)
    {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *arrDistance=[result objectForKey:@"routes"];
        NSMutableArray *arrLeg=[[arrDistance objectAtIndex:0]objectForKey:@"legs"];
        NSMutableDictionary *dictleg=[arrLeg objectAtIndex:0];
        strDistance=[[dictleg valueForKey:@"duration"]valueForKey:@"text"];
    }
    return strDistance;
}

- (IBAction)btnSwichModePressed:(id)sender {
    
    if([_btnOffline isSelected])
    {
        //06/02/2018
        [objShare locationUpdateMethod];
        if([objShare isNetworkReachable])
        {
            [self callWebserviceforSwichMode:@"1"];
        }
        else
        {
            DisplaySimpleAlert([NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_network_not_found", @"Localizable", [AppDel bundle], nil)])
        }
    }
    else
    {
        flagForOfline= TRUE;
        UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                            message:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_sur_offline", @"Localizable", [AppDel bundle], nil)]
                                                            delegate:self
                                                            cancelButtonTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_go_offline", @"Localizable", [AppDel bundle], nil)]
                                                            otherButtonTitles:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_keep_driving", @"Localizable", [AppDel bundle], nil)], nil];
        [alert_notification show];
     
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if(flagForOfline)
    {
        if([title isEqualToString:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_go_offline", @"Localizable", [AppDel bundle], nil)]])
        {
//            _btnOffline.selected=1;
            if([objShare isNetworkReachable])
            {
                [self callWebserviceforSwichMode:@"2"];
                flagForOfline = FALSE;
                [objShare.locationManager stopUpdatingLocation];
            }
            else
            {
                //06/02/2018
                [objShare locationUpdateMethod];
                DisplaySimpleAlert([NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_network_not_found", @"Localizable", [AppDel bundle], nil)])
            }
        }
    }
    else
    {
        
    }
}

- (IBAction)btnSideBarPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SideBarManage" object:nil];
    //[_BRSlider slideOpen];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
