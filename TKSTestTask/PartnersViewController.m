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
#import <MapKit/MapKit.h>

@interface PartnerAnnotation: NSObject<MKAnnotation> {
  CLLocationCoordinate2D _coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@implementation PartnerAnnotation
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
  if (self = [super init]) {
    _coordinate = coordinate;
  }
  return self;
}
@end

@interface PartnersViewController () <MKMapViewDelegate>
@property (weak) IBOutlet MKMapView *map;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) PartnersStore *partnersStore;
@property (strong) NSArray *partnerAnnotations;
@end

@implementation PartnersViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.partnersStore = [[PartnersStore alloc] init];
  self.operationQueue = [[NSOperationQueue alloc] init];
  PartnersRequestOperation *op = [[PartnersRequestOperation alloc] initWithStore:self.partnersStore];
  op.completionBlock = ^{
    NSLog(@"Requested");
  };
  [self.operationQueue addOperation:op];
//  PartnersRequest *pr = [[PartnersRequest alloc] init];
//  __weak typeof(self) weakSelf = self;
//  [pr loadSpotsAtPoint:CLLocationCoordinate2DMake(55.755786, 37.617633) radius:1000 completion:^(id o) {
//    __strong typeof(weakSelf) strongSelf = weakSelf;
//    if (!strongSelf) {
//      return;
//    }
//    
//    [strongSelf.map removeAnnotations:strongSelf.partnerAnnotations];
//    
//    assert([o isKindOfClass:[NSArray class]]);
//    NSMutableArray *res = [NSMutableArray array];
//    for (NSDictionary *p in o) {
//      assert(p[@"location"] != nil);
//      assert([p[@"location"] isKindOfClass:[NSDictionary class]]);
//      assert(p[@"location"][@"latitude"] != nil);
//      assert(p[@"location"][@"longitude"] != nil);
//      NSDictionary *locationDict = p[@"location"];
//      
//      CGFloat lat = [locationDict[@"latitude"] floatValue];
//      CGFloat lng = [locationDict[@"longitude"] floatValue];
//      
//      PartnerAnnotation *annotation = [[PartnerAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng)];
//      [res addObject:annotation];
//      
//      [strongSelf.map addAnnotation:annotation];
//    }
//  }];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
  MKPinAnnotationView *pin =
    [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
  return pin;
}

@end