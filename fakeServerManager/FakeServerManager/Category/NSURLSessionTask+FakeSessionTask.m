//
//  NSURLSessionTask+FakeSessionTask.m
//  Order
//
//  Created by Hung Vo on 04.02.15.
//  Copyright (c) 2015 Zarubanov Vasily. All rights reserved.
//

#import "NSURLSessionTask+FakeSessionTask.h"
#import "FakeServerManager.h"
#include <objc/runtime.h>

@implementation NSURLSessionTask (FakeSessionTask)

-(void) swizzle_resume{
    if([[FakeServerManager sharedInstance] fakeServerState]){
        id callback = [[FakeServerManager sharedInstance] getCallbackByRequest:self.currentRequest];
        [[FakeServerManager sharedInstance] sendFakeRequest:self.currentRequest completionHandler:callback];
    }
    else{
        [self swizzle_resume];
    }
}

+(void)load{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(resume)), class_getInstanceMethod(self, @selector(swizzle_resume)));
}

@end
