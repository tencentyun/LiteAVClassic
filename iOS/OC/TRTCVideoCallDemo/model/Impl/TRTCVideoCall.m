//
//  TRTCVideoCall.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/22.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCVideoCall.h"
#import "TRTCCloud.h"
#import "VideoCallUtils.h"
#import <ImSDK/ImSDK.h>

static double kTimeOut = 30.0;

@interface TRTCVideoCall ()<TRTCCloudDelegate, V2TIMAdvancedMsgListener>

@property (nonatomic, assign) UInt32 mSDKAppID;
@property (nonatomic, strong) NSString *mUserSig;

@property (nonatomic, assign) UInt32 curRoomID;
@property (nonatomic, strong) NSString *curGroupID;
@property (nonatomic, strong) NSString *curCallID;
@property (nonatomic, assign) VideoCallAction curType;
// data
@property (nonatomic, assign) UInt32 checkTimeID;
@property (nonatomic, strong) NSMutableArray<NSString *> *curInvitiingList;
@property (nonatomic, strong) NSMutableArray<NSString *> *curRespList;
@property (nonatomic, strong) NSMutableArray<NSString *> *curRoomList;
@property (nonatomic, strong) NSString *curSponsorForMe;
@property (nonatomic, strong) VideoCallModel *curLastModel;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *checkTimeOutIDsMap;
// flag
@property (nonatomic, assign) BOOL isFrontCamera;
@property (nonatomic, assign) BOOL isRespSponsor;
@property (nonatomic, assign) BOOL isInRoom;
@property (nonatomic, assign) BOOL isOnCalling;

@end

@implementation TRTCVideoCall

@dynamic curCallID;
@dynamic curRoomID;
@dynamic curType;
@dynamic curGroupID;

+ (instancetype)sharedInstance {
    static TRTCVideoCall* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TRTCVideoCall alloc] init];
    });
    return instance;
}

- (void)setup {
    self.isOnCalling = NO;
}

- (void)destroy {
    self.delegate = nil;
    [[V2TIMManager sharedInstance] removeAdvancedMsgListener:self];
}

- (void)setIsOnCalling:(BOOL)isOnCalling {
    BOOL isChange = isOnCalling != _isOnCalling;
    _isOnCalling = isOnCalling;
    if (!_isOnCalling && isChange) {
        // 退出通话
        self.curCallID = @"";
        self.curRoomID = 0;
        self.curType = VideoCallActionUnknown;
        [self.curInvitiingList removeAllObjects];
        [self.curRespList removeAllObjects];
        [self.curRoomList removeAllObjects];
        self.curSponsorForMe = @"";
        [self.checkTimeOutIDsMap removeAllObjects];
        self.checkTimeID = 0;
        self.curLastModel = [[VideoCallModel alloc] init];
        self.isRespSponsor = NO;
        self.isInRoom = NO;
    }
    TRTCLog(@"isOnCalling: %d", _isOnCalling);
}

- (void)setCurCallID:(NSString *)curCallID {
    self.curLastModel.callid = curCallID;
}

- (NSString *)curCallID {
    return self.curLastModel.callid;
}

- (void)setCurRoomID:(UInt32)curRoomID {
    self.curLastModel.roomid = curRoomID;
}

- (UInt32)curRoomID {
    return self.curLastModel.roomid;
}

- (void)setCurType:(VideoCallAction)curType {
    self.curLastModel.calltype = curType;
}

- (VideoCallAction)curType {
    return self.curLastModel.calltype;
}

- (void)setCurGroupID:(NSString *)curGroupID {
    self.curLastModel.groupid = curGroupID;
}

- (NSString *)curGroupID {
    return self.curLastModel.groupid;
}


- (VideoCallModel *)curLastModel {
    if (!_curLastModel) {
        _curLastModel = [[VideoCallModel alloc] init];
    }
    return _curLastModel;
}

