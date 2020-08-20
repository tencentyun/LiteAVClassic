//
//  TRTCVideoCallModelDef.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/22.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static UInt32 videoCallVersion = 4;

typedef NS_ENUM(NSInteger, VideoCallAction) {
    VideoCallActionError = -1,
    VideoCallActionUnknown = 0,
    VideoCallActionDialing = 1,
    VideoCallActionSponsorCancel = 2,
    VideoCallActionReject = 3,
    VideoCallActionSponsorTimeout = 4,
    VideoCallActionHangup = 5,
    VideoCallActionLinebusy = 6
};

typedef NS_ENUM(NSUInteger, VideoCallType) {
    VideoCallTypeUnknown = 0,
    VideoCallTypeAudio = 1,
    VideoCallTypeVideo = 2
};

@interface VideoCallModel : NSObject

/// 自定义消息version
@property (nonatomic, assign) UInt32 version;

/// 邀请类型 video or voice
@property (nonatomic, assign) VideoCallType calltype;
/// 邀请群组
@property (nonatomic, copy, nullable) NSString *groupid;
/// 通话ID，每次请求的唯一ID
@property (nonatomic, copy) NSString *callid;
/// 房间ID
@property (nonatomic, assign) UInt32 roomid;
/// 信令消息
@property (nonatomic, assign) VideoCallAction action;
/// 信令代码
@property (nonatomic, assign) NSInteger code;
/// 邀请列表
@property (nonatomic, copy) NSArray<NSString *> *invitedList;

@end

NS_ASSUME_NONNULL_END
