//
//  AFURLSessionManager+FakeSessionAFNetwork.m
//  Order
//
//  Created by Hung Vo on 04.02.15.
//  Copyright (c) 2015 Zarubanov Vasily. All rights reserved.
//

#import "AFURLSessionManager+FakeSessionAFNetwork.h"
#include <objc/runtime.h>

#import "FakeServerManager.h"

#if defined(__has_include)
#if __has_include("AFURLSessionManager.h")
@implementation AFURLSessionManager (FakeSessionAFNetwork)
- (NSURLSessionDataTask *) swizzled_AFNetworkDataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    NSURLSessionDataTask *sessionTask = [self swizzled_AFNetworkDataTaskWithRequest:request completionHandler:completionHandler];
    
    if([[FakeServerManager sharedInstance] fakeServerState] && completionHandler){
        [[FakeServerManager sharedInstance] addSessionTask:sessionTask completionHandler:completionHandler];
        [self performSelector:@selector(removeDelegateForTask:) withObject:sessionTask];
    }
    return sessionTask;
}

+ (void)load{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(dataTaskWithRequest:completionHandler:)), class_getInstanceMethod(self, @selector(swizzled_AFNetworkDataTaskWithRequest:completionHandler:)));
    
    
}
@end
#endif
#endif



