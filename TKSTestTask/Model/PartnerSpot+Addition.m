//
//  PartnerSpot+Addition.m
//  TKSTestTask
//
//  Created by Anton Serov on 3/14/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import "PartnerSpot+Addition.h"
#import "NSManagedObject+Custom.h"
#import "Partner+Addition.h"

@implementation PartnerSpot (Creation)

+ (PartnerSpot *)createOrUpdateSpotFrom:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
  Partner *partner = [Partner firstObjectWithPredicate:[NSPredicate predicateWithFormat:@"partnerId == %@", dict[@"partnerName"]] inContext:context];
  if (partner == nil) {
    return nil;
  }
  BOOL isNew = NO;
  PartnerSpot *spot =
    [PartnerSpot firstObjectWithPredicate:[NSPredicate predicateWithFormat:@"fullAddress == %@", dict[@"fullAddress"]] inContext:context];
  if (spot == nil) {
    spot =
      [[PartnerSpot alloc] initWithEntity:
          [NSEntityDescription entityForName:@"PartnerSpot" inManagedObjectContext:context]
         insertIntoManagedObjectContext:context];
    isNew = YES;
  }
  spot.partner = partner;
  spot.addressInfo = dict[@"addressInfo"];
  spot.fullAddress = dict[@"fullAddress"];
  spot.phones = dict[@"phones"];
  spot.workHours = dict[@"workHours"];
  spot.latitude = dict[@"location"][@"latitude"];
  spot.longitude = dict[@"location"][@"longitude"];
  
  if (isNew) {
    [context insertObject:spot];
  }
  
  return spot;
}

@end
