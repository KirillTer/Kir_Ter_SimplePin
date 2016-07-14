//
//  MapViewController.m
//  Kir_Ter_SimplePin
//
//  Created by Admin on 7/14/16.
//  Copyright © 2016 KirillTer. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "FBClient.h"
#import "DBManager.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *userMap;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic)  MKUserLocation* currentLocation;
@property (nonatomic, strong) id <MKAnnotation> currentPin;
@property (strong, nonatomic) Pins* myCurrentPin;
@property (assign, nonatomic) BOOL userLocationShown;



@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userMap.delegate =  self;
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    NSString* userID = [FBClient currentClient].currentUserID;
    NSArray* savedPins = [[DBManager sharedManager] getPinsWithUserID:userID];
    if ([savedPins count] >= 1) {
        for(Pins* pin in savedPins){
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([pin.latitude doubleValue], [pin.longitude doubleValue]);
            [self addPinToMapWithCoordinates:coordinate];
        }
    }
}

#pragma mark -- MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *) userLocation {
    self.currentLocation = userLocation;
    if(self.userLocationShown){
        return;
    }
    self.userLocationShown = YES;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1600, 1600);
    [self.userMap setRegion:[self.userMap regionThatFits:region] animated:YES];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    CLLocationCoordinate2D newCoordinate = view.annotation.coordinate;
    self.currentPin = view.annotation;
    self.myCurrentPin = [[DBManager sharedManager] getCurrentPin:newCoordinate];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState{
    
    if (newState == MKAnnotationViewDragStateEnding){
        
        CGPoint dropPoint = CGPointMake(annotationView.center.x, annotationView.center.y);
        CLLocationCoordinate2D newCoordinate = [self.userMap convertPoint:dropPoint toCoordinateFromView:annotationView.superview];
        [annotationView.annotation setCoordinate:newCoordinate];
        self.myCurrentPin.longitude = [NSNumber numberWithDouble:newCoordinate.longitude];
        self.myCurrentPin.latitude = [NSNumber numberWithDouble:newCoordinate.latitude];
        [[DBManager sharedManager] saveContext];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.draggable = YES;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [self deletePinButton];
    self.currentPin = annotation;
    return annotationView;
}

#pragma mark -- helped Methods

- (UIButton*) deletePinButton{
    UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton addTarget:self action:@selector(deletePin) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteButton setBackgroundColor:[UIColor grayColor]];
    [deleteButton setFrame:CGRectMake(0, 0, 60, 30)];
    
    return deleteButton;
}

- (void) deletePin{
    
    [self.userMap removeAnnotation:self.currentPin];
    [[DBManager sharedManager] deletePin:self.currentPin];
}

- (void) addPinToMapWithCoordinates:(CLLocationCoordinate2D) coordinates{
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coordinates;
    point.title = @"The Location";
    point.subtitle = @"Subtitle";
    [self.userMap addAnnotation:point];
}

#pragma mark -- actions

- (IBAction)addPinAction:(UIBarButtonItem *)sender {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.location.coordinate, 800, 800);
    [self.userMap setRegion:[self.userMap regionThatFits:region] animated:YES];
    [self addPinToMapWithCoordinates:self.currentLocation.location.coordinate];
    NSString* userID = [FBClient currentClient].currentUserID;
    [[DBManager sharedManager] savePin:self.currentLocation.location.coordinate withUserID:userID];
}

- (IBAction)logOutAction:(UIBarButtonItem *)sender {
    __weak MapViewController* weakSelf = self;
    [[FBClient currentClient] loggOut:^{    //to do: show activiti indicator
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
}

@end
