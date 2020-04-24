//
//  ArrivedVC.m
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import "ArrivedVC.h"
#import "EndTripVC.h"
#import "CancelRequestVC.h"
#import "AppConstant.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SharedClass.h"
#import <AFNetworking.h>
#import "HomeVC.h"
#import "ArrivingUserInfoCell.h"
#import "ArrivinglocationCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoCell.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ArrivedVC ()<CLLocationManagerDelegate,GMSMapViewDelegate>
{
    NSTimer* m_timer;
    UIButton *button;
    IBOutlet GMSMapView *mapView_;
    CLLocationManager * locationmanager;
    //  CLLocation *crnLoc;
    NSNumber *longitude;
    NSNumber *latitude;
    GMSMarker *marker;
    NSString *strCurrLoc;
    NSArray *routes;
    CLLocationCoordinate2D point;
    NSString *strPhoneNo;
    
    NSString *strPicklat,*strPicklon;
    
    IBOutlet NSLayoutConstraint *constantHeightTbl;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITableView *tblArrived;
    NSDictionary  *dictResponse;
    IBOutlet UILabel *lblPhoneNumber;
    IBOutlet UIView *viewCall;
    IBOutlet UILabel *lblStatCall;
    IBOutlet UIButton *btnCall;
    IBOutlet UIButton *btnCancel1;
    int dataCount;
    NSTimer *timerDriver;
    NSMutableArray  *arrDriverTracking;
    NSString *strPassenger;
    NSString *strCarType;
}
@end

@implementation ArrivedVC
@synthesize isStartTripButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    dataCount = 1;
    arrDriverTracking = [[NSMutableArray alloc]init];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.btnYes.bounds byRoundingCorners:(UIRectCornerBottomLeft) cornerRadii:CGSizeMake(25.0, 25.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.btnNo.bounds byRoundingCorners:(UIRectCornerBottomRight) cornerRadii:CGSizeMake(25.0, 25.0)];
    CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
    maskLayer1.frame = self.view.bounds;
    maskLayer1.path  = maskPath1.CGPath;
    _viewAlert.hidden=true;
    _viewReqcancel.hidden=true;
    [self.view addSubview:_viewAlert];
    [self setLanguage];
    
}

-(void)setLanguage
{
    [_btnYes setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_yes", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    if(isStartTripButton){
        [_btnTrip setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_starttrip", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    }else{
        [_btnTrip setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_arrived", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    }
    [_btnNo setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_no", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [_btnCancel setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_cancel", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [_btnCustomer setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_callcustmr", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    lblStatCall.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_callcustmr", @"Localizable", [AppDel bundle], nil)];
    self.lblSure.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_sure", @"Localizable", [AppDel bundle], nil)];
    self.lblCancelReq.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_cancle_req", @"Localizable", [AppDel bundle], nil)];
    self.lblArrived.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_arrivenow", @"Localizable", [AppDel bundle], nil)];
    
    [btnCall setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_callNew", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [btnCancel1 setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_cancel", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rejectrequestObserver:) name:@"rejectrequest" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(starttripRequestObserver:) name:@"starttrip" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(driverarrivednotifyRequestObserver:) name:@"driverarrivednotify" object:nil];
    [self callWebServiceforArrivingRequest];
    
}

- (void)rejectrequestObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self rejectRequestResponse:requestInfo];
}


- (void)driverarrivednotifyRequestObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self driverarrivednotifyRequestResponse:requestInfo];
    
}

- (void)starttripRequestObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self starttripRequestResponse:requestInfo];
    
}

-(void)rejectRequestResponse:(NSDictionary *)responseObject
{
    if([[responseObject objectForKey:@"response_status"] integerValue]==1)
    {
        [objShare hideLoading];
        //05/06/2017 Nipa
        [SharedClass objSharedClass].isCurrentTripOn = false;

        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"RequestId"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [SharedClass objSharedClass].selectSettingsOption(0);
    }
    else
    {
        [objShare hideLoading];
    }
}

