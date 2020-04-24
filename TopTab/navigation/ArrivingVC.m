//
//  ArrivingVC.m
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import "ArrivingVC.h"
#import "ArrivedVC.h"
#import "CancelRequestVC.h"
#import "AppConstant.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SharedClass.h"
#import "AppConstant.h"
#import <AFNetworking.h>
#import "HomeVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoCell.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface ArrivingVC ()<CLLocationManagerDelegate,GMSMapViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSTimer* m_timer;
    UIButton *button;
    IBOutlet GMSMapView *mapView_;
    CLLocationManager * locationmanager;
    NSNumber *longitude;
    NSNumber *latitude;
    GMSMarker *marker;
    NSString *strCurrLoc;
    NSArray *routes;
    CLLocationCoordinate2D point;
    float driverUpdateLocationTimer;
    NSDictionary  *dictResponse;
    IBOutlet NSLayoutConstraint *constantHeightTbl;
    IBOutlet UIScrollView *scrollView;
    IBOutlet NSLayoutConstraint *constantBottomScroll;
    int dataCount;
    NSMutableArray  *arrLatLong;
    int increCount;

}

@end

@implementation ArrivingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    dataCount = 1;
    increCount = 0;
    driverUpdateLocationTimer = 3.0;// Timer Variable to update DRIVER LOCATION //10
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.btnYes.bounds byRoundingCorners:(UIRectCornerBottomLeft) cornerRadii:CGSizeMake(25.0, 25.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
//    self.btnYes.layer.mask = maskLayer;
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.btnNo.bounds byRoundingCorners:(UIRectCornerBottomRight) cornerRadii:CGSizeMake(25.0, 25.0)];
    CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
    maskLayer1.frame = self.view.bounds;
    maskLayer1.path  = maskPath1.CGPath;
//    self.btnNo.layer.mask = maskLayer1;
//    _viewReqcancel.layer.cornerRadius=25.0f;
//    _btnArriving.layer.cornerRadius=25.0f;
    _viewAlert.hidden=true;
    _viewReqcancel.hidden=true;
    [self.view addSubview:_viewAlert];
    
    increCount =0;
    arrLatLong = [[NSMutableArray alloc]init];

    
    [self setLanguage];
    // Do any additional setup after loading the view.
}

- (void)arrivedObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self arrivedAPIResponse:requestInfo];
    
}

-(void)arrivedAPIResponse:(NSDictionary *)responce
{
    if([[responce objectForKey:@"response_status"] integerValue]==1){
        [objShare hideLoading];
        
        ArrivedVC *rvc = (ArrivedVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"ArrivedVC"];
        rvc.isStartTripButton = false;
        [self.navigationController pushViewController:rvc animated:YES];
    }
    else {
        [objShare hideLoading];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rejectrequestObserver:) name:@"rejectrequest" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arrivedObserver:) name:@"arrived" object:nil];
    [self displayMap];
    if([objShare isNetworkReachable]){
        [self callWebServiceforArrivingRequest];
    }
    else{
        AlertViewNetwork
    }
   
    if(_isFutureTrip)
    {
        _btnBack.hidden = FALSE;
        int MinuteDifference = [self daysBetween:_futureTrip_date and:[NSDate date]];
         // MANTHAN DESAI NEED TO CHNAGE HERE |*| need to  go minus
        if(MinuteDifference > 150 || MinuteDifference < -60 ) //Nipa (minute - 15)
        {
            constantBottomScroll.constant = 0;
            _btnArriving.hidden = TRUE;
        }else{
            constantBottomScroll.constant = 53;
            _btnArriving.hidden = FALSE;
        }
    }
    else
    {
         _btnBack.hidden = TRUE;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)rejectrequestObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self rejectRequestResponse:requestInfo];
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


-(int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2
{
    NSDate* date1 = dt1;
    NSDate* date2 = dt2;
    NSTimeInterval distanceBetweenDates1 = [date1 timeIntervalSinceDate:date2];
    //double secondsInAnHour = 3600;
    double secondsInMinute = 60;
    //NSInteger hoursBetweenDates1 = distanceBetweenDates1 / secondsInAnHour;
    NSInteger minutesBetweenDates = distanceBetweenDates1 / secondsInMinute;
    return minutesBetweenDates;
}

-(void)setLanguage{
    
    [_btnYes setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_yes", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [_btnNo setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_no", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [_btnCancel setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_cancel", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    self.lblSure.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_sure", @"Localizable", [AppDel bundle], nil)];
    self.lblCancelReq.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_cancle_req", @"Localizable", [AppDel bundle], nil)];
    [_btnArriving setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_arrivenow", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    self.lblArriving.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_arriving", @"Localizable", [AppDel bundle], nil)];
}

