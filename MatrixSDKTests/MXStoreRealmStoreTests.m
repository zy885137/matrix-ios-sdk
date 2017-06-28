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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MXRealmStore.h"
#import "MXStoreTests.h"

// Do not bother with retain cycles warnings in tests
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"

@interface MXStoreRealmStoreTests : MXStoreTests
@end

@implementation MXStoreRealmStoreTests

- (void)doTestWithMXRealmStore:(void (^)(MXRoom *room))readyToTest
{
    MXRealmStore *store = [[MXRealmStore alloc] init];
    [self doTestWithStore:store readyToTest:readyToTest];
}

- (void)doTestWithTwoUsersAndMXRealmStore:(void (^)(MXRoom *room))readyToTest
{
    MXRealmStore *store = [[MXRealmStore alloc] init];
    [self doTestWithTwoUsersAndStore:store readyToTest:readyToTest];
}

- (void)doTestWithMXRealmStoreAndMessagesLimit:(NSUInteger)messagesLimit readyToTest:(void (^)(MXRoom *room))readyToTest
{
    MXRealmStore *store = [[MXRealmStore alloc] init];
    [self doTestWithStore:store andMessagesLimit:messagesLimit readyToTest:readyToTest];
}


#pragma mark - MXRealmStore
- (void)testMXRealmStoreEventExistsWithEventId
{
    MXRealmStore *store = [[MXRealmStore alloc] init];
    [self checkEventExistsWithEventIdOfStore:store];
}

- (void)testMXRealmStoreEventWithEventId
{
    MXRealmStore *store = [[MXRealmStore alloc] init];
    [self checkEventWithEventIdOfStore:store];
}

- (void)testMXRealmStorePaginateBack
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkPaginateBack:room];
    }];
}

- (void)testMXRealmStorePaginateBackFilter
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkPaginateBackFilter:room];
    }];
}

- (void)testMXRealmStorePaginateBackOrder
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkPaginateBackOrder:room];
    }];
}

- (void)testMXRealmStorePaginateBackDuplicates
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkPaginateBackDuplicates:room];
    }];
}

// This test illustrates bug SYIOS-9
- (void)testMXRealmStorePaginateBackDuplicatesInRoomWithTwoUsers
{
    [self doTestWithTwoUsersAndMXRealmStore:^(MXRoom *room) {
        [self checkPaginateBackDuplicates:room];
    }];
}

- (void)testMXRealmStoreSeveralPaginateBacks
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkSeveralPaginateBacks:room];
    }];
}

- (void)testMXRealmStorePaginateWithLiveEvents
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkPaginateWithLiveEvents:room];
    }];
}

- (void)testMXRealmStoreCanPaginateFromHomeServer
{
    // Preload less messages than the room history counts so that there are still requests to the HS to do
    [self doTestWithMXRealmStoreAndMessagesLimit:1 readyToTest:^(MXRoom *room) {
        [self checkCanPaginateFromHomeServer:room];
    }];
}

- (void)testMXRealmStoreCanPaginateFromMXStore
{
    // Preload more messages than the room history counts so that all messages are already loaded
    // room.liveTimeline.canPaginate will use [MXStore canPaginateInRoom]
    [self doTestWithMXRealmStoreAndMessagesLimit:100 readyToTest:^(MXRoom *room) {
        [self checkCanPaginateFromMXStore:room];
    }];
}

- (void)testMXRealmStoreLastMessageAfterPaginate
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkLastMessageAfterPaginate:room];
    }];
}

- (void)testMXRealmStoreLastMessageProfileChange
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkLastMessageProfileChange:room];
    }];
}

- (void)testMXMFileStoreLastMessageIgnoreProfileChange
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkLastMessageIgnoreProfileChange:room];
    }];
}

- (void)testMXRealmStorePaginateWhenJoiningAgainAfterLeft
{
    [self doTestWithMXRealmStoreAndMessagesLimit:100 readyToTest:^(MXRoom *room) {
        [self checkPaginateWhenJoiningAgainAfterLeft:room];
    }];
}

- (void)testMXRealmStoreAndHomeServerPaginateWhenJoiningAgainAfterLeft
{
    // Not preloading all messages of the room causes a duplicated event issue with MXRealmStore
    // See `testMXRealmStorePaginateBackDuplicatesInRoomWithTwoUsers`.
    // Check here if MXRealmStore is able to filter this duplicate
    [self doTestWithMXRealmStoreAndMessagesLimit:10 readyToTest:^(MXRoom *room) {
        [self checkPaginateWhenJoiningAgainAfterLeft:room];
    }];
}

- (void)testMXRealmStorePaginateWhenReachingTheExactBeginningOfTheRoom
{
    [self doTestWithMXRealmStore:^(MXRoom *room) {
        [self checkPaginateWhenReachingTheExactBeginningOfTheRoom:room];
    }];
}

- (void)testMXRealmStoreRedactEvent
{
    [self doTestWithMXRealmStoreAndMessagesLimit:100 readyToTest:^(MXRoom *room) {
        [self checkRedactEvent:room];
    }];
}

- (void)testMXRealmStoreUserDisplaynameAndAvatarUrl
{
    [self checkUserDisplaynameAndAvatarUrl:MXRealmStore.class];
}

- (void)testMXRealmStoreUpdateUserDisplaynameAndAvatarUrl
{
    [self checkUpdateUserDisplaynameAndAvatarUrl:MXRealmStore.class];
}

- (void)testMXRealmStoreMXSessionOnStoreDataReady
{
    [self checkMXSessionOnStoreDataReady:MXRealmStore.class];
}

- (void)testMXRealmStoreRoomDeletion
{
    [self checkRoomDeletion:MXRealmStore.class];
}

- (void)testMXRealmStoreAge
{
    [self checkEventAge:MXRealmStore.class];
}

- (void)testMXRealmStoreMXRoomPaginationToken
{
    [self checkMXRoomPaginationToken:MXRealmStore.class];
}

- (void)testMXRealmStoreMultiAccount
{
    [self checkMultiAccount:MXRealmStore.class];
}

- (void)testMXRealmStoreRoomAccountDataTags
{
    [self checkRoomAccountDataTags:MXRealmStore.class];
}

- (void)testMXRealmStoreRoomSummary
{
    [self checkRoomSummary:MXRealmStore.class];
}

@end

#pragma clang diagnostic pop
