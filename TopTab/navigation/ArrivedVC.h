//
//  ArrivedVC.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRouteController.h"

@interface ArrivedVC : UIViewController{
    NSMutableArray *_coordinates;
    GMSPolyline *_polyline;
    GMSMarker *_markerStart;
    GMSMarker *_markerFinish;
    LRouteController *_routeController;
    
}
@property (strong, nonatomic) IBOutlet UIView *viewAddressInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblSource;
@property (strong, nonatomic) IBOutlet UILabel *lblDestination;

@property (strong, nonatomic) IBOutlet UIButton *btnCustomer;
@property (strong, nonatomic) IBOutlet UIButton *btnTrip;
- (IBAction)btnStartTripPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewReqcancel;
- (IBAction)btnCancelPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *viewAlert;
@property (strong, nonatomic) IBOutlet UIButton *btnYes;
@property (strong, nonatomic) IBOutlet UIButton *btnNo;
@property (strong, nonatomic) IBOutlet UILabel *lblArrived;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;

@property (strong, nonatomic) IBOutlet UILabel *lblSure;
@property (strong, nonatomic) IBOutlet UILabel *lblCancelReq;
@property (assign, nonatomic) BOOL  isStartTripButton;
@end
