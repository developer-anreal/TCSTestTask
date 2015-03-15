//
//  SpotsRequestOperation.m
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import "SpotsRequestOperation.h"
#import "PartnerSpot+Addition.h"

NSString * const kPartnersSpotTemplateURL = @"https://api.tcsbank.ru/v1/deposition_points?latitude=%f&longitude=%f&radius=%ld";

@interface SpotsRequestOperation()
@property (nonatomic, assign) NSInteger radius;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation SpotsRequestOperation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(NSInteger)radius store:(PartnersStore *)partnersStore {
  if (self = [super initWithStore:partnersStore]) {
    self.radius = radius;
    self.coordinate = coordinate;
  }

  return self;
}

- (NSURL *)requestURL {
  return [NSURL URLWithString:
          [NSString stringWithFormat:kPartnersSpotTemplateURL,
           self.coordinate.latitude, self.coordinate.longitude, self.radius]];
}

- (void)parseReceivedData:(NSData *)data {
  NSError *error = nil;
  NSArray *raw =
  [NSJSONSerialization JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                    error:&error][@"payload"];
  
  if (error != nil || raw == nil || self.isCancelled) {
    return;
  }
  
  for (NSDictionary *p in raw) {
    if (self.isCancelled) {
      return;
    }
    
    if (p[@"partnerName"] == nil || p[@"location"] == nil) {
      continue;
    }
    
    [PartnerSpot createOrUpdateSpotFrom:p inContext:self.context];
  }
}

@end
