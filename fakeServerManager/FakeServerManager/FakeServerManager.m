//
//  FakeServerManager.m
//  fakeServerManager
//
//  Created by Hung Vo on 02.02.15.
//  Copyright (c) 2015 itsoftline. All rights reserved.
//

#import "FakeServerManager.h"
#import "FakeSessionTask.h"
#import "FakeServerDefines.h"

enum {
    HTTPPOST,
    HTTPGET
};

typedef NSInteger HttpMethodType;

@interface FakeServerManager()
@property (nonatomic, strong) NSURLRequest *requestFake;
@property (nonatomic, assign) HttpMethodType httpMethodType;
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSMutableArray *fakeSessionTaskArray;

@property (assign) BOOL isServerRun;
@end

@implementation FakeServerManager
#pragma mark - singleton
+ (FakeServerManager *)sharedInstance
{
    static FakeServerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FakeServerManager alloc] init];
        sharedInstance.fakeSessionTaskArray = [NSMutableArray new];
    });
    return sharedInstance;
}

#pragma mark - Public methods
-(void) startFakeServer{
    self.isServerRun = YES;
}

-(void) stopFakeServer{
    self.isServerRun = NO;
}

-(BOOL) fakeServerState{
    return self.isServerRun;
}

-(void) addSessionTask:(NSURLSessionTask*)task completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionTask == %@", task];
    NSArray *filteredArray = [self.fakeSessionTaskArray filteredArrayUsingPredicate:predicate];
    
    if(filteredArray.count>0){
        FakeSessionTask *fakeTask = [filteredArray firstObject];
        [self.fakeSessionTaskArray removeObject:fakeTask];
    }
    [self.fakeSessionTaskArray addObject:[[FakeSessionTask alloc] initWithSessionTask:task completionHandler:completionHandler]];
}

-(id) getCallbackByRequest:(NSURLRequest*)request{
    for(FakeSessionTask *task in self.fakeSessionTaskArray){
        if([task.sessionTask.currentRequest isEqual:request]){
            if ([task respondsToSelector:@selector(callback)]) {
                return task.callback;
            }
            else
            {
                return nil;
            }
            
        }
    }
    return nil;
}

-(void) sendFakeRequest:(NSURLRequest*)request completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    
    NSError *error = nil;
    
    NSData *responseData = [self sendFakeRequest:request error:&error];
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"text/plain" expectedContentLength:0 textEncodingName:nil];
    
    if(completionHandler){
        if(error){
            completionHandler(response, nil, error);
        }
        else{
            completionHandler(response, responseData, nil);
        }
    }
    
    [self.fakeSessionTaskArray removeObject:[self getCurrentTaskByRequest:self.requestFake]];
}

-(NSData*) sendFakeRequest:(NSURLRequest*)request error:(NSError**)error{
    self.requestFake = request;
    self.httpMethodType = [self httpMethod];
    self.methodName = [self methodName];
    
    NSDictionary *responseDict = [self methodResponse];
    
    BOOL successValue = [responseDict[JSON_ResponseSuccess_Key] boolValue];
    
    
    if(!responseDict || !successValue){
        *error = [self createErrorWithErrorDescription:responseDict[JSON_ResponseErrorMessage_Key] code:[responseDict[JSON_ResponseCode_Key] integerValue]];
    }
    
    if(*error){
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:responseDict[JSON_ResponseData_Key] options:0 error:nil];
}


