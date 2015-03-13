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
  Partner *p = [Partner firstObjectWithPredicate:[NSPredicate predicateWithFormat:@"partnerId == %@", dict[@"id"]] inContext:context];
  if (p == nil) {
    p = [[Partner alloc] initWithEntity:[NSEntityDescription entityForName:@"Partner" inManagedObjectContext:context]
         insertIntoManagedObjectContext:context];
  }
  
  p.partnerId = dict[@"id"];
  p.name = dict[@"name"];
  
  p.partnerDescription = dict[@"description"];
  p.url = dict[@"url"];
  p.moneyMin = dict[@"moneyMin"];
  p.moneyMin = dict[@"moneyMax"];
  
  if (dict[@"pointType"] != nil) {
    NSString *pointType = dict[@"pointType"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", pointType];
    PointType *pt = [PointType firstObjectWithPredicate:predicate inContext:context];
    if (pt != nil) {
      p.pointType = pt;
    } else {
      pt =
        [[PointType alloc] initWithEntity:[NSEntityDescription entityForName:@"PointType" inManagedObjectContext:context]
         insertIntoManagedObjectContext:context];
      pt.name = dict[@"pointType"];
      p.pointType = pt;
      [context insertObject:pt];
    }
  }
  
  [context insertObject:p];
  
  return p;
}

@end
