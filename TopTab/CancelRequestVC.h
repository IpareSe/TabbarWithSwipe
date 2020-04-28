//
//  CancelRequestVC.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 04/08/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CancelRequestVC : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *btnOption;
@property (strong, nonatomic) IBOutlet UIButton *btnOpt1;
- (IBAction)CancelRequest:(id)sender;
- (IBAction)btnBackPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *txtViewReject;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblCustomer;
@property (strong, nonatomic) IBOutlet UILabel *lblOther;


@end
