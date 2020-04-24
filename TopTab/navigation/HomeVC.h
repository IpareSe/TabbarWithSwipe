//
//  ViewController.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 27/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "SliderContainerVC.h"
#import "LRouteController.h"

@interface HomeVC : UIViewController <BRSliderDelegate,MKMapViewDelegate,CLLocationManagerDelegate,MKAnnotation>
{
    NSMutableArray *_coordinates;
    LRouteController *_routeController;
    GMSPolyline *_polyline;
    GMSMarker *_markerStart;
    GMSMarker *_markerFinish;
    BOOL isSetDestination;
    NSTimer *timerupdateUserlatLong;
    float GeoAngle;
    
    IBOutlet UIImageView *imgCar;
    
    IBOutlet UILabel *lblCar;
    
    IBOutlet UILabel *lblNumberPlate;
}
@property (strong, nonatomic) SliderContainerVC *BRSlider;

@property (strong, nonatomic) IBOutlet UILabel *lblHome;
@property (strong, nonatomic) IBOutlet UIButton *btnOffline;
@property (strong, nonatomic) IBOutlet UILabel *lblDriverName;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (nonatomic, retain) NSString *address;
@property (weak, nonatomic) IBOutlet UIImageView *star0;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (strong, nonatomic) IBOutlet UIImageView *imgUser;



@end

