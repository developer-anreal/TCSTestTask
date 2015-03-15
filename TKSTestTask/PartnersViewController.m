//
//  PartnersViewController.m
//  TKSTestTask
//
//  Created by Anton Serov on 3/12/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import "PartnersViewController.h"
#import "PartnersRequest.h"
#import "PartnersRequestOperation.h"
#import "SpotsRequestOperation.h"
#import "PartnerSpot.h"
#import "Partner+Addition.h"
#import "NSManagedObject+Custom.h"
#import <MapKit/MapKit.h>

@interface SpotAnnotation: NSObject<MKAnnotation> {
  CLLocationCoordinate2D _coordinate;
  NSString *_info;
  NSString *_workHours;
  NSString *_address;
  NSString *_name;
  NSString *_id;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (instancetype)initWithSpot:(PartnerSpot *)spot;
@property (readonly) NSString *spotId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) UIImage *image;
@end

@implementation SpotAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
  if (self = [super init]) {
    _coordinate = coordinate;
  }
  return self;
}

- (instancetype)initWithSpot:(PartnerSpot *)spot {
  if (self = [self initWithCoordinate:
              CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue)]) {
    _name = [spot.partner.name copy];
    _info = [spot.addressInfo copy];
    _workHours = [spot.workHours copy];
    _address = [spot.fullAddress copy];
    _id = spot.objectIDStringRepresentation;
    if (spot.partner.image != nil) {
      _image = spot.partner.image;
    }
    _title = _name;
    _subtitle = [NSString stringWithFormat:@"%@, %@", _address, _workHours];
  }
  
  return self;
}

- (NSString *)spotId {
  return _id;
}

@end

@interface PartnersViewController ()
  <MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate>

@property (weak) IBOutlet MKMapView *map;
@property (nonatomic, strong, readonly) NSFetchedResultsController *spots;
@end

@implementation PartnersViewController {
  PartnersStore *_partnersStore;
  NSOperationQueue *_operationQueue;
  CLLocationManager *_locationManager;
  PartnersRequestOperation *_loadPartnersOperation;
  SpotsRequestOperation *_loadSpotsOperation;
  NSFetchedResultsController *_spots;
  NSMutableDictionary *_displayedAnnotations;
}

- (NSFetchedResultsController *)spots {
  if (_spots != nil) {
    return _spots;
  }
  
  NSString *predicateFormat = @"(latitude BETWEEN {%f, %f}) AND (longitude BETWEEN {%f, %f})";
  CLLocationCoordinate2D center = self.map.region.center;
  MKCoordinateSpan span = self.map.region.span;
  float minLat = center.latitude - span.latitudeDelta / 2.f;
  float maxLat = center.latitude + span.latitudeDelta / 2.f;
  float minLng = center.longitude - span.longitudeDelta / 2.f;
  float maxLng = center.longitude + span.longitudeDelta / 2.f;
  NSFetchRequest *spotsRequest = [[NSFetchRequest alloc] initWithEntityName:@"PartnerSpot"];
  spotsRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"latitude" ascending:YES]];
  spotsRequest.predicate =
    [NSPredicate predicateWithFormat:predicateFormat, minLat, maxLat, minLng, maxLng];

  _spots =
    [[NSFetchedResultsController alloc] initWithFetchRequest:spotsRequest
      managedObjectContext:_partnersStore.mainManagedObjectContext
      sectionNameKeyPath:nil cacheName:nil];
  _spots.delegate = self;
  
  return _spots;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.leftBarButtonItem =
    [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.map];
  
  _displayedAnnotations = [NSMutableDictionary dictionary];
  
  _partnersStore = [PartnersStore sharedInstance];
  
  _operationQueue = [[NSOperationQueue alloc] init];
  
  _loadPartnersOperation =
    [[PartnersRequestOperation alloc] initWithStore:_partnersStore];
  [_operationQueue addOperation:_loadPartnersOperation];
  
  _locationManager = [[CLLocationManager alloc] init];
  _locationManager.delegate = self;
  if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    [_locationManager requestWhenInUseAuthorization];
  }
}

- (IBAction)zoomIn:(id)sender {
  MKCoordinateRegion region = self.map.region;
  MKCoordinateSpan span;
  span.latitudeDelta = region.span.latitudeDelta / 2.;
  span.longitudeDelta = region.span.longitudeDelta / 2.;
  region.span = span;
  [self.map setRegion:region animated:YES];
}

