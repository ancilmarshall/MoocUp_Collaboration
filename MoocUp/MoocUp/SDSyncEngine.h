//
//  SDSyncEngine.h
//  SignificantDates
//
//  Created by Chris Wagner on 7/1/12.
//

#import <Foundation/Foundation.h>

extern NSString * const kSDSyncEngineSyncCompletedNotificationName;

typedef enum {
    SDObjectSynced = 0,
} SDObjectSyncStatus;

@interface SDSyncEngine : NSObject

@property (atomic, readonly) BOOL syncInProgress;

+ (SDSyncEngine *)sharedEngine;

- (void)registerNSManagedObjectClassToSync:(NSString*)className;
- (void)startSync;

@end
