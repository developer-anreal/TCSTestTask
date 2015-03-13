//
//  PartnerSpot.h
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PartnerSpot : NSManagedObject

@property (nonatomic, retain) NSString * addressInfo;
@property (nonatomic, retain) NSString * fullAddress;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * partnerName;
@property (nonatomic, retain) NSString * phones;
@property (nonatomic, retain) NSString * workHours;
@property (nonatomic, retain) NSManagedObject *partner;

@end
