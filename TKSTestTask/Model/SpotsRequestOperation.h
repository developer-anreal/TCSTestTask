//
//  SpotsRequestOperation.h
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PartnersRequestOperation.h"

extern NSString * const kPartnersSpotTemplateURL;

@interface SpotsRequestOperation : PartnersRequestOperation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
    radius:(NSInteger)radius
    store:(PartnersStore *)partnersStore;

@end
