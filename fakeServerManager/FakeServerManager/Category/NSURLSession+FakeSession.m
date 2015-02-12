//
//  NSURLSession+FakeSession.m
//  Order
//
//  Created by Hung Vo on 04.02.15.
//  Copyright (c) 2015 Zarubanov Vasily. All rights reserved.
//

#import "NSURLSession+FakeSession.h"
#include <objc/runtime.h>

#import "FakeServerManager.h"

@implementation NSURLSession (FakeSession)

- (NSURLSessionDataTask *) swizzled_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    NSURLSessionDataTask *sessionTask = [self swizzled_dataTaskWithRequest:request completionHandler:completionHandler];
    
    if([[FakeServerManager sharedInstance] fakeServerState] && completionHandler){
        [[FakeServerManager sharedInstance] addSessionTask:sessionTask completionHandler:completionHandler];
    }
    
    return sessionTask;
}

+ (void)load{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(dataTaskWithRequest:completionHandler:)), class_getInstanceMethod(self, @selector(swizzled_dataTaskWithRequest:completionHandler:)));
}


@end