-(void)starttripRequestResponse:(NSDictionary *)response
{
    if([[response objectForKey:@"response_status"] integerValue]==1)
    {
        [objShare hideLoading];
        EndTripVC *rvc = (EndTripVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"EndTripVC"];
        rvc.strPicklat = strPicklat;
        rvc.strPicklon = strPicklon;
        rvc.strPassenger = strPassenger;
        rvc.strCarType = strCarType;
        rvc.isKillAPI = NO;
        [self.navigationController pushViewController:rvc animated:YES];
    }
    else {
        [objShare hideLoading];
    }

}

-(void)driverarrivednotifyRequestResponse:(NSDictionary *)response
{
    [objShare hideLoading];
    if([[response objectForKey:@"response_status"] integerValue]==1)
    {
        [timerDriver invalidate];
        timerDriver = nil;
        [objShare hideLoading];
        
        [_btnTrip setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_starttrip", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    }
    else {
        [objShare hideLoading];
        DisplayAlertWithTitle(TRY_AGAIN_MSG, APP_NAME);
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)displayMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:objShare.applatitude
                                                            longitude:objShare.applongitude zoom:16];
    
    mapView_.camera = camera;
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    mapView_.settings.myLocationButton = YES;
    
    [self.view bringSubviewToFront:button];
    [self.view bringSubviewToFront:_viewAddressInfo];
    
    marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(objShare.applatitude, objShare.applongitude);
    
    if([strPassenger isEqualToString:@"4"])
    {
        marker.icon=[UIImage imageNamed:@"trackcar"];
    }
    else
    {
        marker.icon=[UIImage imageNamed:@"trackvan"];
    }
 
    marker.map = mapView_;
    //Hotel
    timerDriver = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(liveDriverTrackingMethod)
                                                             userInfo:nil
                                                              repeats:YES];
    [timerDriver fire];

}
-(void)liveDriverTrackingMethod{
    //12/12/2016
    NSMutableDictionary  *tempDict = [[NSMutableDictionary alloc]init];
    [tempDict setObject:[NSString stringWithFormat:@"%f",objShare.applatitude] forKey:@"prevLat"];
    [tempDict setObject:[NSString stringWithFormat:@"%f",objShare.applongitude] forKey:@"prevLong"];
    [tempDict setObject:[NSString stringWithFormat:@"%f",objShare.appangle] forKey:@"angel"];
    [arrDriverTracking addObject:tempDict];
    if([arrDriverTracking count] > 1){
        [CATransaction begin];
        [CATransaction setAnimationDuration:3.0];
        NSMutableDictionary *prevdict = [arrDriverTracking objectAtIndex:[arrDriverTracking count] - 2];
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
                                                               // NSLog(@"Image update to url := %@",urlMarker.absoluteString);
                                                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                   marker.icon = image;
                                                               }];
                                                           }
                                                       }];
        
        
        [mapView_ animateToLocation:CLLocationCoordinate2DMake(prevLat,prevLon)];
        marker.map = mapView_;
        marker.position = CLLocationCoordinate2DMake(prevLat,prevLon);
        double curangle = [[prevdict valueForKey:@"angel"] doubleValue];
        marker.rotation = curangle;
        [CATransaction commit];
    }
}

-(float)getDistanceInKm:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    float lat1,lon1,lat2,lon2;
    lat1 = newLocation.coordinate.latitude  * M_PI / 180;
    lon1 = newLocation.coordinate.longitude * M_PI / 180;
    lat2 = oldLocation.coordinate.latitude  * M_PI / 180;
    lon2 = oldLocation.coordinate.longitude * M_PI / 180;
    float R = 6371; // km
    float dLat = lat2-lat1;
    float dLon = lon2-lon1;
    float a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
    float c = 2 * atan2(sqrt(a), sqrt(1-a));
    float d = R * c;
//    NSLog(@"Kms-->%f",d);
    return d;
}

