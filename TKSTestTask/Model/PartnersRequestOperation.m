//
//  PartnersRequestOperation.m
//  TKSTestTask
//
//  Created by Anton Serov on 3/13/15.
//  Copyright (c) 2015 hexforge. All rights reserved.
//

#import "PartnersRequestOperation.h"
#import "Partner+Addition.h"

NSString * const kPartnersURL = @"https://api.tcsbank.ru/v1/deposition_partners?accountType=Credit";

@interface PartnersRequestOperation()<NSURLSessionDataDelegate>
@property (nonatomic, strong) PartnersStore *partnersStore;
@property (nonatomic, strong) NSManagedObjectContext* workingContext;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSOperationQueue *currentQueue;
@end

@implementation PartnersRequestOperation

- (id)initWithStore:(PartnersStore *)partnersStore {
  if (self = [super init]) {
    self.partnersStore = partnersStore;
    self.receivedData = [[NSMutableData alloc] init];
    self.name = @"Partners Request Operation";
  }
  return self;
}

- (void)main {
  [self request];
}

- (void)request {
  if (self.isCancelled) {
    return;
  }
  self.currentQueue = [NSOperationQueue currentQueue];
  NSURL *url = [NSURL URLWithString:kPartnersURL];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
      delegate:self
      delegateQueue:self.currentQueue];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
  [task resume];
}

- (void)createPartners {
  self.workingContext = [self.partnersStore createPrivateContext];
  self.workingContext.undoManager = nil;
  
  __weak typeof(self) weakSelf = self;
  [self.workingContext performBlockAndWait:^{
    NSError *error = nil;
    NSError *saveError = nil;
    NSArray *raw =
    [NSJSONSerialization JSONObjectWithData:weakSelf.receivedData
                                    options:NSJSONReadingAllowFragments
                                      error:&error][@"payload"];
    
    if (error != nil || raw == nil) {
      return;
    }
    
    for (NSDictionary *p in raw) {
      if (weakSelf.isCancelled) {
        break;
      }
      
      if (p[@"id"] == nil || p[@"name"] == nil) {
        continue;
      }
      
      [Partner createOrUpdatePartnerFrom:p inContext:weakSelf.workingContext];
      [weakSelf.workingContext save:&saveError];
    }
    [weakSelf.workingContext save:&saveError];
  }];
}

#pragma mark - NSURLSessionTaskDelegate impl

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    didCompleteWithError:(NSError *)error {
  if (self.isCancelled) {
    self.receivedData = nil;
    return;
  }
  
  if (self.receivedData.length > 0) {
    [self createPartners];
  }
}

#pragma mark - NSURLSessionDataDelegate impl

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
  if (self.isCancelled) {
    [dataTask cancel];
    return;
  }
  
  [self.receivedData appendData:data];
}

@end
