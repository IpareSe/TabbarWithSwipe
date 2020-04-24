//
//  ArrivingVC.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRouteController.h"
#import "ArrivingUserInfoCell.h"
#import "ArrivinglocationCell.h"

@interface ArrivingVC : UIViewController{
    NSMutableArray *_coordinates;
    GMSPolyline *_polyline;
    GMSMarker *_markerStart;
    GMSMarker *_markerFinish;
    LRouteController *_routeController;

}
@property (strong, nonatomic) IBOutlet UILabel *lblPhoneNo;
@property (strong, nonatomic) IBOutlet UIView *viewAddressInfo;
@property (strong, nonatomic) IBOutlet UITableView *tblArriving;
@property (strong, nonatomic) IBOutlet UIButton *btnArriving;
- (IBAction)btnArrivingNowPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewReqcancel;
- (IBAction)btnCancelPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewAlert;
@property (strong, nonatomic) IBOutlet UIButton *btnYes;
@property (strong, nonatomic) IBOutlet UIButton *btnNo;
@property (strong, nonatomic) IBOutlet UILabel *lblArriving;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;

@property (strong, nonatomic) IBOutlet UILabel *lblSure;
@property (strong, nonatomic) IBOutlet UILabel *lblCancelReq;
@property (strong, nonatomic) IBOutlet UILabel *lblSource;
@property (strong, nonatomic) IBOutlet UILabel *lblDestination;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
- (IBAction)btnBackClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerName;

//@property (strong, nonatomic) NSString *futureTrip_userId;
//@property (strong, nonatomic) NSString *futureTrip_requestId;
@property (strong, nonatomic) NSDate *futureTrip_date;

@property BOOL isFutureTrip;


@end