- (NSMutableArray<NSString *> *)curInvitiingList {
    if (!_curInvitiingList) {
        _curInvitiingList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return _curInvitiingList;
}

- (NSMutableDictionary<NSString *,NSString *> *)checkTimeOutIDsMap {
    if (!_checkTimeOutIDsMap) {
        _checkTimeOutIDsMap = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _checkTimeOutIDsMap;
}

- (NSMutableArray<NSString *> *)curRoomList {
    if (!_curRoomList) {
        _curRoomList = [NSMutableArray arrayWithCapacity:2];
    }
    return _curRoomList;
}

#pragma mark - login
- (void)login:(UInt32)sdkAppID user:(NSString *)userID userSig:(NSString *)userSig success:(VideoCallback)success failed:(VideoErrorCallback)failed {
    self.mSDKAppID = sdkAppID;
    self.mUserSig = userSig;
    [[V2TIMManager sharedInstance] initSDK:sdkAppID config:nil listener:nil];
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
    
    if ([[[V2TIMManager sharedInstance] getLoginUser] isEqualToString:userID]) {
        if (success) {
            success();
        }
        // 设置APNS
        [self setupAPNS];
        return;
    }
    
    NSAssert(userID.length > 0 || userSig.length > 0, @"用户名或用户签名设置有误");
    TIMLoginParam *loginParam = [[TIMLoginParam alloc] init];
    loginParam.identifier = userID;
    loginParam.userSig = userSig;
    @weakify(self)
    [[V2TIMManager sharedInstance] login:userID userSig:userSig succ:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (success) {
            success();
        }
        [self setupAPNS];
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
            [self.delegate onError:code msg:desc];
        }
        if (failed) {
            failed(code, desc);
        }
    }];
}

- (void)logout:(VideoCallback)success failed:(VideoErrorCallback)failed {
    self.mUserSig = nil;
    self.mSDKAppID = 0;
    [[V2TIMManager sharedInstance] logout:^{
        if (success) {
            success();
        }
    } fail:^(int code, NSString *desc) {
        if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
            [self.delegate onError:code msg:desc];
        }
        if (failed) {
            failed(code, desc);
        }
    }];
}

- (void)call:(NSString *)userID type:(VideoCallType)type {
    [self invite:@[userID] type:type groupID:nil];
}

- (void)groupCall:(NSArray<NSString *> *)userIDs type:(VideoCallType)type groupID:(NSString *)groupID {
    [self invite:userIDs type:type groupID:groupID];
}

- (void)invite:(NSArray<NSString *> *)userIds type:(VideoCallType)type groupID:(NSString *)groupID {
    if (!self.isOnCalling) {
        self.curCallID = [VideoCallUtils generateCallID];
        self.curRoomID = [VideoCallUtils generateRoomID];
        self.curGroupID = groupID;
        self.curType = type;
        self.isOnCalling = YES;
        self.curLastModel.action = VideoCallActionDialing;
        [self enterRoom:self.mSDKAppID userSig:self.mUserSig];
    }
    NSMutableArray *filterUserIds = [NSMutableArray arrayWithCapacity:2];
    for (NSString *userID in userIds) {
        if (![self.curInvitiingList containsObject:userID]) {
            [self.curInvitiingList addObject:userID];
            [filterUserIds addObject:userID];
        }
    }
    self.curLastModel.invitedList = self.curInvitiingList;
    for (NSString *userID in self.curInvitiingList) {
        if ([self.curRespList containsObject:userID]) {
            [self.curRespList removeObject:userID];
        }
    }
    if (self.curGroupID && self.curGroupID.length > 0) {
        if (filterUserIds.count > 0) {
            [self sendModel:self.curGroupID action:VideoCallActionDialing model:nil];
        }
    } else {
        for (NSString *userID in filterUserIds) {
            [self sendModel:userID action:VideoCallActionDialing model:nil];
        }
    }
    /// 发起方检查超时
    for (NSString *userID in filterUserIds) {
        [self checkTimeOut:userID time:kTimeOut];
    }
}

- (void)accept {
    self.isRespSponsor = YES;
    [self enterRoom:self.mSDKAppID userSig:self.mUserSig];
}

