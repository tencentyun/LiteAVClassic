//
//  TRTCAudioCallModelDef.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/16.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static UInt32 audioCallVersion = 4;

typedef NS_ENUM(NSInteger, AudioCallAction) {
    AudioCallActionError = -1,
    AudioCallActionUnknown = 0,
    AudioCallActionDialing = 1,
    AudioCallActionSponsorCancel = 2,
    AudioCallActionReject = 3,
    AudioCallActionSponsorTimeout = 4,
    AudioCallActionHangup = 5,
    AudioCallActionLinebusy = 6
};

typedef NS_ENUM(NSUInteger, AudioCallType) {
    AudioCallTypeUnknown = 0,
    AudioCallTypeAudio = 1,
    AudioCallTypeVideo = 2
};

@interface AudioCallModel : NSObject

/// 自定义消息version
@property (nonatomic, assign) UInt32 version;

/// 邀请类型 video or voice
@property (nonatomic, assign) AudioCallType calltype;
/// 邀请群组
@property (nonatomic, copy, nullable) NSString *groupid;
/// 通话ID，每次请求的唯一ID
@property (nonatomic, copy) NSString *callid;
/// 房间ID
@property (nonatomic, assign) UInt32 roomid;
/// 信令消息
@property (nonatomic, assign) AudioCallAction action;
/// 信令代码
@property (nonatomic, assign) NSInteger code;
/// 邀请列表
@property (nonatomic, copy) NSArray<NSString *> *invitedList;

@end

NS_ASSUME_NONNULL_END
