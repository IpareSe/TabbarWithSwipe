//
//  CancelRequestVC.m
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 04/08/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import "CancelRequestVC.h"
#import "AppConstant.h"
#import <AFNetworking.h>
#import "SharedClass.h"
#import "HomeVC.h"

@interface CancelRequestVC (){
    NSString *strReason;
}
@end

@implementation CancelRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    strReason=@"I couldn't find customer";
    _btnOption.layer.borderWidth = 1.0f;
    _btnOption.layer.cornerRadius = _btnOption.frame.size.height /2;
    _btnOption.layer.masksToBounds = YES;
    _btnOption.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnOpt1.layer.borderWidth = 1.0f;
    _btnOpt1.layer.cornerRadius = _btnOpt1.frame.size.height /2;
    _btnOpt1.layer.masksToBounds = YES;
    _btnOpt1.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _txtViewReject.layer.borderWidth = 1.0f;
    _btnSubmit.layer.cornerRadius=5.0f;
    _txtViewReject.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self setLanguage];
    // Do any additional setup after loading the view.
}

-(void)setLanguage{
    [_btnSubmit setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_submit", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    self.lblTitle.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_whycancel", @"Localizable", [AppDel bundle], nil)];
    self.lblCustomer.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_customer", @"Localizable", [AppDel bundle], nil)];
    self.lblOther.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_other", @"Localizable", [AppDel bundle], nil)];
     self.txtViewReject.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_type_here", @"Localizable", [AppDel bundle], nil)];
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    [textView setText:@""];
    //other awesome stuff here...
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)callWebServiceforRejectRequest{
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];
    NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
    [dictParameter setObject:UDUserId forKey:@"driver_userid"];
    
    if(CustomerId){
        [dictParameter setObject:CustomerId forKey:@"userid"];
    }
    if(RequestId){
        [dictParameter setObject:RequestId forKey:@"request_id"];
    }
    if(CarId){
        [dictParameter setObject:CarId forKey:@"car_id"];
    }
    [dictParameter setObject:@"0" forKey:@"flag"];
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
    [dictParameter setObject:strReason forKey:@"reject_reason"];
    [dictParameter setObject:_txtViewReject.text forKey:@"comment"];
    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@reasonrequest",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
        
    if([[responseObject objectForKey:@"response_status"] integerValue]==1){
        [objShare hideLoading];
        
        if(objShare.isBackgroundNotif)
        {
            
            HomeVC *rvc = (HomeVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
            [self.navigationController pushViewController:rvc animated:YES];
        }
        else
        {
            //HomeVC *rvc = (HomeVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
            for (UIViewController *controller in self.navigationController.viewControllers)
            {
                if ([controller isKindOfClass:[HomeVC class]])
                {
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
        }
    }
    else{
            [objShare hideLoading];
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (IBAction)CancelRequest:(id)sender {
    if([sender tag]==0){
        _btnOption.selected=1;
        _btnOpt1.selected=0;
        strReason=@"I couldn't find customer";
    }
    else{
        _btnOpt1.selected=1;
        _btnOption.selected=0;
        strReason=@"Other";
    }
}

- (IBAction)btnSubmitPressed:(id)sender {
    if([objShare isNetworkReachable]){
        [self callWebServiceforRejectRequest];
    }
    else{
        AlertViewNetwork
    }
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
