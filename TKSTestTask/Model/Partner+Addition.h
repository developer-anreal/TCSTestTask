//
//  Partner+Addition.h
//  TKSTestTask
//
//  Created by Anton Serov on 13/03/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Partner.h"

@interface Partner (Creation)

+ (Partner *)createOrUpdatePartnerFrom:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

@end