- (IBAction)zoomOut:(id)sender {
  MKCoordinateRegion region = self.map.region;
  MKCoordinateSpan span;
  span.latitudeDelta = region.span.latitudeDelta * 2;
  span.longitudeDelta = region.span.longitudeDelta * 2;
  region.span = span;
  [self.map setRegion:region animated:YES];
}

- (void)reloadFetchRequest {
  _spots = nil;
  NSError *fetchError = nil;
  [self.spots performFetch:&fetchError];
  if (fetchError == nil) {
    for (PartnerSpot *spot in self.spots.fetchedObjects) {
      [self addAnnotationForPartnerSpot:spot];
    }
  } else {
    NSLog(@"%@", fetchError.localizedDescription);
  }
}

- (void)setupMap {
  MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, 300, 300);
  self.map.region = [self.map regionThatFits:region];
}

- (void)addAnnotationForPartnerSpot:(PartnerSpot *)spot {
  dispatch_queue_t background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
  dispatch_sync(background, ^{
    if (_displayedAnnotations[spot.objectIDStringRepresentation] == nil) {
      SpotAnnotation *annotation = [[SpotAnnotation alloc] initWithSpot:spot];
      _displayedAnnotations[spot.objectIDStringRepresentation] = spot;
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.map addAnnotation:annotation];
      });
    }
  });
}

- (void)removeAnnotationForPartnerSpot:(PartnerSpot *)spot {
  if (_displayedAnnotations[spot.objectIDStringRepresentation] != nil) {
    [self.map removeAnnotation:_displayedAnnotations[spot.objectIDStringRepresentation]];
  }
}

- (void)loadSpots {
  if (_loadSpotsOperation.executing || _loadSpotsOperation.ready) {
    [_loadSpotsOperation cancel];
  }
  CLLocationCoordinate2D coordinate = self.map.region.center;
  double radius = self.map.visibleMapRect.size.height / 2.;
  
  _loadSpotsOperation =
    [[SpotsRequestOperation alloc]
      initWithCoordinate:CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
      radius:radius
      store:_partnersStore];
  
  if (_loadPartnersOperation.executing || _loadPartnersOperation.ready) {
    [_loadSpotsOperation addDependency:_loadPartnersOperation];
  }
  
  _loadSpotsOperation.completionBlock = ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
  };
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [_operationQueue addOperation:_loadSpotsOperation];
}

- (void)removeInvisibleAnnotations {
  NSSet *visibleAnnotations = [self.map annotationsInMapRect:self.map.visibleMapRect];
  NSMutableSet *allAnnotations =
    [NSMutableSet setWithSet:[self.map annotationsInMapRect:MKMapRectWorld]];
  [allAnnotations minusSet:visibleAnnotations];
  dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    for (id<MKAnnotation> a in allAnnotations.allObjects) {
      if ([a isKindOfClass:[SpotAnnotation class]]) {
        [_displayedAnnotations removeObjectForKey:((SpotAnnotation *)a).spotId];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.map removeAnnotations:allAnnotations.allObjects];
        });
      }
    }
  });
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - MKMapViewDelegate impl

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
  if ([annotation isKindOfClass:[SpotAnnotation class]]) {
    static NSString *spotAnnotationViewId = @"pinId";
    MKAnnotationView *spotView;
    spotView = [mapView dequeueReusableAnnotationViewWithIdentifier:spotAnnotationViewId];
    
    if (spotView == nil) {
      spotView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                              reuseIdentifier:spotAnnotationViewId];
    }
    
    spotView.canShowCallout = YES;
    spotView.image = ((SpotAnnotation *)annotation).image;
    spotView.frame = CGRectMake(0, 0, 30, 30);
    
    return spotView;
  }
  return nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
  [_loadSpotsOperation cancel];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self reloadFetchRequest];
    [self loadSpots];
    [self removeInvisibleAnnotations];
  }
}

#pragma mark - CLLocationManagerDelegate impl

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [manager startUpdatingLocation];
    [self setupMap];
  } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {

  }
}

#pragma mark NSFetchedResultsControllerDelegate impl

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  switch (type) {
    
    case NSFetchedResultsChangeInsert:
      [self addAnnotationForPartnerSpot:anObject];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self removeAnnotationForPartnerSpot:anObject];
      break;
      
    default:
      break;
  }
}

@end