
//
//  DisplayViewController.m
//  iOS_2D_RecordPath
//
//  Created by PC on 15/8/3.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import "DisplayViewController.h"
#import "Record.h"

@interface DisplayViewController()<MAMapViewDelegate>

@property (nonatomic, strong) Record *record;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MAPointAnnotation *myLocation;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) double averageSpeed;

@property (nonatomic, assign) NSInteger currentLocationIndex;

@end


@implementation DisplayViewController


#pragma mark - Utility

- (void)showRoute
{
    if (self.record == nil || [self.record numOfLocations] == 0)
    {
        NSLog(@"invaled route");
    }
    
    MAPointAnnotation *startPoint = [[MAPointAnnotation alloc] init];
    startPoint.coordinate = [self.record startLocation].coordinate;
    startPoint.title = @"start";
    [self.mapView addAnnotation:startPoint];
    
    MAPointAnnotation *endPoint = [[MAPointAnnotation alloc] init];
    endPoint.coordinate = [self.record endLocation].coordinate;
    endPoint.title = @"end";
    [self.mapView addAnnotation:endPoint];
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:self.record.coordinates count:[self.record numOfLocations]];
    [self.mapView addOverlay:polyline];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    
    self.averageSpeed = [self.record totalDistance] / [self.record totalDuration];
}

#pragma mark - Interface

- (void)setRecord:(Record *)record
{
    _record = record;
}

#pragma mark - mapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if([annotation isEqual:self.myLocation]) {
        
        static NSString *annotationIdentifier = @"myLcoationIdentifier";
        
        MAAnnotationView *poiAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        poiAnnotationView.image = [UIImage imageNamed:@"aeroplane.png"];
        poiAnnotationView.canShowCallout = NO;
        
        return poiAnnotationView;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"lcoationIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        poiAnnotationView.animatesDrop = YES;
        poiAnnotationView.canShowCallout = YES;
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (MAOverlayRenderer*)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *renderer = [[MAPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 6.0;
        
        return renderer;
    }
    
    return nil;
}

#pragma mark - Action

- (void)actionPlayAndStop
{
    if (self.record == nil)
    {
        return;
    }
    
    self.isPlaying = !self.isPlaying;
    if (self.isPlaying)
    {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_stop.png"];
        if (self.myLocation == nil)
        {
            self.myLocation = [[MAPointAnnotation alloc] init];
            self.myLocation.title = @"AMap";
            self.myLocation.coordinate = [self.record startLocation].coordinate;
            
            [self.mapView addAnnotation:self.myLocation];
        }
        
        [self animateToNextCoordinate];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_play.png"];
        
        MAAnnotationView *view = [self.mapView viewForAnnotation:self.myLocation];
        
        if (view != nil)
        {
            [view.layer removeAllAnimations];
        }
    }
}

- (void)animateToNextCoordinate
{
    if (self.myLocation == nil)
    {
        return;
    }
    
    CLLocationCoordinate2D *coordinates = [self.record coordinates];
    if (self.currentLocationIndex == [self.record numOfLocations] )
    {
        self.currentLocationIndex = 0;
        [self actionPlayAndStop];
        return;
    }
    
    CLLocationCoordinate2D nextCoord = coordinates[self.currentLocationIndex];
    CLLocationCoordinate2D preCoord = self.currentLocationIndex == 0 ? nextCoord : self.myLocation.coordinate;
    
    double heading = [self coordinateHeadingFrom:preCoord To:nextCoord];
    CLLocationDistance distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(nextCoord), MAMapPointForCoordinate(preCoord));
    NSTimeInterval duration = distance / (self.averageSpeed * 100);
    
    [UIView animateWithDuration:duration
                     animations:^{
                        self.myLocation.coordinate = nextCoord;}
                     completion:^(BOOL finished){
                         self.currentLocationIndex++;
                         if (finished)
                         {
                             [self animateToNextCoordinate];
                         }}];
    MAAnnotationView *view = [self.mapView viewForAnnotation:self.myLocation];
    if (view != nil)
    {
        view.transform = CGAffineTransformMakeRotation((CGFloat)(heading/180.0*M_PI));
    }
}

- (double)coordinateHeadingFrom:(CLLocationCoordinate2D)head To:(CLLocationCoordinate2D)rear
{
    if (!CLLocationCoordinate2DIsValid(head) || !CLLocationCoordinate2DIsValid(rear))
    {
        return 0.0;
    }

    double delta_lat_y = rear.latitude - head.latitude;
    double delta_lon_x = rear.longitude - head.longitude;
    
    if (fabs(delta_lat_y) < 0.000001)
    {
        return delta_lon_x < 0.0 ? 270.0 : 90.0;
    }
    
    double heading = atan2(delta_lon_x, delta_lat_y) / M_PI * 180.0;
    
    if (heading < 0.0)
    {
        heading += 360.0;
    }
    return heading;
}

#pragma mark - Initialazation

- (void)initToolBar
{
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionPlayAndStop)];
    self.navigationItem.rightBarButtonItem = playItem;
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)initVariates
{
    self.isPlaying = NO;
    self.currentLocationIndex = 0;
    self.averageSpeed = 2;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Display";
    
    [self initMapView];
    
    [self initToolBar];
    
    [self showRoute];
    
    [self initVariates];
}

@end
