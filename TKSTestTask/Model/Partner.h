//
//  Partner.h
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PartnerSpot, PointType;

@interface Partner : NSManagedObject

@property (nonatomic, retain) NSString * partnerId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * partenrDescription;
@property (nonatomic, retain) NSNumber * moneyMin;
@property (nonatomic, retain) NSNumber * moneyMax;
@property (nonatomic, retain) PointType *pointType;
@property (nonatomic, retain) NSSet *spots;
@end

@interface Partner (CoreDataGeneratedAccessors)

- (void)addSpotsObject:(PartnerSpot *)value;
- (void)removeSpotsObject:(PartnerSpot *)value;
- (void)addSpots:(NSSet *)values;
- (void)removeSpots:(NSSet *)values;

@end
