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

#import "MXRealmStoreModels.h"

#pragma mark - MXRealmAccount
@implementation MXRealmAccount

@end


#pragma mark - MXRealmEvent
@implementation MXRealmEvent

// @TODO: Realm crashes on primary keys on the simulator on my mac
//+ (NSString *)primaryKey
//{
//    return @"eventId";
//}

- (MXEvent *)mxEvent
{
    MXEvent *event = [[MXEvent alloc] init];

    event.eventId = self.eventId;
    event.roomId = self.roomId;
    event.sender = self.sender;
    event.stateKey = self.stateKey;
    event.originServerTs = (uint64_t)self.originServerTs;
    event.ageLocalTs = (uint64_t)self.ageLocalTs;
    event.redacts = self.redacts;
    event.sentState = (MXEventSentState)self.sentState;

    if (self.eventType == MXEventTypeCustom)
    {
        event.wireType = self.type;
    }
    else
    {
        event.wireEventType = (MXEventType)self.eventType;
    }

    if (self.content)
    {
        event.wireContent = [NSJSONSerialization JSONObjectWithData:self.content options:0 error:nil];
    }
    if (self.prevContent)
    {
        event.prevContent = [NSJSONSerialization JSONObjectWithData:self.prevContent options:0 error:nil];
    }
    if (self.unsignedData )
    {
        event.unsignedData = [NSJSONSerialization JSONObjectWithData:self.unsignedData options:0 error:nil];
    }
    if (self.redactedBecause)
    {
        event.redactedBecause = [NSJSONSerialization JSONObjectWithData:self.redactedBecause options:0 error:nil];
    }

    if (self.inviteRoomState)
    {
        event.inviteRoomState = [NSKeyedUnarchiver unarchiveObjectWithData:self.inviteRoomState];
    }
    if (self.sentError)
    {
        event.sentError = [NSKeyedUnarchiver unarchiveObjectWithData:self.sentError];
    }

    return event;
}

+ (MXRealmEvent*)fromMXEvent:(MXEvent*)event
{
    MXRealmEvent *realmEvent = [[MXRealmEvent alloc] init];

    realmEvent.eventId = event.eventId;
    realmEvent.roomId = event.roomId;
    realmEvent.sender = event.sender;
    realmEvent.stateKey = event.stateKey;
    realmEvent.originServerTs = (long long)event.originServerTs;
    realmEvent.ageLocalTs = (long long)event.ageLocalTs;
    realmEvent.redacts = event.redacts;
    realmEvent.sentState = (NSInteger)event.sentState;

    if (event.wireEventType == MXEventTypeCustom)
    {
        realmEvent.type = event.wireType;
    }
    else
    {
        realmEvent.eventType = (NSInteger)event.wireEventType;
    }

    realmEvent.content = [NSJSONSerialization dataWithJSONObject:event.wireContent options:0 error:nil];
    if (event.prevContent)
    {
        realmEvent.prevContent = [NSJSONSerialization dataWithJSONObject:event.prevContent options:0 error:nil];
    }
    if (event.unsignedData)
    {
        realmEvent.unsignedData = [NSJSONSerialization dataWithJSONObject:event.unsignedData options:0 error:nil];
    }
    if (event.redactedBecause)
    {
        realmEvent.redactedBecause = [NSJSONSerialization dataWithJSONObject:event.redactedBecause options:0 error:nil];
    }
    if (event.inviteRoomState)
    {
        realmEvent.inviteRoomState = [NSKeyedArchiver archivedDataWithRootObject:event.inviteRoomState];
    }
    if (event.sentError)
    {
        realmEvent.sentError = [NSKeyedArchiver archivedDataWithRootObject:event.sentError];
    }
    
    return realmEvent;
}
@end


#pragma mark - MXRealmRoom
@implementation MXRealmRoom

// @TODO: Realm crashes on primary keys on the simulator on my mac
//+ (NSString *)primaryKey
//{
//    return @"roomId";
//}

@end
