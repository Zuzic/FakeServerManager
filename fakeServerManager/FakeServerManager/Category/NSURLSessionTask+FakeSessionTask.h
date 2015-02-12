//
//  NSURLSessionTask+FakeSessionTask.h
//  Order
//
//  Created by Hung Vo on 04.02.15.
//  Copyright (c) 2015 Zarubanov Vasily. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionTask (FakeSessionTask)
-(void) swizzle_resume;
@end
