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

#import <Foundation/Foundation.h>

#import "MXSDKOptions.h"

#ifdef MX_REALM_STORE

#import <Realm/Realm.h>

#import "MXEvent.h"


#pragma mark - MXRealmAccount
@interface MXRealmAccount : RLMObject

@property (nonatomic) NSString *homeServer;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *eventStreamToken;
@property (nonatomic) NSDictionary *userAccountData;

@end


#pragma mark - MXRealmEvent
@interface MXRealmEvent : RLMObject

@property NSString *eventId;
@property NSString *roomId;
@property NSString *sender;
@property NSString *stateKey;
@property NSString *redacts;

@property long long ageLocalTs;
@property long long originServerTs;

@property NSInteger sentState;
@property NSData *sentError;

@property MXEventTypeString type;
@property NSInteger eventType;

@property NSData *content;
@property NSData *prevContent;

@property NSData *unsignedData;
@property NSData *redactedBecause;
@property NSData *inviteRoomState; // NSCoding

- (MXEvent*)mxEvent;
+ (MXRealmEvent*)fromMXEvent:(MXEvent*)event;

@end
RLM_ARRAY_TYPE(MXRealmEvent)


#pragma mark - MXRealmRoom
@interface MXRealmRoom : RLMObject

@property NSString *roomId;

@property NSString *paginationToken;
@property BOOL hasReachedHomeServerPaginationEnd;

@property RLMArray<MXRealmEvent *><MXRealmEvent> *state;

@end
RLM_ARRAY_TYPE(MXRealmRoom)

#endif // MX_REALM_STORE