- (void)reject {
    self.isRespSponsor = YES;
    [self sendModel:self.curGroupID ?: self.curSponsorForMe action:VideoCallActionReject model:nil];
    self.isOnCalling = false;
}

- (void)hangup {
    if (!self.isOnCalling) {
        return;
    }
    if (!self.isInRoom) {
        [self reject];
        return;
    }
    if (self.curGroupID) {
        if (self.curRoomList.count == 0) {
            if (self.curInvitiingList.count > 0) {
                // 没有应答的人取消
                [self sendModel:self.curGroupID action:VideoCallActionSponsorCancel model:nil];
            }
        }
    } else {
        for (NSString *userID in self.curInvitiingList) {
            [self sendModel:userID action:VideoCallActionSponsorCancel model:nil];
        }
    }
    [self quitRoom];
    self.isOnCalling = NO;
}

- (void)startRemoteView:(NSString *)userId view:(UIView *)view {
    [[TRTCCloud sharedInstance] startRemoteView:userId view:view];
}

- (void)stopRemoteView:(NSString *)userId {
    [[TRTCCloud sharedInstance] stopRemoteView:userId];
}

- (void)openCamera:(BOOL)frontCamera view:(UIView *)view {
    self.isFrontCamera = frontCamera;
    [[TRTCCloud sharedInstance] startLocalPreview:frontCamera view:view];
}

- (void)closeCamara {
    [[TRTCCloud sharedInstance] stopLocalPreview];
}

- (void)switchCamera:(BOOL)frontCamera {
    if (frontCamera != self.isFrontCamera) {
        [[TRTCCloud sharedInstance] switchCamera];
        self.isFrontCamera = frontCamera;
    }
}

- (void)setIsMicMute:(BOOL)isMicMute {
    _isMicMute = isMicMute;
    [[TRTCCloud sharedInstance] muteLocalAudio:isMicMute];
}

- (void)setHandsFree:(BOOL)isHandsFree {
    _isHandsFreeOn = isHandsFree;
    [[TRTCCloud sharedInstance] setAudioRoute:isHandsFree ? TRTCAudioModeSpeakerphone : TRTCAudioModeEarpiece];
}

#pragma mark - trtc room
- (void)enterRoom:(UInt32)sdkAppId userSig:(NSString *)userSig {
    TXBeautyManager* beauty = [[TRTCCloud sharedInstance] getBeautyManager];
    [beauty setBeautyStyle:TXBeautyStyleNature];
    [beauty setBeautyLevel:6];
    
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = sdkAppId;
    params.userId = [VideoCallUtils curUserId];
    params.roomId = self.curRoomID;
    params.userSig = userSig;
    params.privateMapKey = @"";
    
    //编码设置
    TRTCVideoEncParam *videoEncParam = [[TRTCVideoEncParam alloc] init];
    videoEncParam.videoResolution = TRTCVideoResolution_960_540;
    videoEncParam.videoFps = 15;
    videoEncParam.videoBitrate = 1000;
    videoEncParam.resMode = TRTCVideoResolutionModePortrait;
    videoEncParam.enableAdjustRes = YES;
    [[TRTCCloud sharedInstance] setVideoEncoderParam:videoEncParam];
    
    [TRTCCloud sharedInstance].delegate = self;
    [[TRTCCloud sharedInstance] setAudioQuality:TRTCAudioQualitySpeech];
    [[TRTCCloud sharedInstance] enterRoom:params appScene:TRTCAppSceneVideoCall];
    [[TRTCCloud sharedInstance] startLocalAudio];
    [[TRTCCloud sharedInstance] enableAudioVolumeEvaluation:300];
    self.isMicMute = NO;
    self.isHandsFreeOn = YES; // 视频通话默认打开免提
    self.isInRoom = YES;
}

