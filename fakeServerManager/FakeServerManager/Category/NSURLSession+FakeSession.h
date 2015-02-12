//
//  NSURLSession+FakeSession.h
//  Order
//
//  Created by Hung Vo on 04.02.15.
//  Copyright (c) 2015 Zarubanov Vasily. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (FakeSession)
- (NSURLSessionDataTask *) swizzled_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
@end
