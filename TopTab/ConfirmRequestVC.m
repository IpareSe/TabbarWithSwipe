//
//  ConfirmRequestVC.m
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import "ConfirmRequestVC.h"
#import "ArrivingVC.h"
#import "RejectRequestVC.h"
#import "TestView.h"
#import "AppConstant.h"
#import "SharedClass.h"
#import <AFNetworking/AFNetworking.h>
#import "SharedClass.h"
#import "HomeVC.h"
#import "NSDate+Utilities.h"
#import <SDWebImage/UIImageView+WebCache.h>




@interface ConfirmRequestVC ()<CLLocationManagerDelegate,GMSMapViewDelegate>
{
    TestView *m_testView;
    NSTimer* m_timer;
    UIButton *button;
    GMSMapView *mapView_;
    CLLocationManager * locationmanager;
    //  CLLocation *crnLoc;
    NSNumber *longitude;
    NSNumber *latitude;
    GMSMarker *marker;
    NSString *strCurrLoc;
    NSArray *routes;
    CLLocationCoordinate2D point;
    NSString *strChekNoti;
    BOOL advanceTripFlag;
    
    AVAudioPlayer *backgroundMusicPlayer;
    
}
@end

@implementation ConfirmRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    __btnAccept.layer.cornerRadius=25.0f;
//Play Music Sound
    NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"Sound-2" ofType:@"mp3"];
    NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
    NSError *error;
    backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    [backgroundMusicPlayer prepareToPlay];
    
    imgUser.layer.cornerRadius = imgUser.frame.size.height /2;
    imgUser.layer.masksToBounds = YES;
    imgUser.layer.borderWidth = 3.0f;
    imgUser.layer.borderColor=[textColor(81,81,80)CGColor];
    [self callWebServiceforArrivingRequest];
   

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(acceptrequestObserver:) name:@"acceptrequest" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rejectrequestObserver:) name:@"rejectrequest" object:nil];
    
    [objShare hideLoading];
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
    _viewAlert.hidden=true;
    _viewReqcancel.hidden=true;
    
    [self.view addSubview:_viewAlert];
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor=[UIColor colorWithRed:127.0/255.0 green:121.0/255.0 blue:104.0/255.0 alpha:0.7];
    strChekNoti=[[NSUserDefaults standardUserDefaults]objectForKey:@"checkNotification"];

    //23/11/2016 live
    if(isiPad){
        if(strChekNoti){
//            button.frame =CGRectMake(self.view.center.x - 135,self.view.center.y - 135, 150, 150);
            button.frame =CGRectMake(0, 0, 150, 150);
            button.layer.cornerRadius = button.frame.size.height /2;
            button.layer.masksToBounds = YES;
            button.hidden=false;
            button.center = CGPointMake(self.view.frame.size.width  / 2,
                                             self.view.frame.size.height / 2);
            [self.view addSubview:button];
            
            m_testView = [[TestView alloc]init];
//            m_testView = [[TestView alloc] initWithFrame:CGRectMake(self.view.center.x - 145,self.view.center.y - 145, 165, 165)];
            m_testView = [[TestView alloc] initWithFrame:CGRectMake(0,0, 165, 165)];

            m_testView.center = CGPointMake(self.view.frame.size.width  / 2,
                                        self.view.frame.size.height / 2);
        }
        
    }else{
        if(IS_IPHONE_4)
        {
            if(strChekNoti){
                button.frame =CGRectMake(80,152, 150, 150);
                button.layer.cornerRadius = button.frame.size.height /2;
                button.layer.masksToBounds = YES;
                button.hidden=false;
                [self.view addSubview:button];
                
                m_testView = [[TestView alloc]init];
                m_testView = [[TestView alloc] initWithFrame:CGRectMake(75,146, 165, 165)];
            }
        }
        
        else if(IS_IPHONE_5){
            if(strChekNoti){
                button.frame =CGRectMake(83,224, 150, 150); //78
                button.layer.cornerRadius = button.frame.size.height /2;
                button.layer.masksToBounds = YES;
                button.hidden=false;
                [self.view addSubview:button];
                m_testView = [[TestView alloc]init];
                m_testView = [[TestView alloc] initWithFrame:CGRectMake(75,220, 165, 165)];
            }
            
        }
        
        else if(IS_IPHONE_6P)
        {
            if(strChekNoti)
            {
                button.frame =CGRectMake(125,284, 150, 150); //123
                button.layer.cornerRadius = button.frame.size.height /2;
                button.layer.masksToBounds = YES;
                button.hidden=false;
                [self.view addSubview:button];
                m_testView = [[TestView alloc]init];
                m_testView = [[TestView alloc] initWithFrame:CGRectMake(120,280, 165, 165)];
                
            }
        }
        
        else
        {
            if(strChekNoti)
            {
                button.frame =CGRectMake(109,276, 150, 150);
                button.layer.cornerRadius = button.frame.size.height /2;
                button.layer.masksToBounds = YES;
                button.hidden=false;
                [self.view addSubview:button];
                m_testView = [[TestView alloc]init];
                m_testView = [[TestView alloc] initWithFrame:CGRectMake(104,270, 165, 165)];
            }
        }

    }
    
    m_testView.percent = AppDel.timeLoader;
    if(strChekNoti)
    {
        m_timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(decrementSpin) userInfo:nil repeats:YES];
    }
    [self performSelector:@selector(displayMap) withObject:nil afterDelay:0.3];
    [self setLanguage];
    
}

