//
// Created by Anton Serov on 3/12/15.
// Copyright (c) 2015 hexforge. All rights reserved.
//

#import "PartnersRequest.h"

@implementation PartnersRequest

- (void)loadSpotsAtPoint:(CLLocationCoordinate2D)point radius:(double)radius completion:(void (^)(id))completion {
  NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  NSURLRequest *request =
    [NSURLRequest requestWithURL:
      [[NSURL alloc] initWithString:@"https://api.tcsbank.ru/v1/deposition_points?latitude=55.755786&longitude=37.617633&partners=EUROSET&radius=1000"]];
  NSURLSessionDataTask *task =
    [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {

    } else {
      id serialization =
        [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
      if (serialization) {
        completion(serialization[@"payload"]);
      }
    }
  }];
  [task resume];
}

@end