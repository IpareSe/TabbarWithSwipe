//
//  FareSummaryVC.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 04/08/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FareSummaryVC : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *btnTrip;
@property (strong, nonatomic) IBOutlet UIButton *btnOnline;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) NSMutableDictionary *dictFareSummary;
@property (strong, nonatomic) IBOutlet UILabel *lblStartLoc;
@property (strong, nonatomic) IBOutlet UILabel *lblEndLoc;
@property (strong, nonatomic) IBOutlet UILabel *lblTotPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalKm;
@property (strong, nonatomic) IBOutlet UILabel *lblPerKm;
@property (strong, nonatomic) IBOutlet UILabel *lblMinCharge;
@property (strong, nonatomic) IBOutlet UILabel *lblWaitingChrg;

@end
