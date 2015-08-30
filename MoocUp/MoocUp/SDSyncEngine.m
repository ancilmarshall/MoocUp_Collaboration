//
//  SDSyncEngine.m
//  SignificantDates
//
//  Created by Chris Wagner on 7/1/12.
//

#import "SDSyncEngine.h"
#import "SDCoreDataController.h"
#import "SDAFParseAPIClient.h"


#if 0 && defined(DEBUG)
#define SYNC_ENGINE_LOG(format, ...) NSLog(@"Sync Engine: " format, ## __VA_ARGS__)
#else
#define SYNC_ENGINE_LOG(format, ...)
#endif

NSString * const kSDSyncEngineInitialCompleteKey = @"SDSyncEngineInitialSyncCompleted";
NSString * const kSDSyncEngineSyncCompletedNotificationName = @"SDSyncEngineSyncCompleted";

@interface SDSyncEngine ()

@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SDSyncEngine

@synthesize syncInProgress = _syncInProgress;

@synthesize registeredClassesToSync = _registeredClassesToSync;
@synthesize dateFormatter = _dateFormatter;

+ (SDSyncEngine *)sharedEngine {
    static SDSyncEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[SDSyncEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)registerNSManagedObjectClassToSync:(NSString*)className {
    if (!self.registeredClassesToSync) {
        self.registeredClassesToSync = [NSMutableArray array];
    }
    
    if (![self.registeredClassesToSync containsObject:className]) {
        [self.registeredClassesToSync addObject:className];
    } else {
        NSLog(@"Unable to register %@ as it is already registered",className);
    }
}

- (void)startSync {
    if (!self.syncInProgress) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadDataForRegisteredObjects:YES];
        });
    }
}

- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self setInitialSyncCompleted];
        NSError *error = nil;
        [[SDCoreDataController sharedInstance] saveBackgroundContext];
        if (error) {
            NSLog(@"Error saving background context after creating objects on server: %@", error);
        }
        
        [[SDCoreDataController sharedInstance] saveMasterContext];
        SYNC_ENGINE_LOG(@"Posting Sync Completion Notification");
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:kSDSyncEngineSyncCompletedNotificationName 
         object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}

- (BOOL)initialSyncComplete {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kSDSyncEngineInitialCompleteKey] boolValue];
}

- (void)setInitialSyncCompleted {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kSDSyncEngineInitialCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName {
    __block NSDate *date = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    [request setFetchLimit:1];
    [[[SDCoreDataController sharedInstance] backgroundManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        NSArray *results = [[[SDCoreDataController sharedInstance] backgroundManagedObjectContext] executeFetchRequest:request error:&error];
        if ([results lastObject])   {
            date = [[results lastObject] valueForKey:@"updatedAt"];
            SYNC_ENGINE_LOG(@"Most Recent Course Data in CoreData: %@",date);
        }
    }];
    
    return date;
}

//Update this function to use NSURL Session for HTTP connection
- (void)downloadDataForRegisteredObjects:(BOOL)useUpdatedAtDate {
    //NSMutableArray *operations = [NSMutableArray array];
    
    for (NSString *className in self.registeredClassesToSync) {
        NSDate *mostRecentUpdatedDate = nil;
        if (useUpdatedAtDate) {
            mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:className];
        }
        NSMutableURLRequest *request = [[SDAFParseAPIClient sharedClient]
                                        GETRequestForAllRecordsOfClass:className
                                        updatedAfterDate:mostRecentUpdatedDate];
        
        //TODO: Make this a background download task
        NSURLSessionDataTask* task = [[SDAFParseAPIClient sharedClient] HTTPRequestTaskWithRequest:request
            success:^(NSURLSessionDataTask * task, id responseObject, NSError* error) {
                if (error == nil){
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        SYNC_ENGINE_LOG(@"Writing to JSON file");
                        [self writeJSONResponse:responseObject toDiskForClassWithName:className];
                    } else {
                        NSLog(@"Expected JSON response to be an NSDictionary");
                    }
                } else if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."]) {
                    NSLog(@"Error: %@",error.localizedDescription);
                    [self executeSyncCompletedOperations];
                    //TODO: Inform user that the connection is not available and will try again later
                } else {
                    NSLog(@"Error: %@",error.localizedDescription);
                }
            } failure:^(NSURLSessionDataTask* task, id responseObject, NSError* error){
                NSLog(@"Error: %@",error.localizedDescription);
                [self executeSyncCompletedOperations];
            }];
        //TODO: May not really need this operation queue
        NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
            [task resume];
        }];
        [queue addOperation:operation];
    }
}

