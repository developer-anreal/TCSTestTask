//
//  PartnerSpot.h
//  TKSTestTask
//
//  Created by Anton Serov on 3/14/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner;

@interface PartnerSpot : NSManagedObject

@property (nonatomic, retain) NSString * addressInfo;
@property (nonatomic, retain) NSString * fullAddress;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * phones;
@property (nonatomic, retain) NSString * workHours;
@property (nonatomic, retain) Partner *partner;

@end
