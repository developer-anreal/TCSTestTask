//
//  Partner+Addition.m
//  TKSTestTask
//
//  Created by Anton Serov on 13/03/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import "Partner+Addition.h"
#import "PointType.h"
#import "NSManagedObject+Custom.h"

@implementation Partner (Creation)

+ (Partner *)createOrUpdatePartnerFrom:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
  BOOL isNew = NO;
  Partner *partner = [Partner firstObjectWithPredicate:[NSPredicate predicateWithFormat:@"partnerId == %@", dict[@"id"]] inContext:context];
  if (partner == nil) {
    partner = [[Partner alloc] initWithEntity:[NSEntityDescription entityForName:@"Partner" inManagedObjectContext:context]
         insertIntoManagedObjectContext:context];
    isNew = YES;
  }
  
  partner.partnerId = dict[@"id"];
  partner.name = dict[@"name"];
  
  partner.partnerDescription = dict[@"description"];
  partner.url = dict[@"url"];
  partner.moneyMin = dict[@"moneyMin"];
  partner.moneyMin = dict[@"moneyMax"];
  
  if (dict[@"pointType"] != nil) {
    NSString *pointType = dict[@"pointType"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", pointType];
    PointType *pt = [PointType firstObjectWithPredicate:predicate inContext:context];
    if (pt != nil) {
      partner.pointType = pt;
    } else {
      pt =
        [[PointType alloc] initWithEntity:[NSEntityDescription entityForName:@"PointType" inManagedObjectContext:context]
         insertIntoManagedObjectContext:context];
      pt.name = dict[@"pointType"];
      partner.pointType = pt;
      [context insertObject:pt];
    }
  }
  
  if (isNew) {
    [context insertObject:partner];
  }
  
  return partner;
}

@end

@implementation Partner (Image)

- (UIImage *)image {
  return [UIImage imageWithData:self.pictureData];
}

@end