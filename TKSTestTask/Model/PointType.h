//
//  PointType.h
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PointType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *spot;
@end

@interface PointType (CoreDataGeneratedAccessors)

- (void)addSpotObject:(NSManagedObject *)value;
- (void)removeSpotObject:(NSManagedObject *)value;
- (void)addSpot:(NSSet *)values;
- (void)removeSpot:(NSSet *)values;

@end