- (void)quitRoom {
    [[TRTCCloud sharedInstance] stopLocalAudio];
    [[TRTCCloud sharedInstance] stopLocalPreview];
    [[TRTCCloud sharedInstance] exitRoom];
    self.isMicMute = NO;
    self.isHandsFreeOn = YES;
    self.isInRoom = NO;
}


#pragma mark - TRTCCloudDelegate
- (void)onEnterRoom:(NSInteger)result {
    if (result < 0) {
        self.curLastModel.code = result;
        if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
            [self.delegate onCallEnd];
        }
        [self hangup];
    }
}

- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    self.curLastModel.code = errCode;
    if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
        [self.delegate onCallEnd];
    }
    [self hangup];
}

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    [self.curInvitiingList removeObject:userId];
    if (![self.curRoomList containsObject:userId]) {
        [self.curRoomList addObject:userId];
    }
    if ([self canDelegateRespondMethod:@selector(onUserEnter:)]) {
        [self.delegate onUserEnter:userId];
    }
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    [self.curInvitiingList removeObject:userId];
    [self.curRoomList removeObject:userId];
    if ([self canDelegateRespondMethod:@selector(onUserLeave:)]) {
        [self.delegate onUserLeave:userId];
    }
    [self checkAutoHangUp];
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    if ([self canDelegateRespondMethod:@selector(onUserAudioAvailable:available:)]) {
        [self.delegate onUserAudioAvailable:userId available:available];
    }
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    if ([self canDelegateRespondMethod:@selector(onUserVideoAvailable:available:)]) {
        [self.delegate onUserVideoAvailable:userId available:available];
    }
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    if ([self canDelegateRespondMethod:@selector(onUserVoiceVolume:volume:)]) {
        for (TRTCVolumeInfo *info in userVolumes) {
            if (info.userId) {
                [self.delegate onUserVoiceVolume:info.userId volume:(UInt32)info.volume];
            } else {
                [self.delegate onUserVoiceVolume:[VideoCallUtils curUserId] volume:(UInt32)info.volume];
            }
        }
    }
}

#pragma mark - V2TIMAdvancedMsgListener
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        V2TIMCustomElem* elem = msg.customElem;
        VideoCallModel *model = [VideoCallUtils dataToCallModel:elem.data];
        if (!model || model.calltype != VideoCallTypeVideo) {
            return;
        }
        [TRTCCloud sharedInstance].delegate = self;
        if (model.version == videoCallVersion && msg.sender) {
            TRTCLog(@"on call msg: sender:%@, call_id:%@, room_id:%u, action:%ld", msg.sender, model.callid, (unsigned int)model.roomid, (long)model.action);
            NSTimeInterval timeInterval = [[[NSDate alloc] init] timeIntervalSinceDate:msg.timestamp];
            BOOL isTimeOut = timeInterval >= kTimeOut;
            if (!isTimeOut) {
                [self handleCallModelWithSender:msg.sender model:model leftTime:MAX(0, kTimeOut - timeInterval)];
                if ([model.callid isEqualToString:self.curCallID]) {
                    if (![self.curRespList containsObject:msg.sender]) {
                        [self.curRespList addObject:msg.sender];
                    }
                }
            }
        }
    }
}


#pragma mark - private Method
- (BOOL)canDelegateRespondMethod:(SEL)selector {
    return self.delegate && [self.delegate respondsToSelector:selector];
}

- (void)checkAutoHangUp {
    if (self.isInRoom && self.curRoomList.count == 0 && self.curInvitiingList.count == 0) {
        if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
            [self.delegate onCallEnd];
        }
        [self hangup];
    }
}

- (void)checkTimeOut:(NSString *)uid time:(double)time {
    NSString *checkID = [VideoCallUtils generateCallID];
    self.checkTimeOutIDsMap[uid] = checkID;
    NSString *cid = self.curCallID;
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self) {
            return;
        }
        NSString *theCheckId = self.checkTimeOutIDsMap[uid];
        if ([self.curCallID isEqualToString:cid] && [checkID isEqualToString:theCheckId]) {
            BOOL timeOut = ![self.curRespList containsObject:uid] && [self.curInvitiingList containsObject:uid];
            if (timeOut) {
                if ([self canDelegateRespondMethod:@selector(onNoResp:)]) {
                    [self.delegate onNoResp:uid];
                }
                [self.curInvitiingList removeObject:uid];
            }
            [self.curRespList removeObject:uid];
            if (timeOut) {
                [self checkAutoHangUp];
            }
        }
    });
}

