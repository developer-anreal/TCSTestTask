//
//  NSManagedObject+Custom.h
//  TKSTestTask
//
//  Created by Anton Serov on 13/03/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (Custom)

+ (instancetype)firstObjectWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

@end
