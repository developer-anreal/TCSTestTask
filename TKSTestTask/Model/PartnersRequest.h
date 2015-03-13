//
// Created by Anton Serov on 3/12/15.
// Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface PartnersRequest : NSObject

- (void)loadSpotsAtPoint:(CLLocationCoordinate2D)point radius:(double)radius completion:(void (^)(id))completion;

@end