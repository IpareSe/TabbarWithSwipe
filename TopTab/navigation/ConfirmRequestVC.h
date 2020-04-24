//
//  ConfirmRequestVC.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 30/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <AVFoundation/AVFoundation.h>

@interface ConfirmRequestVC : UIViewController <AVAudioPlayerDelegate>
{
    NSMutableArray *_coordinates;
    GMSPolyline *_polyline;
    GMSMarker *_markerStart;
    GMSMarker *_markerFinish;
    IBOutlet UIImageView *imgCar;
    IBOutlet UILabel *lblCar;    
    IBOutlet UILabel *lblNumberPlate;
    IBOutlet UIImageView *imgUser;
    
}

@property (weak, nonatomic) IBOutlet UILabel *lblPickUpLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;

@property (strong, nonatomic) IBOutlet UIButton *_btnAccept;

- (IBAction)btnAcceptPressed:(id)sender;

- (IBAction)btnRejectPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewReqcancel;
@property (strong, nonatomic) IBOutlet UIView *viewAlert;
@property (strong, nonatomic) IBOutlet UIButton *btnYes;
@property (strong, nonatomic) IBOutlet UIButton *btnNo;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnReject;
@property (strong, nonatomic) IBOutlet UIButton *btnAccept;
@property (strong, nonatomic) IBOutlet UILabel *lblSure;
@property (strong, nonatomic) IBOutlet UILabel *lblCancelReq;

@end