-(void)displayMap{
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:objShare.applatitude
                                                            longitude:objShare.applongitude zoom:16];
    mapView_.camera = camera;
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    mapView_.settings.myLocationButton = YES;
    [self.view bringSubviewToFront:_viewAddressInfo];
    marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(objShare.applatitude, objShare.applongitude);
    marker.icon=[UIImage imageNamed:@"user-pin.png"];
    marker.map = mapView_;
}

-(float)getDistanceInKm:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
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

#pragma mark WebServices
-(void)callWebServiceforArrivingRequest
{
//    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
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
    NSLog(@"Arrivingparameter%@",dictParameter);
    [objShare callWebservice:@"arrivingscreen" inputParameters:dictParameter completion:^(id response) {
//        NSLog(@"Arriving%@",response);
        dictResponse = response;
        //06/02/2018
        if([[response objectForKey:@"FixRate"] integerValue]==1)
        {
            objShare.isOutSideHagArea = true;
            [[NSUserDefaults standardUserDefaults]setObject:@"true" forKey:@"isOutSideHagArea"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"isout:%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"isOutSideHagArea"]);
        }else{
            objShare.isOutSideHagArea = false;
            [[NSUserDefaults standardUserDefaults]setObject:@"false" forKey:@"isOutSideHagArea"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if([[response objectForKey:@"response_status"] integerValue]==1)
        {
            marker = [[GMSMarker alloc] init];
            
//            marker.position = CLLocationCoordinate2DMake([[[response valueForKey:@"destination_latlong"] valueForKey:@"lat"] floatValue],[[[response valueForKey:@"destination_latlong"] valueForKey:@"lon"] floatValue]); // Nipa 27/09/2016
            //marker.flat = YES;
            
            marker.position = CLLocationCoordinate2DMake(objShare.applatitude, objShare.applongitude);
            
            if([[response valueForKey:@"car_passenger"] isEqualToString:@"4"]){
                marker.icon=[UIImage imageNamed:@"trackcar"];
            }else{
                marker.icon=[UIImage imageNamed:@"trackvan"];
            }
            
            //    marker.icon=[UIImage imageNamed:@"car-icon_dark.png"];
//            marker.icon=[UIImage imageNamed:@"green-pin.png"];
            
            marker.map = mapView_;
            _lblSource.text=[response objectForKey:@"pickup_address"];
             NSString *tempString = [NSString stringWithFormat:@"(%@ away)",[response objectForKey:@"pick_dest_km"]];
            _lblDistance.text=tempString;
            
//            NSString *tempString = [NSString stringWithFormat:@"%@ (%@ away)",[response objectForKey:@"pickup_address"],[response objectForKey:@"pick_dest_km"]];
//             _lblSource.text=tempString;
            
            NSString *strComment=[response objectForKey:@"comment"];
            if(strComment)
            {
                _lblDestination.text=strComment;
            }
            if([[response objectForKey:@"Type trip"]isEqualToString:@""])
            {
                dataCount = 7;
            }
            else
            {
                dataCount = 8;
            }
            //dataCount = 7;
            _lblPhoneNo.text=[response objectForKey:@"mobile"];
            _lblCustomerName.text = [response objectForKey:@"passenger"];
            [objShare hideLoading];
            [_tblArriving reloadData];
            _tblArriving.userInteractionEnabled = YES;
            [_tblArriving updateConstraintsIfNeeded];
            [_tblArriving layoutIfNeeded];
            constantHeightTbl.constant = _tblArriving.contentSize.height+10;
            dispatch_async(dispatch_get_main_queue(), ^{
                constantHeightTbl.constant = _tblArriving.contentSize.height+10;
            });
        }
        else
        {
            [objShare hideLoading];
            DisplayAlert(@"Try again")
        }

    }];
}

-(void)callWebServiceforArriveNow{
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
    
    if([AppDel.mainSocket isConnected])
    {
        [dictParameter setObject:@"arrived" forKey:Socket_Request_Type];
        [dictParameter setObject:UDUserId forKey:Socket_Requester_Id];
        AppDel.dicSocketSend = [NSMutableDictionary new];
        AppDel.dicSocketSend = [dictParameter mutableCopy];
        [AppDel sendRequest];
        return;
    }
    
    [objShare callWebservice:@"arrived" inputParameters:dictParameter completion:^(id response) {
//        NSLog(@"%@",response);
        [self arrivedAPIResponse:response];
    }];
  
}

-(void)callWebServiceforRejectRequest
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
    [dictParameter setObject:@"503" forKey:@"status"];
   
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
//         NSLog(@"%@",responseObject);
        #pragma mark ==== i am working here
         [self rejectRequestResponse:responseObject];
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [objShare hideLoading];
        DisplaySimpleAlert(TRY_AGAIN_MSG)
        
    }];
}