- (void)acceptrequestObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self acceptRequestResponse:requestInfo];
}

- (void)rejectrequestObserver:(NSNotification *) notification
{
    NSDictionary* requestInfo = notification.userInfo;
    [self rejectRequestResponse:requestInfo];
}

-(void)acceptRequestResponse:(NSDictionary *)responce
{
    if([[responce objectForKey:@"response_status"] integerValue]==1)
    {
        [objShare hideLoading];
        [self callWebServiceforArrivingRequestFromConfirmRequest];
        
    }
    else {
        [objShare hideLoading];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                            message:[responce objectForKey:@"message"]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        alertView.tag = 9999;
        [alertView show];
    }

}

-(void)rejectRequestResponse:(NSDictionary *)responseObject
{
    if([[responseObject objectForKey:@"response_status"] integerValue]==1){
        [objShare hideLoading];
        //        DisplaySimpleAlert(@"Request Rejected..")
        RejectRequestVC *rvc = (RejectRequestVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"RejectRequestVC"];
        [self.navigationController pushViewController:rvc animated:YES];
    }
    else {
        [objShare hideLoading];
    }
}


-(void)setLanguage{
    [_btnYes setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_yes", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [__btnAccept setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_accept", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [_btnNo setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_no", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    [_btnReject setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_reject", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    self.lblSure.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_sure", @"Localizable", [AppDel bundle], nil)];
    self.lblCancelReq.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_cancle_req", @"Localizable", [AppDel bundle], nil)];
     self.lblTitle.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_confirm", @"Localizable", [AppDel bundle], nil)];

}

- (void)decrementSpin
{
    // If we can decrement our percentage, do so, and redraw the view
    if (m_testView.percent > 0)
    {
        [backgroundMusicPlayer play];
        m_testView.percent = m_testView.percent - 1;
        [m_testView setNeedsDisplay];
//        NSLog(@"%f",m_testView.percent);

    }
    else
    {
        [backgroundMusicPlayer stop];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:APP_NAME message:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_miss_accept_request", @"Localizable", [AppDel bundle], nil)] preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  if(advanceTripFlag == TRUE)
                                                                  {
                                                                      advanceTripFlag = FALSE;
                                                                      [SharedClass objSharedClass].selectSettingsOption(0);
                                                                  }
                                                                  else
                                                                  {
                                                                      [SharedClass objSharedClass].selectSettingsOption(0);
                                                                     
                                                                  }

                                                              }];
        
        [alertController addAction:ok];

        [self presentViewController:alertController animated:YES completion:nil];
        
        
        [m_timer invalidate];
        m_timer = nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 9999){
        [SharedClass objSharedClass].selectSettingsOption(0);
//        HomeVC *rvc = (HomeVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
//        [self.navigationController pushViewController:rvc animated:YES];
    }else{
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:@"Ok"])
        {
            if(advanceTripFlag == TRUE)
            {
                advanceTripFlag = FALSE;
                [SharedClass objSharedClass].selectSettingsOption(0);
//                HomeVC *rvc = (HomeVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
//                [self.navigationController pushViewController:rvc animated:YES];
                
            }
            else
            {
                [SharedClass objSharedClass].selectSettingsOption(0);
//                HomeVC *rvc = (HomeVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
//                [self.navigationController pushViewController:rvc animated:YES];
            }
            
        }

    }
}

/*-(void)callWebServiceforTimeoutRequest{
    [objShare showLoadingWithText:@"Loading"];
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    //dataImgPic = UIImagePNGRepresentation(_imgProfle.image);
    //  [dictParameter setObject:UDUserId forKey:@"iUserId"];
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    if(CustomerId)
    {
        [dictParameter setObject:CustomerId forKey:@"userid"];
    }
    if(RequestId)
    {
        [dictParameter setObject:RequestId forKey:@"request_id"];
    }
    if(CarId)
    {
        [dictParameter setObject:CarId forKey:@"car_id"];
    }
    [dictParameter setObject:@"english" forKey:@"language"];

    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@timeoutrequest",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
     
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              NSLog(@"%@",responseObject);
                                              
                                              
                                              if([[responseObject objectForKey:@"response_status"] integerValue]==1)
                                              {
                                                  [objShare hideLoading];
                                                   PopToback
                                                }
                                              else {
                                                  [objShare hideLoading];
                                                  
                                                  //   DisplayAlert(@"Your Email Address Not Registered.")
                                              }
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              
                                          }];
}*/

