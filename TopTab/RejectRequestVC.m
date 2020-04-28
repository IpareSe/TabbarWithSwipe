

#import "RejectRequestVC.h"
#import "AppConstant.h"
#import "SharedClass.h"
#import <AFNetworking.h>
#import "HomeVC.h"
#import "SharedClass.h"

@interface RejectRequestVC ()
{
    NSString *strReason;
}

@end

@implementation RejectRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    strReason=@"I have another trip.";
    _textViewComment.hidden = TRUE;
     _btnOpt1.layer.borderWidth = 1.0f;
    _btnOpt1.layer.cornerRadius = _btnOpt1.frame.size.height /2;
    _btnOpt1.layer.masksToBounds = YES;
    _btnOpt1.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnOpt2.layer.borderWidth = 1.0f;
    _btnOpt2.layer.cornerRadius = _btnOpt2.frame.size.height /2;
    _btnOpt2.layer.masksToBounds = YES;
    _btnOpt2.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnOpt3.layer.borderWidth = 1.0f;
    _btnOpt3.layer.cornerRadius = _btnOpt3.frame.size.height /2;
    _btnOpt3.layer.masksToBounds = YES;
    _btnOpt3.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _textViewComment.layer.borderWidth = 1.0f;
    _btnSubmit.layer.cornerRadius=5.0f;
    _textViewComment.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self setLanguage];
}
-(void)setLanguage
{
    self.lblTitle.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_whyreject", @"Localizable", [AppDel bundle], nil)];
    [_btnSubmit setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_submit", @"Localizable", [AppDel bundle], nil)] forState:UIControlStateNormal];
    self.lblTripAnother.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_trip", @"Localizable", [AppDel bundle], nil)];
    self.lblTaxi.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_taxiready", @"Localizable", [AppDel bundle], nil)];
    self.lblOther.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_other", @"Localizable", [AppDel bundle], nil)];
    self.textViewComment.text=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_type_here", @"Localizable",[AppDel bundle], nil)];
}

- (void) textViewDidBeginEditing:(UITextView *) textView
{
    [textView setText:@""];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)callWebServiceforRejectRequest
{
    
    [objShare showLoadingWithText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_loading", @"Localizable", [AppDel bundle], nil)]];NSMutableDictionary *dictParameter=[[NSMutableDictionary alloc]init];
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
    [dictParameter setObject:strReason forKey:@"reason"];
    //[dictParameter setObject:_textViewComment.text forKey:@"comment"];
    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@reasonrequest",SERVER_URL] parameters:dictParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
     
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                              NSLog(@"%@",responseObject);
                                              
                                              
                                              if([[responseObject objectForKey:@"response_status"] integerValue]==1)
                                              {
                                                  [objShare hideLoading];
                                                  
                                                  DisplaySimpleAlert([NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"lbl_rejected_sucess", @"Localizable", [AppDel bundle], nil)])
                                                  
                                                  
                                                  if(objShare.isBackgroundNotif)
                                                  {
                                                       [SharedClass objSharedClass].selectSettingsOption(0);
//                                                      HomeVC *rvc = (HomeVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
//                                                      [self.navigationController pushViewController:rvc animated:YES];
                                                  }
                                                  else
                                                  {
                                                      //HomeVC *rvc = (HomeVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
                                                      
                                                     /* for (UIViewController *controller in self.navigationController.viewControllers)
                                                      {
                                                          if ([controller isKindOfClass:[HomeVC class]])
                                                          {
                                                              [self.navigationController popToViewController:controller animated:YES];
                                                              break;
                                                          }
                                                      }*/
                                                      
                                                      [SharedClass objSharedClass].selectSettingsOption(0);
                                                  }
                                                  
                                              }
                                              else {
                                                  [objShare hideLoading];
                                                //  DisplayAlert(@"Your Email Address Not Registered.")
                                              }
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              [objShare hideLoading];
                                              DisplaySimpleAlert(TRY_AGAIN_MSG)
                                          }];
    //[op start];
}
- (IBAction)btnRejectRequestPress:(id)sender {
    if([objShare isNetworkReachable])
    {
        if(_btnOpt1.selected == 1)
        {
            strReason=@"I have another trip.";
        }
        else if(_btnOpt2.selected == 1)
        {
            strReason=@"My Taxi Not Ready";
        }
        else if(_btnOpt3.selected == 1)
        {
            strReason=[NSString stringWithFormat:@"%@",_textViewComment.text];
        }
        [self callWebServiceforRejectRequest];
    }
    else
    {
        AlertViewNetwork
    }
}
- (IBAction)backButtonPress:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)RejectRequest:(id)sender {
    if([sender tag]==0)
    {
        _textViewComment.hidden = TRUE;
        _btnOpt1.selected=1;
        _btnOpt2.selected=0;
        _btnOpt3.selected=0;
         //strReason=@"I have another trip.";
    }
    if([sender tag]==1)
    {
        _textViewComment.hidden = TRUE;
        _btnOpt1.selected=0;
        _btnOpt2.selected=1;
        _btnOpt3.selected=0;
       // strReason=@"My Taxi Not Ready";
    }
    if([sender tag]==2)
    {
        _textViewComment.hidden = FALSE;
        _btnOpt1.selected=0;
        _btnOpt2.selected=0;
        _btnOpt3.selected=1;
    }
}
@end
