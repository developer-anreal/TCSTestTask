//
//  PartnersRequestOperation.h
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PartnersStore.h"

extern NSString * const kPartnersURL;

@interface PartnersRequestOperation : NSOperation

- (id)initWithStore:(PartnersStore *)partnersStore;

@end