-(void)displayMap
{
    NSDictionary *dict= [[NSUserDefaults standardUserDefaults]objectForKey:@"coordinates"];
    latitude=[dict objectForKey:@"lat"];
    longitude=[dict objectForKey:@"lon"];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[latitude floatValue]
                                                            longitude:[longitude floatValue]zoom:16];
    
    

    //23/11/2016 live
    
    if(isiPad){
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH, WINDOW_HEIGHT - 180) camera:camera];

    }else{
        if(IS_IPHONE_5)
        {
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH,360) camera:camera];
        }
        else if(IS_IPHONE_6P)
        {
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH,520) camera:camera];
        }
        else if(IS_IPHONE_4)
        {
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH,290) camera:camera];
            
        }
        else
        {
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,77, WINDOW_WIDTH,460) camera:camera];
        }
    }
    

    
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    [self.view addSubview: mapView_];
    if(strChekNoti){
    [self.view bringSubviewToFront:button];
    [self.view addSubview: m_testView];
    [self.view bringSubviewToFront:m_testView];
    }
    marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
    marker.icon=[UIImage imageNamed:@"user-pin.png"];
    marker.map = mapView_;
}

#pragma mark ***** found issue here

-(void)callWebservice:(NSString *)strUrl inputParameters:(NSMutableDictionary *)dictParameter completion:(void(^)(id response))completion{
    if ([objShare isNetworkReachable]) {
//        [objShare showLoadingWithText:@"Loading..."];
        
        NSString *strRequetURL = [NSString stringWithFormat:@"%@%@",SERVER_URL,strUrl];
        [[AFHTTPRequestSerializer serializer]setTimeoutInterval:30];
        
        NSLog(@"Request - %@",strRequetURL);
        NSLog(@"Parameter - %@",strUrl);
        
        [[AFHTTPRequestOperationManager manager] POST:strRequetURL parameters:dictParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [objShare hideLoading];
            NSLog(@"Parameter - %@",responseObject);
            completion(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error - %@",error);
            [objShare hideLoading];
            PopToback
            //DisplaySimpleAlert(@"Please Try Again")
        }];
    }
    else
    {
        AlertViewNetwork;
    }
}