#pragma mark - Private methods
-(NSError*) createErrorWithErrorDescription:(NSString*)descriptionOfErr code:(NSInteger)errorCode{
    NSInteger code = errorCode;
    NSString *errorDisc = descriptionOfErr.length>0 ? descriptionOfErr : ERROR_Description_Value;
    NSArray *objArray = [NSArray arrayWithObjects:errorDisc, ERROR_Cause_Value, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    return [NSError errorWithDomain:ERROR_Domain_Value code:code userInfo:userInfo];
}

-(HttpMethodType) httpMethod{
    if([self.requestFake.HTTPMethod.lowercaseString isEqualToString:POST.lowercaseString]){
        return HTTPPOST;
    }
    
    if ([self.requestFake.HTTPMethod.lowercaseString isEqualToString:GET.lowercaseString]) {
        return HTTPGET;
    }
    
    return HTTPGET;
}

-(NSString*) methodName{
    NSString *baseUrl = [self.requestFake.URL absoluteString];
    
    if([self checkUrlParameters]){
        NSString *urlStr = [self.requestFake.URL absoluteString];
        NSArray *splitUrlArray = [urlStr componentsSeparatedByString:@"?"];
        baseUrl = [splitUrlArray firstObject];
    }
    
    NSMutableArray *splitBaseUrlArray = [NSMutableArray arrayWithArray:[baseUrl componentsSeparatedByString:@"/"]];
    NSString *methodName = [splitBaseUrlArray lastObject];
    if(methodName.length>0){
        return methodName;
    }
   [splitBaseUrlArray removeLastObject];
    
    return [splitBaseUrlArray lastObject];
}

-(NSDictionary*) methodResponse{
    NSDictionary *parametersDict = [self parametersFromBody];
    
    NSDictionary *responseDictionary = [self loadDataFromJsonFile];
    
    BOOL isResponseWithError = [responseDictionary[JSON_ResponseError_Key] boolValue];
    
    if(!responseDictionary)
        return nil;
    
    if(isResponseWithError){
        return responseDictionary[JSON_Error_Key];
    }
    
    
    id result = responseDictionary[JSON_Values_Key];
    
    if([result isKindOfClass:[NSArray class]]){
        NSArray *resultArray = (NSArray*) result;
        
        for(NSDictionary *respDict in resultArray){
            if([self compareDictionary:respDict[JSON_ParameterValues_Key] withDictionary:parametersDict]){
                return respDict[JSON_ResponseValue_Key];
            }
        }
        
        return [resultArray firstObject][JSON_ResponseValue_Key];
    }
    
    if([result isKindOfClass:[NSDictionary class]]){
        return result[JSON_Error_Key];
    }
    
    return nil;
}

-(BOOL) checkUrlParameters{
    NSString *requestUrl = [self.requestFake.URL absoluteString];
    if ([requestUrl rangeOfString:@"?"].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

-(NSDictionary*) parametersFromUrl{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    NSString *requestUrl = [self.requestFake.URL absoluteString];
    NSArray *splitUrlArray = [requestUrl componentsSeparatedByString:@"?"];
    
    NSArray *keyValyeParameters = [[splitUrlArray lastObject] componentsSeparatedByString:@"&"];
    
    for(NSString *strWithValue in keyValyeParameters){
        NSArray *keyValueArray = [strWithValue componentsSeparatedByString:@"="];
        [parameters setObject:[keyValueArray lastObject] forKey:[keyValueArray firstObject]];
    }
    
    return parameters;
}

-(NSDictionary*) parseRequestBody{
    NSError *error = nil;
    
    NSData *reguestHttpBody = self.requestFake.HTTPBody;
    
    NSMutableDictionary *parseBody = [NSJSONSerialization JSONObjectWithData:reguestHttpBody options: NSJSONReadingMutableContainers error: &error];
    
    if(error){
        if(!parseBody){
            parseBody = [NSMutableDictionary new];
        }
        NSString *bodyText = [[NSString alloc] initWithData:reguestHttpBody encoding:NSUTF8StringEncoding];
        NSArray *keyValueParameters = [bodyText componentsSeparatedByString:@"&"];
        if(keyValueParameters.count>0){
            for(NSString *strWithValue in keyValueParameters){
                NSArray *keyValueArray = [strWithValue componentsSeparatedByString:@"="];
                [parseBody setObject:[keyValueArray lastObject] forKey:[keyValueArray firstObject]];
            }
        }
        else{
            NSArray *keyValueArray = [bodyText componentsSeparatedByString:@"="];
            [parseBody setObject:[keyValueArray lastObject] forKey:[keyValueArray firstObject]];
        }
    }
    
    return parseBody;
}

-(NSDictionary*) parametersFromBody{
    NSDictionary *parametersFromBody = [NSDictionary new];
    
    if(self.httpMethodType == HTTPGET){
        if([self checkUrlParameters]){
            parametersFromBody = [self parametersFromUrl];
        }
    }
    else if(self.httpMethodType == HTTPPOST){
        parametersFromBody = [self parseRequestBody];
    }
    return parametersFromBody;
}

-(NSDictionary*) loadDataFromJsonFile{
    __autoreleasing NSError* error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.methodName ofType:@"json"];
    if(!filePath){
        return nil;
    }
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(!result && error){
        return nil;
    }
    return result;
}

-(BOOL) compareDictionary:(NSDictionary*)firstDictionary withDictionary:(NSDictionary*)secondDictionary{
    NSArray *firstDictKey = [firstDictionary allKeys];
    NSArray *secondDictKey = [secondDictionary allKeys];
    
    if(![firstDictKey isEqualToArray:secondDictKey]){
        return NO;
    }
    
    for(NSString *key in firstDictKey){
        id value1 = [firstDictionary objectForKey:key];
        id value2 = [secondDictionary objectForKey:key];
        
        NSString *value1Str = [value1 isKindOfClass:[NSString class]] ? [value1 stringByRemovingPercentEncoding] : [value1 stringValue];
        NSString *value2Str = [value2 isKindOfClass:[NSString class]] ? [value2 stringByRemovingPercentEncoding] : [value2 stringValue];
        
        if(![value1Str isEqualToString:value2Str]){
            return NO;
        }
    }
    
    return YES;
}

-(FakeSessionTask*) getCurrentTaskByRequest:(NSURLRequest*)request{
    for(FakeSessionTask *task in self.fakeSessionTaskArray){
        if([task.sessionTask.currentRequest isEqual:request]){
            return task;
        }
    }
    return nil;
}

@end
