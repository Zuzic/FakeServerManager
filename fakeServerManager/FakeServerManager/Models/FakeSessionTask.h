//
//  FakeSessionTask.h
//  fakeServerManager
//
//  Created by Hung Vo on 04.02.15.
//  Copyright (c) 2015 itsoftline. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SectionCallback)(NSData *data, NSURLResponse *response, NSError *error);

@interface FakeSessionTask : NSObject
@property (nonatomic, strong) NSURLSessionTask* sessionTask;
@property (nonatomic, strong) SectionCallback callback;

-(id) initWithSessionTask:(NSURLSessionTask*)sessionTask completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
@end
