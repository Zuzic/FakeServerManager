//
//  ViewController.m
//  fakeServerManager
//
//  Created by Hung Vo on 02.02.15.
//  Copyright (c) 2015 itsoftline. All rights reserved.
//

#import "ViewController.h"
#import "FakeServerManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self sendRequest];
    
    [[FakeServerManager sharedInstance] startFakeServer];
    
    [self sendPostRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) sendPostRequest{
    NSString *serverUrl = @"http://google.com/example";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];//[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/testMethods?UserId=0&NewsArticleId=0&Date=15/10/2015", serverUrl]]];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    
    // This is how we set header fields
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    // Convert your data and set your request's HTTPBody property
    
   NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@(44),@"UserId",@(0),@"NewsArticleId",@"15/10/2015",@"Date", nil];
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//    
//    request.HTTPBody = jsonData;
    
    NSURLSessionConfiguration *configuratin = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuratin];
    NSMutableArray *pairs = [[NSMutableArray alloc]init];
    for(NSString* key in dict){
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, dict[key]]];
    }
    NSString *requestParameters = [pairs componentsJoinedByString:@"$"];
    NSURL* nsurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/example", serverUrl]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:nsurl];
   // [urlRequest setHTTPMethod:@"POST"];
   // [urlRequest setHTTPBody:[requestParameters dataUsingEncoding:NSUTF8StringEncoding]];
    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"Callback done");
//    }];
//    [dataTask resume];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                                           
//                                       }];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

@end
