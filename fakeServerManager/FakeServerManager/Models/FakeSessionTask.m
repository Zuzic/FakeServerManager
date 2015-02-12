//
//  FakeSessionTask.m
//  fakeServerManager
//
//  Created by Hung Vo on 04.02.15.
//  Copyright (c) 2015 itsoftline. All rights reserved.
//

#import "FakeSessionTask.h"

@implementation FakeSessionTask

-(id) initWithSessionTask:(NSURLSessionTask*)sessionTask completionHandler:(SectionCallback)completionHandler{
    self = [super init];
    if(self){
        self.sessionTask = sessionTask;
        self.callback = completionHandler;
    }
    return self;
}

@end
