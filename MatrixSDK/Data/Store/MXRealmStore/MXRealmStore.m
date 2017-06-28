/*
 Copyright 2017 Vector Creations Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXRealmStore.h"

#ifdef MX_REALM_STORE

#import <Realm/Realm.h>
#import "MXRealmStoreModels.h"

@interface MXRealmStore ()
{
    // The user credentials
    MXCredentials *credentials;
}

@end

@implementation MXRealmStore

- (BOOL)isPermanent
{
    return YES;
}

- (void)openWithCredentials:(MXCredentials*)credentials onComplete:(void (^)())onComplete failure:(void (^)(NSError *error))failure
{

}

- (void)setEventStreamToken:(NSString *)eventStreamToken
{

}

- (NSString *)eventStreamToken
{
    return nil;
}

- (void)storeEventForRoom:(NSString*)roomId event:(MXEvent*)event direction:(MXTimelineDirection)direction
{

}

- (void)replaceEvent:(MXEvent*)event inRoom:(NSString*)roomId
{
}

- (BOOL)eventExistsWithEventId:(NSString*)eventId inRoom:(NSString*)roomId
{
    return NO;
}

- (MXEvent*)eventWithEventId:(NSString*)eventId inRoom:(NSString*)roomId
{
    return nil;
}

- (void)deleteAllMessagesInRoom:(NSString *)roomId
{
}

- (void)deleteRoom:(NSString*)roomId
{

}

- (void)deleteAllData
{

}


- (void)storePaginationTokenOfRoom:(NSString*)roomId andToken:(NSString*)token
{

}

- (NSString*)paginationTokenOfRoom:(NSString*)roomId
{
    return nil;
}


- (void)storeHasReachedHomeServerPaginationEndForRoom:(NSString*)roomId andValue:(BOOL)value
{

}

- (BOOL)hasReachedHomeServerPaginationEndForRoom:(NSString*)roomId
{
    return NO;
}


- (id<MXEventsEnumerator>)messagesEnumeratorForRoom:(NSString*)roomId
{
    return nil;
}

- (id<MXEventsEnumerator>)messagesEnumeratorForRoom:(NSString*)roomId withTypeIn:(NSArray*)types
{
    return nil;
}


#pragma mark - Matrix users
- (void)storeUser:(MXUser*)user
{

}

- (NSArray<MXUser*>*)users
{
    return nil;
}

- (MXUser*)userWithUserId:(NSString*)userId
{
    return nil;
}


- (void)storePartialTextMessageForRoom:(NSString*)roomId partialTextMessage:(NSString*)partialTextMessage
{

}

- (NSString*)partialTextMessageOfRoom:(NSString*)roomId
{
    return nil;
}


- (NSArray*)getEventReceipts:(NSString*)roomId eventId:(NSString*)eventId sorted:(BOOL)sort
{
    return nil;
}

- (BOOL)storeReceipt:(MXReceiptData*)receipt inRoom:(NSString*)roomId
{
    return NO;
}

- (MXReceiptData *)getReceiptInRoom:(NSString*)roomId forUserId:(NSString*)userId
{
    return nil;
}


- (NSUInteger)localUnreadEventCount:(NSString*)roomId withTypeIn:(NSArray*)types
{
    return 0;
}

- (void)commit
{

}

- (void)close
{

}


#pragma mark - Permanent storage
- (NSArray*)rooms
{
    return nil;
}


- (void)storeStateForRoom:(NSString*)roomId stateEvents:(NSArray*)stateEvents
{
    // @TODO in a thread like in MXFileStore

    RLMRealm *realm = self.realm;
    
    NSDate *startDate2 = [NSDate date];

    @autoreleasepool
    {
        __block MXRealmRoom *realmRoom = [MXRealmRoom objectsInRealm:realm where:@"roomId = %@", roomId].firstObject;

        if (realmRoom.state.count)
        {
            NSLog(@"#### stateEvents: %@", @(stateEvents.count));

            // Compute the diff with what is already stored
            NSMutableDictionary *stateEventsById = [NSMutableDictionary dictionaryWithCapacity:stateEvents.count];
            for (MXEvent *event in stateEvents)
            {
                stateEventsById[event.eventId] = event;
            }

            NSArray<NSString *> *storedEventIds = [realmRoom.state valueForKey:@"eventId"];
            NSLog(@"#### storedEventIds: %@", @(storedEventIds.count));

            // Do not readd existing objects
            for (NSString *eventId in storedEventIds)
            {
                [stateEventsById removeObjectForKey:eventId];

                // TODO: get events to remove from the store
            }

            stateEvents = stateEventsById.allValues;

            NSLog(@"#### -> stateEvents: %@", @(stateEvents.count));
        }

        if (stateEvents.count)
        {
            [realm transactionWithBlock:^{

                if (!realmRoom)
                {
                    realmRoom = [[MXRealmRoom alloc] initWithValue:@{
                                                                     @"roomId": roomId,
                                                                     }];

                    [realm addObject:realmRoom];
                }

                for (MXEvent *event in stateEvents)
                {
                    MXRealmEvent *realmEvent = [MXRealmEvent fromMXEvent:event];
                    [realmRoom.state addObject:realmEvent];
                }
            }];
        }
    }

    if ([roomId isEqualToString:@"!cURbafjkfsMDVwdRDQ:matrix.org"])
    {
        NSLog(@"#### Stored %@ states of MatrixHQ in %.0fms", @(stateEvents.count), [[NSDate date] timeIntervalSinceDate:startDate2] * 1000);
        NSLog(@"####");
    }

}

- (NSArray*)stateOfRoom:(NSString*)roomId
{
    // First, try to get the state from the cache
    NSArray *stateEvents; // = preloadedRoomsStates[roomId]; @TODO like MXFileStore

    NSDate *startDate = [NSDate date];

    NSMutableArray *stateEventsM;

    RLMRealm *realm = self.realm;

    MXRealmRoom *realmRoom = [MXRealmRoom objectsInRealm:realm where:@"roomId = %@", roomId].firstObject;
    if (realmRoom)
    {
        stateEventsM = [[NSMutableArray alloc] initWithCapacity:realmRoom.state.count];

        @autoreleasepool
        {
            for (MXRealmEvent *stateEvent in realmRoom.state)
            {
                [stateEventsM addObject:[stateEvent mxEvent]];
            }
        }
    }

    stateEvents = stateEventsM;

    if ([roomId isEqualToString:@"!cURbafjkfsMDVwdRDQ:matrix.org"])
    {
        NSLog(@"#### Loaded %@ states of MatrixHQ in %.0fms", @(stateEvents.count), [[NSDate date] timeIntervalSinceDate:startDate] * 1000);
        NSLog(@"####");
    }

    return stateEvents;
}


- (void)storeSummaryForRoom:(NSString*)roomId summary:(MXRoomSummary*)summary
{

}

- (MXRoomSummary*)summaryOfRoom:(NSString*)roomId
{
    return nil;
}


- (void)storeAccountDataForRoom:(NSString*)roomId userData:(MXRoomAccountData*)accountData
{

}

- (MXRoomAccountData*)accountDataOfRoom:(NSString*)roomId
{
    return nil;
}

#pragma mark - Outgoing events
- (void)storeOutgoingMessageForRoom:(NSString*)roomId outgoingMessage:(MXEvent*)outgoingMessage
{

}

- (void)removeAllOutgoingMessagesFromRoom:(NSString*)roomId
{

}

- (void)removeOutgoingMessageFromRoom:(NSString*)roomId outgoingMessage:(NSString*)outgoingMessageEventId
{

}

- (NSArray<MXEvent*>*)outgoingMessagesInRoom:(NSString*)roomId
{
    return nil;
}

- (void)setUserAccountData:(NSDictionary *)userAccountData
{

}

- (NSDictionary *)userAccountData
{
    return nil;
}

#pragma mark - Private methods

/**
 Build the realm configuration for the current user.
 */
- (RLMRealmConfiguration*)realmConfiguration
{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];

    // Use the default directory, but replace the filename with the userId
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
                       URLByAppendingPathComponent:[NSString stringWithFormat:@"MXStore-%@", credentials.userId]]
                      URLByAppendingPathExtension:@"realm"];

    config.schemaVersion = 0;

    return config;
}

/**
 Get the realm instance for the current user.
 */
- (RLMRealm*)realm
{
    return [RLMRealm realmWithConfiguration:self.realmConfiguration error:nil];
}

@end

#endif // MX_REALM_STORE
