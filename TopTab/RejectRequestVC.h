//
//  RejectRequestVC.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RejectRequestVC : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

- (IBAction)backButtonPress:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnOpt1;
@property (strong, nonatomic) IBOutlet UIButton *btnOpt2;
@property (strong, nonatomic) IBOutlet UIButton *btnOpt3;
- (IBAction)RejectRequest:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *lblTripAnother;
@property (strong, nonatomic) IBOutlet UILabel *lblTaxi;
@property (strong, nonatomic) IBOutlet UILabel *lblOther;
@property (strong, nonatomic) IBOutlet UITextView *textViewComment;

@end
