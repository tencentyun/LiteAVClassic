//
//  TRTCVideoCallDelegate.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/22.
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TRTCVideoCallDelegate_h
#define TRTCVideoCallDelegate_h

#import <Foundation/Foundation.h>

@protocol TRTCVideoCallDelegate <NSObject>

@optional
/// sdk内部发生了错误 | sdk error
/// - Parameters:
///   - code: 错误码
///   - msg: 错误消息
- (void)onError:(int)code
            msg:(NSString *)msg
NS_SWIFT_NAME(onError(code:msg:));

/// 被邀请通话回调 | invitee callback
/// - Parameter userIds: 邀请列表 (invited list)
- (void)onInvited:(NSString *)sponsor
          userIds:(NSArray<NSString *> *)userIds
      isFromGroup:(BOOL)isFromGroup
NS_SWIFT_NAME(onInvited(sponsor:userIds:isFromGroup:));

/// 群聊更新邀请列表回调 | update current inviteeList in group calling
/// - Parameter userIds: 邀请列表 | inviteeList
- (void)onGroupCallInviteeListUpdate:(NSArray<NSString *> *)userIds
NS_SWIFT_NAME(onGroupCallInviteeListUpdate(userIds:));

/// 进入通话回调 | user enter room callback
/// - Parameter uid: userid
- (void)onUserEnter:(NSString *)uid
NS_SWIFT_NAME(onUserEnter(uid:));

/// 离开通话回调 | user leave room callback
/// - Parameter uid: userid
- (void)onUserLeave:(NSString *)uid
NS_SWIFT_NAME(onUserLeave(uid:));

/// 用户是否开启音频上行回调 | is user audio available callback
/// - Parameters:
///   - uid: 用户ID | userID
///   - available: 是否有效 | available
- (void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available
NS_SWIFT_NAME(onUserAudioAvailable(uid:available:));

/// 用户是否开启视频上行回调 | is user video available callback
/// - Parameters:
///   - uid: 用户ID | userID
///   - available: 是否有效 | available
- (void)onUserVideoAvailable:(NSString *)uid available:(BOOL)available
NS_SWIFT_NAME(onUserVideoAvailable(uid:available:));

/// 用户音量回调
/// - Parameter uid: 用户ID | userID
- (void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume
NS_SWIFT_NAME(onUserVoiceVolume(uid:volume:));

/// 拒绝通话回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// reject callback only worked for Sponsor, others should use onUserEnter)
/// - Parameter uid: userid
- (void)onReject:(NSString *)uid
NS_SWIFT_NAME(onReject(uid:));

/// 无回应回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// no response callback only worked for Sponsor, others should use onUserEnter)
/// - Parameter uid: userid
- (void)onNoResp:(NSString *)uid
NS_SWIFT_NAME(onNoResp(uid:));

/// 通话占线回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// linebusy callback only worked for Sponsor, others should use onUserEnter
/// - Parameter uid: userid
- (void)onLineBusy:(NSString *)uid
NS_SWIFT_NAME(onLineBusy(uid:));

// invitee callback

/// 当前通话被取消回调 | current call had been canceled callback
- (void)onCallingCancel;

/// 通话超时的回调 | timeout callback
- (void)onCallingTimeOut;

/// 通话结束 | end callback
- (void)onCallEnd;

@end

#endif /* TRTCVideoCallDelegate_h */