-(void)callWebServiceforArrivingRequest
{
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    if(CustomerId){
        [dictParameter setObject:CustomerId forKey:@"userid"];
    }
    if(RequestId){
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
//    NSLog(@"ArrivingScreen%@",responseObject);
    dictResponse = responseObject;

    if([[responseObject objectForKey:@"response_status"] integerValue]==1){
        [objShare hideLoading];
        //28/12/2016
        if([[responseObject objectForKey:@"Type trip"]isEqualToString:@""])
        {
            dataCount = 7;
        }
        else
        {
            dataCount = 8;
        }

        //dataCount = 7; //5
        strPhoneNo= [responseObject objectForKey:@"mobile"];
        strPicklat=[[responseObject objectForKey:@"pickup_latlong"]valueForKey:@"lat"];
        strPicklon=[[responseObject objectForKey:@"pickup_latlong"]valueForKey:@"lon"];
        strPassenger = [responseObject objectForKey:@"car_passenger"];
        strCarType = [responseObject objectForKey:@"car_type"];
        
        lblPhoneNumber.text = [NSString stringWithFormat:@"%@",strPhoneNo];
        [self displayMap];
        [tblArrived reloadData];
        tblArrived.userInteractionEnabled = YES;
        [tblArrived updateConstraintsIfNeeded];
        [tblArrived layoutIfNeeded];
        constantHeightTbl.constant = tblArrived.contentSize.height + 10;
        dispatch_async(dispatch_get_main_queue(), ^{
            constantHeightTbl.constant = tblArrived.contentSize.height + 10;
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
}

-(void)callWebServiceforRejectRequest
{
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
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
    if([_btnTrip.titleLabel.text isEqualToString:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_arrived", @"Localizable", [AppDel bundle], nil)]])
    {
        [dictParameter setObject:@"503" forKey:@"status"];

    }
    else
    {
        [dictParameter setObject:@"509" forKey:@"status"];

    }
    
    if([AppDel.mainSocket isConnected])
    {
        [dictParameter setObject:@"rejectrequest" forKey:Socket_Request_Type];
        [dictParameter setObject:UDUserId forKey:Socket_Requester_Id];
        AppDel.dicSocketSend = [NSMutableDictionary new];
        AppDel.dicSocketSend = [dictParameter mutableCopy];
        [AppDel sendRequest];
        return;
    }
    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@rejectrequest",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
    success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [self rejectRequestResponse:responseObject];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [objShare hideLoading];
        DisplaySimpleAlert(TRY_AGAIN_MSG)
    }];
}

-(void)callWebServiceforStartTrip
{
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
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
    
    if([AppDel.mainSocket isConnected])
    {
        [dictParameter setObject:@"starttrip" forKey:Socket_Request_Type];
        [dictParameter setObject:UDUserId forKey:Socket_Requester_Id];
        AppDel.dicSocketSend = [NSMutableDictionary new];
        AppDel.dicSocketSend = [dictParameter mutableCopy];
        [AppDel sendRequest];
        return;
    }
    
    [objShare callWebservice:@"starttrip" inputParameters:dictParameter completion:^(id response) {
//        NSLog(@"%@",response);
        [self starttripRequestResponse:response];
    }];
}
-(void)callWebServiceforDriverArrivedNotify
{
    self.lblArrived.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_arrived", @"Localizable", [AppDel bundle], nil)];

    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    
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
    
    if([AppDel.mainSocket isConnected])
    {
        [dictParameter setObject:@"driverarrivednotify" forKey:Socket_Request_Type];
        [dictParameter setObject:UDUserId forKey:Socket_Requester_Id];
        AppDel.dicSocketSend = [NSMutableDictionary new];
        AppDel.dicSocketSend = [dictParameter mutableCopy];
        [AppDel sendRequest];
        return;
    }
    
    [objShare callWebservice:@"driverarrivednotify" inputParameters:dictParameter completion:^(id response) {

        [self driverarrivednotifyRequestResponse:response];
    }];
    
}
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    CLLocation *currentLocation = [locations lastObject];
////    NSMutableDictionary *dict= [NSMutableDictionary new];
////    [dict setObject:[NSNumber numberWithDouble:currentLocation.coordinate.latitude]  forKey:@"lat"];
////    [dict setObject:[NSNumber numberWithDouble:currentLocation.coordinate.longitude] forKey:@"lon"];
////    [dict setObject:[NSNumber numberWithDouble:currentLocation.course] forKey:@"course"];
////    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"coordinates"];
////    [[NSUserDefaults standardUserDefaults]synchronize];
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:0.5];
//    marker.rotation = currentLocation.course;
//    marker.position = currentLocation.coordinate;
//    [mapView_ animateToLocation:currentLocation.coordinate];
//    [CATransaction commit];
//    CLLocation *locationManager = [CLLocation new];
//    
//}


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
    NSMutableDictionary *dict= [NSMutableDictionary new];
    [dict setObject:latitude forKey:@"lat"];
    [dict setObject:longitude forKey:@"lon"];
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0];
   // marker.rotation = myLoc.course;
    [mapView_ animateToLocation:myLoc.coordinate];
    [CATransaction commit];
    
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"coordinates_start"];
    [[NSUserDefaults standardUserDefaults]synchronize];
//    NSLog(@"distance:%f",distance);
//    NSLog(@"%@",[dict valueForKey:@"lat"]);
//    NSLog(@"%@",[dict valueForKey:@"lon"]);

}

