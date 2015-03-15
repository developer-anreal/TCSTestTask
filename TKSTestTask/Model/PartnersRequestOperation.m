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

@interface PartnersRequestOperation()
@property (nonatomic, strong) PartnersStore *partnersStore;
@property (nonatomic, strong) NSManagedObjectContext* workingContext;
@end

@implementation PartnersRequestOperation

- (id)initWithStore:(PartnersStore *)partnersStore {
  if (self = [super init]) {
    self.partnersStore = partnersStore;
    self.name = @"Partners Request Operation";
  }
  return self;
}

- (NSURL *)requestURL {
  return [NSURL URLWithString:kPartnersURL];
}

- (NSURL *)imageURL {
  return [NSURL URLWithString:@"https://static.tcsbank.ru/icons/deposition-partners-v3/logos/contact.png"];
}

- (NSManagedObjectContext *)context {
  return self.workingContext;
}

- (void)main {
  @autoreleasepool {
    self.workingContext = [self.partnersStore createPrivateContext];
    self.workingContext.undoManager = nil;
    __weak typeof(self) weakSelf = self;
    [self.workingContext performBlockAndWait:^{
      [weakSelf request];
    }];
  }
}

- (void)request {
  if (self.isCancelled) {
    return;
  }
  NSURLRequest *request =
    [NSURLRequest requestWithURL:self.requestURL
      cachePolicy:NSURLRequestReturnCacheDataElseLoad
      timeoutInterval:30];
  NSURLResponse *resp;
  NSError *requestError = nil;
  NSData *data =
    [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&requestError];
  if (requestError != nil) {
    NSLog(@"Error while request: %@", requestError.localizedDescription);
    self.error = requestError;
    return;
  }
  [self parseReceivedData:data];
  [self save];
}

- (NSDate *)imageLastModifiedDate {
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.imageURL];
  
  request.HTTPMethod = @"HEAD";
  NSHTTPURLResponse *response = nil;
  NSError *error = nil;
  
  [NSURLConnection sendSynchronousRequest:request
    returningResponse:&response
    error:&error];
  
  if (error) {
    NSLog(@"Error: %@", error.localizedDescription);
    return nil;
  } else if ([response respondsToSelector:@selector(allHeaderFields)]) {
    NSDictionary *headerFields = [response allHeaderFields];
    NSString *lastModification = [headerFields objectForKey:@"Last-Modified"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    
    return [formatter dateFromString:lastModification];
  }
  
  return nil;
}

- (NSData *)imageData {
  NSDate *lastModificationDate =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"LastModifiedKey"];
  if (lastModificationDate == nil ||
      [lastModificationDate compare:[self imageLastModifiedDate]] == NSOrderedAscending ||
      [[NSUserDefaults standardUserDefaults] dataForKey:@"PartnerImageData"] == nil) {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.imageURL];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"PartnerImageData"];
    return data;
  } else {
    return [[NSUserDefaults standardUserDefaults] dataForKey:@"PartnerImageData"];
  }
}

- (void)parseReceivedData:(NSData *)data {
  NSError *error = nil;
  NSArray *raw =
    [NSJSONSerialization JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                    error:&error][@"payload"];
  
  if (error != nil || raw == nil || self.isCancelled) {
    return;
  }
  
  for (NSDictionary *p in raw) {
    if (self.isCancelled) {
      return;
    }
    
    if (p[@"id"] == nil || p[@"name"] == nil) {
      continue;
    }
    
    Partner *partner = [Partner createOrUpdatePartnerFrom:p inContext:self.workingContext];
    partner.pictureData = [self imageData];
  }
}

- (void)save {
  if (self.isCancelled) {
    [self.context rollback];
  } else {
    [self.context performBlock:^{
      NSError *saveError = nil;
      [self.context save:&saveError];
      if (saveError != nil) {
        NSLog(@"Error while save context: %@", saveError.localizedDescription);
        [self.context rollback];
      }
    }];
  }
}

@end
