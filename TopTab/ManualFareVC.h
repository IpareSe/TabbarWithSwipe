//
//  ManualFareVC.h
//  HollandTaxiDriver
//
//  Created by SOTSYS0156 on 4/15/16.
//  Copyright © 2016 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualFareVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblTripAmount;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
- (IBAction)btnSubmitPressed:(id)sender;

@end