#pragma mark Button Clicked Method

- (IBAction)btnCallCancelClicked:(UIButton *)sender {
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == 0){
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",strPhoneNo]];
        [[UIApplication sharedApplication] openURL:phoneUrl];
        lblPhoneNumber.text = [NSString stringWithFormat:@"+%@",strPhoneNo];
        _viewAlert.hidden = true;
        viewCall.hidden = true;
    }else{
        _viewAlert.hidden = true;
        viewCall.hidden = true;
    }
}


- (IBAction)btnCallCustomer:(id)sender {
   /* NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",strPhoneNo]];
//    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
//        [[UIApplication sharedApplication] openURL:phoneUrl];
//    }
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//        [alert show];
//    }
    [[UIApplication sharedApplication] openURL:phoneUrl];*/
    _viewAlert.hidden = false;
    viewCall.hidden = false;
    [self.view bringSubviewToFront:_viewAlert];
    [self.view bringSubviewToFront:viewCall];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnYesNopress:(id)sender {
    if([sender tag]==0)
    {
        _viewAlert.hidden=true;
        _viewReqcancel.hidden=true;
        [self callWebServiceforRejectRequest];
    }
    if([sender tag]==1)
    {
        _viewAlert.hidden=true;
        _viewReqcancel.hidden=true;
    }
}

- (IBAction)btnStartTripPressed:(id)sender {
    
    if([_btnTrip.titleLabel.text isEqualToString:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_arrived", @"Localizable", [AppDel bundle], nil)]])
    {
        [self callWebServiceforDriverArrivedNotify];
    }
    else
    {
        /*[objShare.timerupdateUserlatLong invalidate];
        objShare.timerupdateUserlatLong = nil;*/ //18/10/2016
        
        [self callWebServiceforStartTrip];
//        [objShare.locationManager stopUpdatingLocation]; // 26/09/2016 Nipa
    }
}

- (IBAction)btnCancelPressed:(id)sender {
    _viewAlert.hidden=false;
    _viewReqcancel.hidden=false;
    _viewReqcancel.alpha=1.0;
    [self.view bringSubviewToFront:_viewAlert];
    [self.view bringSubviewToFront:_viewReqcancel];
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
        NSURL *imageURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"driver_image"]];
        [cell.imgUser sd_setImageWithURL:imageURL];
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height /2;
        cell.imgUser.layer.masksToBounds = YES;
        cell.lblName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"driver_name"];
        NSLog(@"CurLocation Arrived : %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"CurLocation"]);
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
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
        //28/12/2016
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
//        }else if(indexPath.row == 6){
//            if (dictResponse != nil){
//                cell.lblName.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"cell_msg_comment", @"Localizable", [AppDel bundle], nil)];
//                cell.imgUser.image = [UIImage imageNamed:@"comment-icon.png"];
//                cell.lblLocation.text = [dictResponse valueForKey:@"comment"];
//            }
//        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        return UITableViewAutomaticDimension;
    }else if(indexPath.row == 1){
        return 64;
    }else{
        return UITableViewAutomaticDimension;
    }
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        return UITableViewAutomaticDimension;
    }else if(indexPath.row == 1){
        return 64;
    }else{
        return UITableViewAutomaticDimension;
    }
}
@end
