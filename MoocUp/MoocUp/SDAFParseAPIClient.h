//
//  SDAFParseAPIClient.h
//  SignificantDates
//
//  Created by Chris Wagner on 7/1/12.
//

#import <UIKit/UIKit.h>

typedef void(^JSONPaserBlockType)(NSDictionary*,NSError*);
typedef void(^HTTPRequestBlockType)(NSURLSessionDataTask*,id,NSError*);

@interface SDAFParseAPIClient : NSObject 

+ (SDAFParseAPIClient *)sharedClient;

- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate;
- (NSURLSessionDataTask*) HTTPRequestTaskWithRequest:(NSURLRequest*)request
                                             success:(HTTPRequestBlockType)successBlock
                                             failure:(HTTPRequestBlockType)failureBlock;

@end
