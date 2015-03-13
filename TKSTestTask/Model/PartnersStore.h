//
//  PartnersStore.h
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PartnersStore : NSOperation

@property (nonatomic,strong,readonly) NSManagedObjectContext *mainManagedObjectContext;

- (void)saveContext;
- (NSManagedObjectContext *)createPrivateContext;

@end
