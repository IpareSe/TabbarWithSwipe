//
//  AppDelegate.h
//  HollandTaxiDriver
//
//  Created by SOTSYS039 on 27/07/15.
//  Copyright (c) 2015 keyur bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderContainerVC.h"
#import "NSObject+DelayBlock.h"
#import "GCDAsyncSocket.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,GCDAsyncSocketDelegate>
{
    NSTimer *socketTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SliderContainerVC *slideContainer;
@property (strong, nonatomic) NSBundle *bundle;
@property (strong, nonatomic) NSArray *img;
@property (assign) double timeLoader;
@property (strong, nonatomic) NSString *strRequestId,*userId;

@property (nonatomic,strong)Reachability *internetReachable;
@property (nonatomic,strong)Reachability *hostReachable;
@property (nonatomic,strong)UILabel *lblPopup;
//Socket
@property (nonatomic,strong)NSMutableDictionary *dicSocketSend;
@property (nonatomic,strong)NSMutableDictionary *dicSocketReceive;
@property (nonatomic,strong)GCDAsyncSocket *mainSocket;
@property (assign) NSString* strIPAddress;
@property(nonatomic)UInt16 portNum;

-(void)CheckInternetConnecivity;

#pragma mark - Socket Methods
- (void) socketConnect;
- (void)socketDisconnect;
- (void)sendRequest;
-(void)connectUserToSocket;
-(void)disconnectUserToSocket;

@end