- (VideoCallModel *)generateModel:(VideoCallAction)action {
    VideoCallModel* model = [self.curLastModel copy];
    model.action = action;
    return model;
}

- (void)sendModel:(NSString *)userID action:(VideoCallAction)action model:(VideoCallModel *)model {
    if (userID.length <= 0) {
        return;
    }
    VideoCallModel *realModel = [self generateModel:action];
    BOOL isGroup = [self.curGroupID isEqualToString:userID];
    if (model) {
        realModel = [model copy];
        realModel.action = action;
        if (model.groupid) {
            isGroup = YES;
        }
    }
    void(^deferBlock)(void) = ^{
        if (realModel.action != VideoCallActionReject &&
            realModel.action != VideoCallActionHangup &&
            realModel.action != VideoCallActionSponsorCancel &&
            model == nil) {
            self.curLastModel = [realModel copy];
        }
    };
    NSData *data = [VideoCallUtils callModelToData:realModel];
    if (!data) {
        deferBlock();
        return;
    }
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:data];
    V2TIMOfflinePushInfo *pushInfo = [[V2TIMOfflinePushInfo alloc] init];
    if (realModel.action == VideoCallActionDialing) {
        pushInfo.desc = @"您收到一个视频通话请求";
        pushInfo.iOSSound = @"00.caf";
    }
    if (isGroup) {
        @weakify(self)
        [[V2TIMManager sharedInstance] sendMessage:msg
                                          receiver:nil
                                           groupID:realModel.groupid
                                          priority:V2TIM_PRIORITY_NORMAL
                                    onlineUserOnly:NO
                                   offlinePushInfo:pushInfo
                                          progress:nil
                                              succ:nil
                                              fail:^(int code, NSString *desc) {
            @strongify(self)
            if (!self) {
                return;
            }
            if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                [self.delegate onError:code msg:desc];
            }
        }];
    } else {
        @weakify(self)
        [[V2TIMManager sharedInstance] sendMessage:msg
                                          receiver:userID
                                           groupID:nil
                                          priority:V2TIM_PRIORITY_NORMAL
                                    onlineUserOnly:NO
                                   offlinePushInfo:pushInfo
                                          progress:nil
                                              succ:nil
                                              fail:^(int code, NSString *desc) {
            @strongify(self)
            if (!self) {
                return;
            }
            if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                [self.delegate onError:code msg:desc];
            }
        }];
    }
    TRTCLog(@"send message to %@: call_id:%@, room_id:%u, action:%ld", userID, realModel.callid, (unsigned int)realModel.roomid, realModel.action);
    deferBlock();
}

