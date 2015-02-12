//
//  NSURLConnection+Methods.m
//  fakeServerManager
//
//  Created by Hung Vo on 12.02.15.
//  Copyright (c) 2015 itsoftline. All rights reserved.
//

#import "NSURLConnection+Methods.h"
#include <objc/runtime.h>
#import "FakeServerManager.h"

static char key;

@implementation NSURLConnection (Methods)
-(void) swizzle_start{
    if([[FakeServerManager sharedInstance] fakeServerState]){
        NSError *error = nil;
        
        NSData *responseData = [[FakeServerManager sharedInstance] sendFakeRequest:self.currentRequest error:&error];
        id baseDelegate = [self requestDelegate];
        if(error){
            if([baseDelegate respondsToSelector:@selector(connection:didFailWithError:)]){
                [baseDelegate connection:self didFailWithError:error];
            }
            return;
        }
       
        if(responseData){
            if([baseDelegate respondsToSelector:@selector(connection:didReceiveData:)]){
                [baseDelegate connection:self didReceiveData:responseData];
            }
            return;
        }
    }
    else{
        [self swizzle_start];
    }
}

- (instancetype)swizzle_initWithRequest:(NSURLRequest *)request delegate:(id)delegate{
    [self setDelegate:delegate];
    return [self swizzle_initWithRequest:request delegate:delegate];
}


-(void) callDelegateWithData:(id)responseValue{
    
}

//property
-(void)setDelegate:(id)requestDelegate {
    objc_setAssociatedObject(self, &key, requestDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id) requestDelegate {
    return objc_getAssociatedObject(self, &key);
}

//swizzling
+(void)load{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(start)), class_getInstanceMethod(self, @selector(swizzle_start)));
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(initWithRequest:delegate:)), class_getInstanceMethod(self, @selector(swizzle_initWithRequest:delegate:)));
}

@end