-(NSDate *)StringFromDate:(NSString *)DateLocal
{
    NSString *dateStr =DateLocal;
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [dateFormatter1 dateFromString:dateStr];
    if(IS_IPHONE_6P)
    {
        date1 = [date1 dateByAddingTimeInterval:60];
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


-(NSDate *)getDateFromDateString :(NSString *)dateString {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss a"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}


#pragma mark  ***** allWebServiceforArrivingRequestFromConfirmRequest
-(void)callWebServiceforArrivingRequestFromConfirmRequest
{
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    if(CustomerId)
    {
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
    [objShare callWebservice:@"arrivingscreen" inputParameters:dictParameter completion:^(id response)
    {
        // NSLog(@"%@",response);
        
        //05/06/2017 Nipa
        [SharedClass objSharedClass].isCurrentTripOn = true;
        if([[response objectForKey:@"response_status"] integerValue]==1)
        {

            NSDate *todayDate = [NSDate date];
            NSLog(@"*/*/*/ TODAY - %@", todayDate);
            NSDate *pickUpDate = [self StringFromDate:[response valueForKey:@"pick_date"]];
            
            NSLog(@"*/*/*/ PICKUP DATE - %@", pickUpDate);
            
            if(![pickUpDate isToday])
            {
                [objShare hideLoading];
                
                advanceTripFlag = TRUE;
                
                NSString *gmtDateString = [response valueForKey:@"pick_date"];
                
                NSDateFormatter *df = [NSDateFormatter new];
                [df setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                NSDate *mydate = [df dateFromString:gmtDateString];
                df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
                [df setDateFormat: @"HH:mm aa"];
                NSString *formattedDate = [df stringFromDate:mydate];
                                
                NSString *loc =[NSString stringWithFormat:@"%@",[response valueForKey:@"pickup_address"]];
                
                NSString *alertMessage = [NSString stringWithFormat:@"%@ %@ %@ %@", [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_thaks", @"Localizable", [AppDel bundle], nil)], formattedDate, [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_From", @"Localizable", [AppDel bundle], nil)], loc];
                
                // Comment by MANTHAN 12/oct/2017 As no future trip Display Accept/Reject Screen.
                
//                UIAlertView *alert_notification = [[UIAlertView alloc] initWithTitle:APP_NAME
//                                                                             message:alertMessage
//                                                                            delegate:self
//                                                                   cancelButtonTitle:@"Ok"
//                                                                   otherButtonTitles:nil, nil];
                
//                [alert_notification show];
            }
            else
            {
                [objShare hideLoading];
                ArrivingVC *rvc = (ArrivingVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"ArrivingVC"];
                [self.navigationController pushViewController:rvc animated:YES];
            }
            
        }
        else {
            [objShare hideLoading];
            DisplayAlert(@"Try again")
        }
    }];
}


#pragma mark  ***** AcceptRequest API CAll

-(void)callWebServiceforAcceptRequest{
    
    //acceptrequest
    
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    //dataImgPic = UIImagePNGRepresentation(_imgProfle.image);
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    if(CustomerId){
        [dictParameter setObject:CustomerId forKey:@"userid"];
    }
    if(RequestId){
        [dictParameter setObject:RequestId forKey:@"request_id"];
    }
    [dictParameter setObject:@"1" forKey:@"flag"];
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
    
    //06/02/2018
    objShare.isOutSideHagArea = false;
    [[NSUserDefaults standardUserDefaults]setObject:@"false" forKey:@"isOutSideHagArea"];
    [[NSUserDefaults standardUserDefaults] synchronize];


    if([AppDel.mainSocket isConnected])
    {
        [dictParameter setObject:@"acceptrequest" forKey:Socket_Request_Type];
        [dictParameter setObject:UDUserId forKey:Socket_Requester_Id];
        NSLog(@"Accept Request Param - %@", dictParameter);
        AppDel.dicSocketSend = [NSMutableDictionary new];
        AppDel.dicSocketSend = [dictParameter mutableCopy];
        [AppDel sendRequest];
        return;
    }
    //06/02/2018
    [self callWebservice:@"acceptrequest" inputParameters:dictParameter completion:^(id response) {
        [self acceptRequestResponse:response];
    }];
}

-(void)callWebServiceforRejectRequest{
    
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    //dataImgPic = UIImagePNGRepresentation(_imgProfle.image);
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
    [dictParameter setObject:@"405" forKey:@"status"];
   
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
    
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%Reject Request - ",responseObject);
        [self rejectRequestResponse:responseObject];

    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [objShare hideLoading];
        DisplaySimpleAlert(TRY_AGAIN_MSG)
    }];
}


- (IBAction)btnYesNopress:(id)sender {
   
    if([sender tag]==0){
        [m_timer invalidate];
         m_timer=nil;
        _viewAlert.hidden=true;
        _viewReqcancel.hidden=true;
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"checkNotification"];
        strChekNoti=[[NSUserDefaults standardUserDefaults]objectForKey:@"checkNotification"];
        if([objShare isNetworkReachable]){
            [self callWebServiceforRejectRequest];
        }
        else{
            DisplaySimpleAlert([NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_network_not_found", @"Localizable", [AppDel bundle], nil)])
        }
    }
    if([sender tag]==1){
        _viewAlert.hidden=true;
        _viewReqcancel.hidden=true;
    }
}

- (IBAction)btnAcceptPressed:(id)sender {
   // if(strChekNoti)
    [m_timer invalidate];
    [backgroundMusicPlayer stop];
    m_timer=nil;
    if([objShare isNetworkReachable]){
        [self callWebServiceforAcceptRequest];
    }
    else{
        DisplaySimpleAlert([NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_network_not_found", @"Localizable", [AppDel bundle], nil)])
    }
}

- (IBAction)btnRejectPressed:(id)sender {
    _viewAlert.hidden=false;
    _viewReqcancel.hidden=false;
    _viewReqcancel.alpha=1.0;
    [self.view bringSubviewToFront:_viewAlert];
    [self.view bringSubviewToFront:_viewReqcancel];
}

-(void)callWebServiceforArrivingRequest
{
    //[objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
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
    [objShare callWebservice:@"arrivingscreen" inputParameters:dictParameter completion:^(id response) {
        if([[response objectForKey:@"response_status"] integerValue]==1)
        {
            NSURL *carURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"car_image"]];
            [imgCar sd_setImageWithURL:carURL];
            NSURL *imageURL = [NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] valueForKey:@"MyUserProfile"] valueForKey:@"profilepic"]];
            [imgUser sd_setImageWithURL:imageURL];
            _lblPickUpLocation.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"driver_name"];
            lblCar.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"car_type"];
            
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
            
            NSString *tempString = [NSString stringWithFormat:@"(%@ away)",[response objectForKey:@"pick_dest_km"]];
            _lblDistance.text=tempString;
        }
        else {
            //[objShare hideLoading];
            //DisplayAlert(@"Try again")
        }
        
    }];
}



@end
