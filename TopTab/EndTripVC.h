//
//  EndTripVC.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRouteController.h"
@interface EndTripVC : UIViewController
{
    NSMutableArray *_coordinates;
    GMSPolyline *_polyline;
    GMSMarker *_markerStart;
    GMSMarker *_markerFinish;
    LRouteController *_routeController;
    
    IBOutlet UILabel *lblStatMeter;
    IBOutlet UILabel *lblValMeter;
    IBOutlet UILabel *lblStatTime;
    IBOutlet UILabel *lblValTime;
    IBOutlet UILabel *lblStatDistance;
    IBOutlet UILabel *lblValDistance;
    IBOutlet UILabel *lblStatMax;
    IBOutlet UILabel *lblValMax;
}
@property (strong, nonatomic) IBOutlet UIView *viewAddressInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblSource;
@property (strong, nonatomic) IBOutlet UILabel *lblDestination;
@property (strong, nonatomic) IBOutlet UIButton *btnTrip;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnHold;
@property (strong, nonatomic) IBOutlet UILabel *lblPhoneText;
@property (assign, nonatomic) BOOL isHoldBtn;
@property (strong, nonatomic) NSString  *strPicklat;
@property (strong, nonatomic) NSString  *strPicklon;
@property (strong, nonatomic) NSString  *strPassenger;
@property (strong, nonatomic) NSString  *strCarType;
@property (assign, nonatomic) BOOL isDesAddress;
@property (assign, nonatomic) float resduration;
@property (assign, nonatomic) float resminutes;
@property (assign, nonatomic) float reskillometers;
@property (strong, nonatomic) NSString *strMaxPriceN;
@property (strong, nonatomic) NSString *strMeterPriceN;
@property (assign, nonatomic) BOOL isKillAPI;


@end
