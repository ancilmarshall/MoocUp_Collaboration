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
static NSString * const kAPIClientPlistFileName = @"ParseAPIClient";
static NSString * const kAPIClientPlistAppIDKey = @"ParseAPIApplicationID";
static NSString * const kAPIClientPlistRESTKey  = @"ParseAPIRestKey";

@interface SDAFParseAPIClient()
@property (nonatomic,strong) NSDictionary* clientPlistDict;
@end

@implementation SDAFParseAPIClient

+ (SDAFParseAPIClient *)sharedClient {
    static SDAFParseAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[SDAFParseAPIClient alloc] initInstance];
    }); 
    
    return sharedClient;
}

- (instancetype)initInstance;
{
    self = [super init];
    if (self){
        NSURL* clientPlistURL = [[NSBundle mainBundle] URLForResource:kAPIClientPlistFileName withExtension:@"plist"];
        self.clientPlistDict = [NSDictionary dictionaryWithContentsOfURL:clientPlistURL];
    }
    return self;
}

- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    
    NSURL* url = [self URLForServerEndpoint:
                  [@"classes/" stringByAppendingString:[NSString stringWithFormat:@"%@",className]]
                                 parameters:parameters];
    
    PARSE_API_LOG(@"URL: %@",url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:self.clientPlistDict[kAPIClientPlistRESTKey] forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request addValue:self.clientPlistDict[kAPIClientPlistAppIDKey] forHTTPHeaderField:@"X-Parse-Application-Id"];
    
    return request;
}

- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate {
    NSMutableURLRequest *request = nil;
    NSDictionary *parameters = nil;
    NSMutableDictionary* mutableParameters = [NSMutableDictionary new];
    if (updatedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'999Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        NSString *jsonString = [NSString 
                                stringWithFormat:@"{\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}", 
                                [dateFormatter stringFromDate:updatedDate]];
        
        [mutableParameters setObject:jsonString forKey:@"where"];
    }
    
    //[mutableParameters setObject:@"image,languages" forKey:@"include"];
    parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    request = [self GETRequestForClass:className parameters:parameters];
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
                successBlock(task,jsonResp);
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
    NSMutableArray* queryItems = nil;

    //add name/value pairs to the url from the parmeters dictionary
    if (parameters!=nil){
        queryItems = [NSMutableArray new];
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
