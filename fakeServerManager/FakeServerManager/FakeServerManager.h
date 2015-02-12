//
//  FakeServerManager.h
//  fakeServerManager
//
//  Created by Hung Vo on 02.02.15.
//  Copyright (c) 2015 itsoftline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLSession+FakeSession.h"
#import "NSURLSessionTask+FakeSessionTask.h"

@interface FakeServerManager : NSObject
+ (FakeServerManager *)sharedInstance;

-(void) startFakeServer;
-(BOOL) fakeServerState;

-(NSData*) sendFakeRequest:(NSURLRequest*)request error:(NSError**)error;

//For Session Task
-(void) sendFakeRequest:(NSURLRequest*)request completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

-(void) addSessionTask:(NSURLSessionTask*)task completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
-(id) getCallbackByRequest:(NSURLRequest*)request;

@end
