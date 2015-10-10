//
//  DrawLineViewController.m
//  officialDemo2D
//
//  Created by PC on 15/7/15.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "DrawLineViewController.h"
#import "MAMutablePolyline.h"
#import "MAMutablePolylineRenderer.h"

@interface DrawLineViewController()

@property (nonatomic, strong) MAMutablePolyline *mutableLine;

@property (nonatomic, strong) MAMutablePolylineRenderer *render;

@end


@implementation DrawLineViewController

#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAMutablePolyline class]])
    {
        MAMutablePolylineRenderer *renderer = [[MAMutablePolylineRenderer alloc] initWithOverlay:overlay];
        self.render = renderer;
        return renderer;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    NSLog(@"update location");
    if (!updatingLocation)
    {
        return;
    }
    
    if ((userLocation.location.horizontalAccuracy < 80.0) && (userLocation.location.horizontalAccuracy > 0))
    {
        [self.mutableLine appendPoint: MAMapPointForCoordinate(userLocation.location.coordinate)];
        
//        [self.mapView setVisibleMapRect:[self.mutableLine showRect] animated:YES];
        
        [self.render setNeedsDisplay];
    }
    
}

#pragma mark - Action

- (void)addBtnTap
{
    double randomX = (double)(arc4random() % 100) / 1000;
    double randomY = (double)(arc4random() % 100) / 1000;
    
    MAMapPoint mapPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(self.mapView.centerCoordinate.latitude + randomX, self.mapView.centerCoordinate.longitude + randomY));
    [self.mutableLine appendPoint:mapPoint];
    [self.mapView setVisibleMapRect:[self.mutableLine showRect] animated:YES];

    [self.render setNeedsDisplay];
}

#pragma mark - Initialization

- (void)initOverlay
{
    self.mutableLine = [[MAMutablePolyline alloc] initWithPoints:@[]];
}

- (void)initButton
{
    CGRect rect = self.view.bounds;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addBtn.frame = CGRectMake(rect.size.width*0.7, rect.size.height*0.75, 90, 40);
    addBtn.backgroundColor = [UIColor blueColor];
    [addBtn addTarget:self action:@selector(addBtnTap) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addBtn];
}

- (void)initMapViewLocation
{
    self.mapView.showsUserLocation = true;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.distanceFilter = 10;
    self.mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initOverlay];
    
    [self initMapViewLocation];
    
    [self initButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.mapView addOverlay:self.mutableLine];
}



@end