/// handle new call model
/// - Parameters:
///   - user: message's sender
///   - model: call model which have been sent
///   - leftTime: the time left for user to make response
- (void)handleCallModelWithSender:(NSString *)user model:(VideoCallModel *)model leftTime:(double)leftTime {
    if (model.groupid.length <= 0) {
        model.groupid = nil;
    }
    void(^syncInvitingList)(void) = ^{
        if (self.curGroupID) {
            for (NSString *userID in model.invitedList) {
                if ([userID isEqualToString:[VideoCallUtils curUserId]]) {
                    continue;
                }
                if (![self.curInvitiingList containsObject:userID]) {
                    [self.curInvitiingList addObject:userID];
                    [self checkTimeOut:userID time:leftTime];
                }
            }
        }
    };
    switch (model.action) {
        case VideoCallActionDialing:
        {
            if (model.groupid && ![model.invitedList containsObject:[VideoCallUtils curUserId]]) {
                // 群聊但是邀请不包含自己
                if ([self.curCallID isEqualToString:model.callid]) {
                    syncInvitingList();
                    if (self.curInvitiingList.count > 0 && [self canDelegateRespondMethod:@selector(onGroupCallInviteeListUpdate:)]) {
                        [self.delegate onGroupCallInviteeListUpdate:self.curInvitiingList];
                    }
                }
                return;
            }
            if (self.isOnCalling) {
                // tell busy
                if (![model.callid isEqualToString:self.curCallID]) {
                    [self sendModel:model.groupid ?: user action:VideoCallActionLinebusy model:model];
                }
            } else {
                self.isOnCalling = YES;
                self.curCallID = model.callid;
                self.curRoomID = model.roomid;
                if (model.groupid && model.groupid.length > 0) {
                    self.curGroupID = model.groupid;
                }
                self.curType = model.calltype;
                self.curSponsorForMe = user;
                syncInvitingList();
                if ([self canDelegateRespondMethod:@selector(onInvited:userIds:isFromGroup:)]) {
                    [self.delegate onInvited:user userIds:model.invitedList isFromGroup:self.curGroupID ? YES : NO];
                }
                self.checkTimeID = [VideoCallUtils generateRoomID];
                NSString *cid = self.curCallID;
                UInt32 checkID = self.checkTimeID;
                @weakify(self)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(leftTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @strongify(self)
                    if (!self) {
                        return;
                    }
                    if ([cid isEqualToString:self.curCallID] &&
                        checkID == self.checkTimeID &&
                        !self.isRespSponsor) {
                        self.isOnCalling = NO;
                        if ([self canDelegateRespondMethod:@selector(onCallingTimeOut)]) {
                            [self.delegate onCallingTimeOut];
                        }
                    }
                });
            }
        }
            break;
        case VideoCallActionSponsorCancel:
        {
            if ([self.curCallID isEqualToString:model.callid]) {
                self.isOnCalling = NO;
                if ([self canDelegateRespondMethod:@selector(onCallingCancel)]) {
                    [self.delegate onCallingCancel];
                }
            }
        }
            break;
        case VideoCallActionReject:
        {
            if ([self.curCallID isEqualToString:model.callid]) {
                [self.curInvitiingList removeObject:user];
                if ([self canDelegateRespondMethod:@selector(onReject:)]) {
                    [self.delegate onReject:user];
                }
                [self checkAutoHangUp];
            }
        }
            break;
        case VideoCallActionSponsorTimeout:
        {
            if ([self.curCallID isEqualToString:model.callid]) {
                self.isOnCalling = NO;
                if ([self canDelegateRespondMethod:@selector(onCallingTimeOut)]) {
                    [self.delegate onCallingTimeOut];
                }
                [self checkAutoHangUp];
            }
        }
            break;
        case VideoCallActionHangup:
            break;
        case VideoCallActionLinebusy:
        {
            if ([self.curCallID isEqualToString:model.callid]) {
                [self.curInvitiingList removeObject:user];
                if ([self canDelegateRespondMethod:@selector(onLineBusy:)]) {
                    [self.delegate onLineBusy:user];
                }
                [self checkAutoHangUp];
            }
        }
            break;
        case VideoCallActionError:
        {
            if ([self.curCallID isEqualToString:model.callid]) {
                [self.curInvitiingList removeObject:user];
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:-1 msg:@"系统错误"];
                }
                [self checkAutoHangUp];
            }
        }
            break;
        default:
            break;
    }
    if (self.curCallID == model.callid) {
        self.curLastModel = [model copy];
    }
}

- (void)setupAPNS {
    V2TIMAPNSConfig *config = [[V2TIMAPNSConfig alloc] init];
    config.businessID = self.imBusinessID;
    config.token = self.deviceToken;
    [[V2TIMManager sharedInstance] setAPNS:config succ:^{
        TRTCLog(@"-----> 上传 token 成功");
    } fail:^(int code, NSString *desc) {
        TRTCLog(@"-----> 上传 token 失败");
    }];
}

@end