#pragma mark Button Clicked Method
- (IBAction)btnYesNopress:(id)sender {
    if([sender tag]==0)
    {
        _viewAlert.hidden=true;
        _viewReqcancel.hidden=true;
        if([objShare isNetworkReachable]){
            [self callWebServiceforRejectRequest];
        }
        else{
            AlertViewNetwork
        }
    }
    if([sender tag]==1)
    {
        _viewAlert.hidden=true;
        _viewReqcancel.hidden=true;
    }
}

-(IBAction)btnCancelPressed:(id)sender
{
    _viewAlert.hidden=false;
    _viewReqcancel.hidden=false;
    _viewReqcancel.alpha=1.0;
    [self.view bringSubviewToFront:_viewAlert];
    [self.view bringSubviewToFront:_viewReqcancel];
   
}

- (IBAction)btnArrivingNowPressed:(id)sender {
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
    if(userId != nil){
        if([objShare isNetworkReachable]){

            [self callWebServiceforArriveNow];
        }
        else{
            AlertViewNetwork
        }
    }
   
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
        
       
            cell.imgUser.layer.borderWidth = 2.0f;
            cell.imgUser.layer.borderColor=[textColor(81,81,80)CGColor];
        
            if (dictResponse != nil){
                cell.lblName.text = [dictResponse valueForKey:@"driver_name"];
                cell.lblLocation.text = [dictResponse valueForKey:@"pickup_address"];

            }else{
                cell.lblName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"driver_name"];
                cell.lblLocation.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurLocation"];
            }
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

        }else if (indexPath.row == 1){
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
//                    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if (indexPath.row == 0){
        return UITableViewAutomaticDimension;
    }else if(indexPath.row == 1){
        return 64;
    }
    else{
        return UITableViewAutomaticDimension;
    }

}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0){
        return UITableViewAutomaticDimension;
    }else if(indexPath.row == 1){
        return 64;
    }
    else{
        return UITableViewAutomaticDimension;
    }

}


#pragma mark *** timer call to start update driver location


-(double)DegreeBearing:(CLLocation *)A B:(CLLocation *)B{
    double dlon = [self ToRad:B.coordinate.longitude - A.coordinate.longitude];
    double dPhi = log(tan([self ToRad:B.coordinate.latitude] / 2 + M_PI / 4) / tan([self ToRad:A.coordinate.latitude] / 2 + M_PI / 4));
    if(fabs(dlon) > M_PI){
        dlon = (dlon > 0) ? (dlon - 2*M_PI) : (2*M_PI + dlon);
    }
    return [self ToBearing:(atan2(dlon, dPhi))];
}
-(double)ToRad:(double)degrees{
    return degrees*(M_PI/180);
}
-(double)ToBearing:(double)radians{
    return [self ToDegrees:radians] + 360  % 360;
}
-(double)ToDegrees:(double)radians{
    return radians * 180 / M_PI;
}
#pragma mark lacation manager start Updating location

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
    double  direction = myLoc.course;
    NSMutableDictionary *dict= [NSMutableDictionary new];
    [dict setObject:latitude forKey:@"lat"];
    [dict setObject:longitude forKey:@"lon"];
    [dict setObject:[NSString stringWithFormat:@"%f",direction] forKey:@"course"];
    [mapView_ animateToLocation:myLoc.coordinate];
    [arrLatLong addObject:dict];
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"coordinates"];
    [[NSUserDefaults standardUserDefaults]synchronize];
//    NSLog(@"distance:%f",distance);
    if (marker)
    {
        marker.map = nil;
        marker = nil;
    }
    marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
//    marker.icon=[UIImage imageNamed:@"Drivercar_icon_4s.png"];
    
    
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
    
    marker.groundAnchor = CGPointMake(0.5, 0.5);
    marker.flat = YES;
    marker.map = mapView_;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)btnBackClick:(id)sender {
    
    if (_isFutureTrip)
    {
        _btnBack.hidden = FALSE;
        [self.navigationController popViewControllerAnimated:YES];
        _isFutureTrip = FALSE;
    }
}
@end
