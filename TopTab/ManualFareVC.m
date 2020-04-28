//
//  ManualFareVC.m
//  HollandTaxiDriver
//
//  Created by SOTSYS0156 on 4/15/16.
//  Copyright © 2016 keyur bhalodiya. All rights reserved.
//

#import "ManualFareVC.h"
#import "AppDelegate.h"
#import "SharedClass.h"
#import "AppConstant.h"
#import "WebserviceManager.h"
#import "HomeVC.h"
#import "FareSummaryVC.h"


@interface ManualFareVC ()

@end

@implementation ManualFareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLanguage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setLanguage
{
    self.txtAmount.placeholder = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_Enter_Amount_placeholder", @"Localizable", [AppDel bundle], nil)];
    
    _lblTripAmount.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_trip_amount",@"Localizable", [AppDel bundle], nil)];
    
    [_btnSubmit setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_submit",@"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    
     _lblTitle.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_trip_amount",@"Localizable", [AppDel bundle], nil)];
    
}
-(void)CallWebserviceForEndTrip
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
    [dictParameter setObject:_txtAmount.text forKey:@"price"];
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
    //    if(strTotalHoldTime)
    //    {
    //        [dictParameter setObject:strTotalHoldTime forKey:@"hold_time"];
    //    }
//    NSLog(@"%@",dictParameter);
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@endtrip",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
//         NSLog(@"%@",responseObject);
         
         if([[responseObject objectForKey:@"response_status"] integerValue]==1)
         {
             [objShare hideLoading];
             //[self callWebserviceforSwichMode:@"1"];
             [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"RequestId"];
             [[NSUserDefaults standardUserDefaults]synchronize];
             
             FareSummaryVC *rvc = (FareSummaryVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"FareSummaryVC"];
             rvc.dictFareSummary=responseObject;
             [self.navigationController pushViewController:rvc animated:YES];

         }
         else
         {
             [objShare hideLoading];
             DisplayAlertWithTitle(responseObject[@"message"], APP_NAME)
         }
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [objShare hideLoading];
         DisplaySimpleAlert(TRY_AGAIN_MSG)
     }];
    
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
                                                  [objShare hideLoading];
  
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSubmitPressed:(id)sender
{
    [self CallWebserviceForEndTrip];
    
}
@end
