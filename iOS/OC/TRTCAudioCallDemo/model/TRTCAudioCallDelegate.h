//
//  TRTCAudioCallDelegate.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/16.
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TRTCAudioCallDelegate_h
#define TRTCAudioCallDelegate_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TRTCAudioCallDelegate <NSObject>

@optional
- (void)onError:(int)code
            msg:(NSString * _Nullable)msg
NS_SWIFT_NAME(onError(code:msg:));

- (void)onInvited:(NSString *)sponsor
          userIds:(NSArray<NSString *> *)userIds
      isFromGroup:(BOOL)isFromGroup
NS_SWIFT_NAME(onInvited(sponsor:userIds:isFromGroup:));

- (void)onGroupCallInviteeListUpdate:(NSArray<NSString *> *)userIds
NS_SWIFT_NAME(onGroupCallInviteeListUpdate(userIds:));

- (void)onUserEnter:(NSString *)uid
NS_SWIFT_NAME(onUserEnter(uid:));

- (void)onUserLeave:(NSString *)uid
NS_SWIFT_NAME(onUserLeave(uid:));

- (void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available
NS_SWIFT_NAME(onUserAudioAvailable(uid:available:));

- (void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume
NS_SWIFT_NAME(onUserVoiceVolume(uid:volume:));

- (void)onReject:(NSString *)uid
NS_SWIFT_NAME(onReject(uid:));

- (void)onNoResp:(NSString *)uid
NS_SWIFT_NAME(onNoResp(uid:));

- (void)onLineBusy:(NSString *)uid
NS_SWIFT_NAME(onLineBusy(uid:));

- (void)onCallingCancel;

- (void)onCallingTimeOut;

- (void)onCallEnd;

@end

NS_ASSUME_NONNULL_END

#endif /* TRTCAudioCallDelegate_h */
