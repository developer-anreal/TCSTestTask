//
//  PartnerSpot+Addition.h
//  TKSTestTask
//
//  Created by Anton Serov on 3/14/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PartnerSpot.h"

@interface PartnerSpot (Creation)

+ (PartnerSpot *)createOrUpdateSpotFrom:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

@end
