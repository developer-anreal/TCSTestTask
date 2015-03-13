//
//  PartnersRequestOperation.m
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import "PartnersRequestOperation.h"

NSString * const kPartnersURL = @"https://api.tcsbank.ru/v1/deposition_partners?accountType=Credit";

@interface PartnersRequestOperation()<NSURLSessionDataDelegate>
@property (nonatomic, strong) PartnersStore *partnersStore;
@property (nonatomic, strong) NSManagedObjectContext* workingContext;
@end

@implementation PartnersRequestOperation

- (id)initWithStore:(PartnersStore *)partnersStore {
  if (self = [super init]) {
    self.partnersStore = partnersStore;
  }
  return self;
}

- (void)main {
  self.workingContext = [self.partnersStore createPrivateContext];
  self.workingContext.undoManager = nil;
  
  __weak typeof(self) weakSelf = self;
  [self.workingContext performBlockAndWait:^{
     [weakSelf request];
  }];
}

- (void)request {
  if (self.isCancelled) {
    return;
  }
  NSURL *url = [NSURL URLWithString:kPartnersURL];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
      delegate:self
      delegateQueue:[NSOperationQueue currentQueue]];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
  [task resume];
}

@end
