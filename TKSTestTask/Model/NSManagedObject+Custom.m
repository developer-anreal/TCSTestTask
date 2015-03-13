//
//  NSManagedObject+Custom.m
//  TKSTestTask
//
//  Created by Anton Serov on 13/03/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import "NSManagedObject+Custom.h"

@implementation NSManagedObject (Custom)

+ (instancetype)firstObjectWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity =
    [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
  [fetchRequest setEntity:entity];
  [fetchRequest setPredicate:predicate];
  NSError *error = nil;
  NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  if (fetchedObjects != nil && fetchedObjects.count > 0) {
    return fetchedObjects.firstObject;
  }
  
  return nil;
}

@end
