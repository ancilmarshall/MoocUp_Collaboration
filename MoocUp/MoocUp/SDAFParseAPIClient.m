//
//  SDAFParseAPIClient.m
//  SignificantDates
//
//  Created by Chris Wagner on 7/1/12.
//

#import "SDAFParseAPIClient.h"

#if 1 && defined(DEBUG)
#define PARSE_API_LOG(format, ...) NSLog(@"Parse API Client: " format, ## __VA_ARGS__)
#else
#define PARSE_API_LOG(format, ...)
#endif


static NSString* const ParseAPIClientScheme = @"https";
static NSString* const ParseAPIClientHostname = @"api.parse.com";
static NSString* const ParseAPIClientPath = @"/1/";
//TODO: Place this in plist file
static NSString * const kSDFParseAPIApplicationId = @"V7qeQoqBdCe0URaXYO7zWXFZbUg87KlpqUyIB6gV";
static NSString * const kSDFParseAPIKey = @"yBJYwGvjxppoSJmFCIXVIVG8hIbvOgX69nNwAEEP";


@implementation SDAFParseAPIClient

+ (SDAFParseAPIClient *)sharedClient {
    static SDAFParseAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[SDAFParseAPIClient alloc] init];
    }); 
    
    return sharedClient;
}

- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    
    NSURL* url = [self URLForServerEndpoint:
                  [@"classes/" stringByAppendingString:[NSString stringWithFormat:@"%@",className]]
                                 parameters:parameters];
    
    PARSE_API_LOG(@"URL: %@",url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:kSDFParseAPIKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request addValue:kSDFParseAPIApplicationId forHTTPHeaderField:@"X-Parse-Application-Id"];
    
    return request;
}

- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate {
    NSMutableURLRequest *request = nil;
    NSDictionary *paramters = nil;
    if (updatedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'999Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        NSString *jsonString = [NSString 
                                stringWithFormat:@"{\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}", 
                                [dateFormatter stringFromDate:updatedDate]];
        
        paramters = [NSDictionary dictionaryWithObject:jsonString forKey:@"where"];
    }
    
    request = [self GETRequestForClass:className parameters:paramters];
    return request;
}


#pragma mark - NSURLSession task

-(NSURLSessionDataTask*) HTTPRequestTaskWithRequest:(NSURLRequest*)request
                                            success:(HTTPRequestBlockType)successBlock
                                            failure:(HTTPRequestBlockType)failureBlock
{
    //TODO: Change to a background config on a background queue
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    __weak SDAFParseAPIClient* weakSelf = (SDAFParseAPIClient*)self;
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request
                                            completionHandler:
        ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
            JSONPaserBlockType jsonParser = ^(NSDictionary* jsonResp){
                NSDictionary* result = jsonResp[@"results"];
                //TODO: Add some more error checking here, and implement the failureBlock logic
                successBlock(task,result);
            };
            [weakSelf parseData:data response:response error:error handler:jsonParser];
        }];
    return task;
}

#pragma mark - Helper Function Blocks to Handle Server Responses and Parse Data

-(void)parseData:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error handler:(JSONPaserBlockType)jsonParser;
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (!error)
    {
        NSAssert([response isKindOfClass:[NSHTTPURLResponse class]],
                 @"Expected response to be of type NSHTTPURLResponse");
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*)response;
        
        if (httpResp.statusCode == 200){
            
            [self parseJSONData:data usingBlock:jsonParser];
            
        } else {
            [self taskFailedWithErrorMessage:[NSString stringWithFormat:
                                              @"Error in HTTP Repsonse\nStatus code: %tu",httpResp.statusCode]];
        }
    } else {
        [self taskFailedWithErrorMessage:[NSString stringWithFormat:
                                          @"Error in NSURLSessionTask\nError: %@",[error localizedDescription]]];
    }
}


-(void)parseJSONData:(NSData*)data usingBlock:(JSONPaserBlockType)jsonParserBlock {
    
    // Parse returned JSON data
    NSError* jsonError = nil;
    NSDictionary* jsonResp =
    [NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingAllowFragments
                                      error:&jsonError];
    
    if (!jsonError){
        
        jsonParserBlock(jsonResp);
        
    } else {
        [self taskFailedWithErrorMessage:[NSString stringWithFormat:
                                          @"Error serializing JSON data\nError: %@",[jsonError localizedDescription]]];
    }
}

-(void)taskFailedWithErrorMessage:(NSString*)errorMsg;
{
    NSLog(@"%@",errorMsg);
}

#pragma mark - URL based on Query Items and Server Endpoints

-(NSURL*)URLForServerEndpoint:(NSString*)endpoint parameters:(NSDictionary*)parameters
{
    //create queryItems
    NSMutableArray* queryItems = [NSMutableArray new];

    //add name/value pairs to the url from the parmeters dictionary
    if (parameters!=nil){
        for (NSString* key in [parameters allKeys]){
            [queryItems addObject:
             [NSURLQueryItem queryItemWithName:key value:parameters[key]]];
        }
    }
    
    NSURLComponents* URLcomponents = [self NSURLComponentsFromEndpoint:endpoint
                                                            queryItems:queryItems];
    
    return URLcomponents.URL;
    
}

-(NSURL*)URLForServerEndpoint:(NSString*)endpoint;
{
    return [self URLForServerEndpoint:endpoint parameters:nil];
}

-(NSURLComponents*)NSURLComponentsFromEndpoint:(NSString*)endpoint queryItems:(NSArray*)queryItems;
{
    
    NSURLComponents* components = [[NSURLComponents alloc] init];
    components.scheme = ParseAPIClientScheme;
    components.host = ParseAPIClientHostname;
    components.path = [ParseAPIClientPath stringByAppendingString:endpoint];
    components.queryItems = queryItems;
    
    return  components;
}

@end
