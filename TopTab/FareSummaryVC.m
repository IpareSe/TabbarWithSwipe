//
//  FareSummaryVC.m
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 04/08/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import "FareSummaryVC.h"
#import "HomeVC.h"
#import "AppConstant.h"
#import "DriverScheduleVC.h"
#import <AFNetworking.h>
#import "SharedClass.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HCSStarRatingView.h"

@interface FareSummaryVC (){
    
    IBOutlet UILabel *lblStatMin;
    IBOutlet UILabel *lblValMin;
    IBOutlet UILabel *lblBaseCharges;
    IBOutlet UILabel *lblStatBase;
    IBOutlet UILabel *lblStatKm;
    IBOutlet UILabel *lblValKm;
    IBOutlet UILabel *lblValWait;
    IBOutlet UILabel *lblStatWait;
    IBOutlet UILabel *lblStatMeterPrice;
    IBOutlet UILabel *lblValMeterPrice;
    IBOutlet UILabel *lblValMaxPrice;
    IBOutlet UILabel *lblStatMaxPrice;
    IBOutlet UILabel *lblStatTotal;
    IBOutlet UIImageView *imgUser;
    IBOutlet UIImageView *imgCar;
    IBOutlet UILabel  *lblName;
    IBOutlet UILabel  *lblCar;
    IBOutlet UILabel  *lblNumberPlate;
    IBOutlet HCSStarRatingView  *viewRating;
    IBOutlet UILabel *lblUserLoc;
}

@end

@implementation FareSummaryVC
@synthesize dictFareSummary;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lblStartLoc.text=[dictFareSummary valueForKey:@"pickup_address"];
    self.lblEndLoc.text=[dictFareSummary valueForKey:@"destination_address"];
    self.lblTotPrice.text=[NSString stringWithFormat:@"€ %.2f",[[dictFareSummary valueForKey:@"actual_payment"] floatValue]];

    lblStatKm.text = [dictFareSummary valueForKey:@"Kilometer"];
    lblValKm.text = [NSString stringWithFormat:@"€ %.2f",[[dictFareSummary valueForKey:@"km_price"] floatValue]];
    lblStatMin.text = [dictFareSummary valueForKey:@"Duration"];
    lblValMin.text = [NSString stringWithFormat:@"€ %.2f",[[dictFareSummary valueForKey:@"Minute"] floatValue]];
    lblBaseCharges.text = [NSString stringWithFormat:@"€ %.2f",[[dictFareSummary valueForKey:@"Starting_Tarriff"]floatValue]];
    lblValWait.text = [NSString stringWithFormat:@"€ %.2f",[[dictFareSummary valueForKey:@"hold_charge"]floatValue]];
    
    lblStatWait.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_Hold_charges", @"Localizable", [AppDel bundle], nil)];
    lblStatBase.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_Starting_Tarriff", @"Localizable", [AppDel bundle], nil)];
    lblStatMeterPrice.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_meterPrice", @"Localizable", [AppDel bundle], nil)];
    lblStatMaxPrice.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_maxfarescreen", @"Localizable", [AppDel bundle], nil)];
    lblStatTotal.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_total_amount", @"Localizable", [AppDel bundle], nil)];    
    
    lblUserLoc.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurLocation"];
    lblValMeterPrice.text = [NSString stringWithFormat:@"€ %.2f",[[dictFareSummary valueForKey:@"meter_price"] floatValue]];
    lblValMaxPrice.text = [NSString stringWithFormat:@"€ %.2f",[[dictFareSummary valueForKey:@"max_fare"] floatValue]];
    
    NSURL *imageURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"driver_image"]];
    [imgUser sd_setImageWithURL:imageURL];
    imgUser.layer.cornerRadius = imgUser.frame.size.height /2;
    imgUser.layer.masksToBounds = YES;
    lblName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"driver_name"];
    viewRating.allowsHalfStars = true;
    viewRating.value = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ratting"] floatValue];
    
    NSURL *carURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"car_image"]];
    [imgCar sd_setImageWithURL:carURL];
    lblCar.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"car_type"];
    
    //Hotel

//   lblNumberPlate.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"car_number"];
    
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
    [self setLanguage];
}

-(void)setLanguage
{
      self.lblTitle.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_fare_sum", @"Localizable", [AppDel bundle], nil)];
      [_btnTrip setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_new_trip", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
      [_btnOnline setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_online", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
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
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    [dictParameter setObject:status forKey:@"status"];
    [dictParameter setObject:lang forKey:@"language"];
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@gooffline",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                              NSLog(@"%@",responseObject);
                                              
                                              if([[responseObject objectForKey:@"response_status"] integerValue]==1)
                                              {
                                                  if([[responseObject objectForKey:@"message"] isEqualToString:@"Successfully offline."]){
                                                      DriverScheduleVC *rvc = (DriverScheduleVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"DriverScheduleVC"];
                                                      [self.navigationController pushViewController:rvc animated:YES];
                                                      [AppDel socketDisconnect];

                                                      
                                                  }
                                                  else
                                                  {
                                                      [AppDel socketConnect];
                                                      [AppDel connectUserToSocket];
                                                      [SharedClass objSharedClass].selectSettingsOption(0);
                                                  }
                                                  [objShare hideLoading];
                                                   //[SharedClass objSharedClass].selectSettingsOption(0);
                                                 
                                                  
                                              }
                                              else {
                                                  [objShare hideLoading];
                                              }
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              [objShare hideLoading];
                                              DisplaySimpleAlert(TRY_AGAIN_MSG)
                                          }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnOnlinePress:(id)sender {
    //Offline
    [self callWebserviceforSwichMode:@"2"];
}

- (IBAction)btnNewTripPress:(id)sender {
    //Online
    [self callWebserviceforSwichMode:@"1"];
    
}


@end