- (void)processJSONDataRecordsIntoCoreData {
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    for (NSString *className in self.registeredClassesToSync) {
        if (![self initialSyncComplete]) { // import all downloaded data to Core Data for initial sync
            NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];
            NSArray *records = [JSONDictionary objectForKey:@"results"];
            NSUInteger counter = 0;
            for (NSDictionary *record in records) {
                [self newManagedObjectWithClassName:className forRecord:record];
                counter++;
                SYNC_ENGINE_LOG(@"Processed JSON File into CoreData: %tu of %tu",counter,records.count);
            }
        } else {
            NSArray *downloadedRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
            if ([downloadedRecords lastObject]) {
                NSArray *storedRecords = [self managedObjectsForClass:className sortedByKey:@"objectId" usingArrayOfIds:[downloadedRecords valueForKey:@"objectId"] inArrayOfIds:YES];
                int currentIndex = 0;
                for (NSDictionary *record in downloadedRecords) {
                    NSManagedObject *storedManagedObject = nil;
                    if ([storedRecords count] > currentIndex) {
                        storedManagedObject = [storedRecords objectAtIndex:currentIndex];
                    }
                    
                    if ([[storedManagedObject valueForKey:@"objectId"] isEqualToString:[record valueForKey:@"objectId"]]) {
                        [self updateManagedObject:[storedRecords objectAtIndex:currentIndex] withRecord:record];
                    } else {
                        [self newManagedObjectWithClassName:className forRecord:record];
                    }
                    currentIndex++;
                    SYNC_ENGINE_LOG(@"Processed JSON File into CoreData: %tu of %tu",currentIndex,downloadedRecords.count);

                }
            }
        }
        
        [managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Unable to save context for class %@", className);
            }
        }];
        
        [self deleteJSONDataRecordsForClassWithName:className];
        [self executeSyncCompletedOperations];
    }
    
    //[self downloadDataForRegisteredObjects:NO];
}

- (NSManagedObject*)newManagedObjectWithClassName:(NSString *)className forRecord:(NSDictionary *)record {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[SDCoreDataController sharedInstance] backgroundManagedObjectContext]];
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:newManagedObject];
        
    }];
    [record setValue:[NSNumber numberWithInt:SDObjectSynced] forKey:@"syncStatus"];
    return newManagedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record {
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}


- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
    if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"]) {
        NSDate *date = [self dateUsingStringFromAPI:value];
        [managedObject setValue:date forKey:key];
    } else if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"Object"]){
        return;
    } else if ([key isEqualToString:@"className"]){
        return;
    } else if ([value isKindOfClass:[NSArray class]]){
        //all the relationships are arrays, so are recognized as arrays in the JSONData
        NSArray* valueArray = (NSArray*)value;
        if ([[[valueArray firstObject] objectForKey:@"__type"] isEqualToString:@"Object"]){
            NSMutableSet* relationshipObjects = [NSMutableSet new];
            for (NSDictionary* record in valueArray) {
                NSString* className = [record valueForKey:@"className"];
                NSManagedObject* storedObject = [self managedObjectForClass:className withObjectId:[record valueForKey:@"objectId"]];
                if (storedObject != nil) {
                    [relationshipObjects addObject:storedObject];
                } else {
                    NSManagedObject* newObject = [self newManagedObjectWithClassName:className forRecord:record];
                    [relationshipObjects addObject:newObject];
                }
            }
            [managedObject setValue:relationshipObjects forKey:key];
        }
    } else if ([key isEqualToString:@"image"]) {
        NSDictionary* record = (NSDictionary*)value;
        NSString* className = [record valueForKey:@"className"];
        NSManagedObject* newObject = [self newManagedObjectWithClassName:className forRecord:record];
        [managedObject setValue:newObject forKey:key];
    } else if ([key isEqualToString:@"largeIcon"]) {
        if ([value objectForKey:@"__type"]) {
            NSString *dataType = [value objectForKey:@"__type"];
            if ([dataType isEqualToString:@"File"]) {
                NSString *urlString = [value objectForKey:@"url"];
                NSURL *url = [NSURL URLWithString:urlString];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                NSURLResponse *response = nil;
                NSError *error = nil;
                NSData *dataResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                [managedObject setValue:dataResponse forKey:@"photoData"];
            } else {
                //NSLog(@"Unknown Data Type Received");
                [managedObject setValue:nil forKey:key];
            }
        }
    } else if ([key isEqualToString:@"smallIcon"]){
        return;
    } else if ([key isEqualToString:@"photo"]){
        return;
    } else {
        [managedObject setValue:value forKey:key];
    }
}

- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(SDObjectSyncStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncStatus = %d", syncStatus];
    [fetchRequest setPredicate:predicate];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;    
}

- (NSManagedObject *)managedObjectForClass:(NSString *)className withObjectId:(NSString*)objectId {
    __block NSManagedObject *result = nil;
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    [fetchRequest setPredicate:predicate];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        result = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] lastObject];
    }];
    
    return result;
}


- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate;
    if (inIds) {
        predicate = [NSPredicate predicateWithFormat:@"objectId IN %@", idArray];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"NOT (objectId IN %@)", idArray];
    }
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

- (void)initializeDateFormatter {
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
}

- (NSDate *)dateUsingStringFromAPI:(NSString *)dateString {
    [self initializeDateFormatter];
    // NSDateFormatter does not like ISO 8601 so strip the milliseconds and timezone
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-5)];
    
    return [self.dateFormatter dateFromString:dateString];
}

- (NSString *)dateStringForAPIUsingDate:(NSDate *)date {
    [self initializeDateFormatter];
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    // remove Z
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-1)];
    // add milliseconds and put Z back on
    dateString = [dateString stringByAppendingFormat:@".000Z"];
    
    return dateString;
}

#pragma mark - File Management

- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"JSONRecords/" relativeToURL:[self applicationCacheDirectory]];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    } else {
        //NSLog(@"File already exists at path: %@",[url path]);
    }
    
    return url;
}

- (void)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if (![(NSDictionary *)response writeToFile:[fileURL path] atomically:YES]) {
        NSLog(@"Error saving response to disk, will attempt to remove NSNull values and try again.");
        // remove NSNulls and try again...
        NSArray *records = [response objectForKey:@"results"];
        NSMutableArray *nullFreeRecords = [NSMutableArray array];
        for (NSDictionary *record in records) {
            NSMutableDictionary *nullFreeRecord = [NSMutableDictionary dictionaryWithDictionary:record];
            [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNull class]]) {
                    [nullFreeRecord setValue:nil forKey:key];
                }
            }];
            [nullFreeRecords addObject:nullFreeRecord];
        }
        
        NSDictionary *nullFreeDictionary = [NSDictionary dictionaryWithObject:nullFreeRecords forKey:@"results"];
        
        if (![nullFreeDictionary writeToFile:[fileURL path] atomically:YES]) {
            NSLog(@"Failed all attempts to save reponse to disk: %@", response);
        }
    }
    [self processJSONDataRecordsIntoCoreData];
}

- (void)deleteJSONDataRecordsForClassWithName:(NSString *)className {
    NSURL *url = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        NSLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

- (NSDictionary *)JSONDictionaryForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]]; 
    return [NSDictionary dictionaryWithContentsOfURL:fileURL];
}

- (NSArray *)JSONDataRecordsForClass:(NSString *)className sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];
    NSArray *records = [JSONDictionary objectForKey:@"results"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}
@end
