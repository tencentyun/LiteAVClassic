//
//  TRTCVideoCall.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/22.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCVideoCallDelegate.h"
#import "TRTCVideoCallModelDef.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^VideoCallback)(void);
typedef void(^VideoErrorCallback)(int code, NSString *des);

@interface TRTCVideoCall : NSObject

/// 语音通话的代理回调
@property (nonatomic, weak) id<TRTCVideoCallDelegate> delegate;

/// 当前是否静音
@property (nonatomic, assign) BOOL isMicMute;

/// 当前是否开启免提
@property (nonatomic, assign, setter=setHandsFree:) BOOL isHandsFreeOn;

/// IM APNS推送ID
@property (nonatomic, assign) int imBusinessID;

/// 推送DeviceToken，需要在调用登录之前设置，否则APNS推送会设置失败
@property (nonatomic, strong) NSData *deviceToken;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 单例方法
+ (instancetype)sharedInstance
NS_SWIFT_NAME(shared());

#pragma mark - life-cycle
/// 初始化函数，请在使用所有功能之前先调用该函数进行必要的初始化
- (void)setup;

/// 销毁函数，如果不需要再运行该实例，请调用该接口
- (void)destroy;

#pragma mark - login
/// 登录IM接口，所有功能需要先进行登录后才能使用
/// - Parameters:
///   - sdkAppID: TRTC SDK AppID
///   - user: 用户名
///   - userSig: 用户签名
///   - success: 成功回调
///   - failed: 失败回调
- (void)login:(UInt32)sdkAppID
         user:(NSString *)userID
      userSig:(NSString *)userSig
      success:(VideoCallback _Nullable)success
       failed:(VideoErrorCallback _Nullable)failed
NS_SWIFT_NAME(login(sdkAppID:user:suerSig:success:failed:));

/// 登出接口，登出后无法再进行拨打操作
/// - Parameters:
///   - success: 成功回调
///   - failed: 失败回调
- (void)logout:(VideoCallback _Nullable)success
        failed:(VideoErrorCallback)failed
NS_SWIFT_NAME(logout(success:failed:));

#pragma mark - call
/// c2c通话邀请
/// - Parameters:
///   - userID: 用户ID | userID
- (void)call:(NSString *)userID
        type:(VideoCallType)type
NS_SWIFT_NAME(call(userID:type:));

/// 群聊通话邀请
/// - Parameters:
///   - userIDs: 用户ID列表 | userIDs
///   - groupID: 群组ID | groupID
/// - Note:
///    IM群组邀请通话，被邀请方会收到 onInvited 回调
///    如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到 onGroupCallInviteeListUpdate 回调
- (void)groupCall:(NSArray<NSString *> *)userIDs
             type:(VideoCallType)type
          groupID:(NSString * _Nullable)groupID
NS_SWIFT_NAME(groupCall(userIDs:type:groupID:));

/// 接受当前通话 |
///  accept current call
/// - Note:
///    当您作为被邀请方收到 onInvited 的回调时，可以调用该函数接听来电
- (void)accept;

/// 拒绝当前通话 |
///  reject cunrrent call
/// - Note:
///    当您作为被邀请方收到 onInvited 的回调时，可以调用该函数拒绝来电
- (void)reject;

/// 挂断当前通话如果多人通话中有人未应答就发送取消 |
/// In a multi-person call a cancel message will be sent if there have user who not respond
/// - Note:
///    当您处于通话中，可以调用该函数结束通话
- (void)hangup;

#pragma mark - Device
/// 当您收到 onUserVideoAvailable 回调时，可以调用该函数将远端用户的摄像头数据渲染到指定的 UIView 中
   /// - Parameters:
   ///   - userId: 远端用户id
   ///   - view: 远端用户数据将渲染到该view中
- (void)startRemoteView:(NSString *)userId
                   view:(UIView *)view
NS_SWIFT_NAME(startRemoteView(userId:view:));

/// 当您收到 onUserVideoAvailable 回调为false时，可以停止渲染数据
/// - Parameter userId: 远端用户id
- (void)stopRemoteView:(NSString *)userId
NS_SWIFT_NAME(stopRemoteView(userId:));

/// 您可以调用该函数开启摄像头，并渲染在指定的 UIView 中
/// - Parameters:
///   - frontCamera: 是否开启前置摄像头
///   - view: 摄像头的数据将渲染到该view中
- (void)openCamera:(BOOL)frontCamera view:(UIView *)view
NS_SWIFT_NAME(openCamera(frontCamera:view:));

/// 您可以调用该函数关闭摄像头
/// 处于通话中的用户会收到 onUserVideoAvailable 回调
- (void)closeCamara;

/// 您可以调用该函数切换前后摄像头
/// - Parameter frontCamera: true:切换前置摄像头 false:切换后置摄像头
- (void)switchCamera:(BOOL)frontCamera
NS_SWIFT_NAME(switchCamera(frontCamera:));

/// isMute true:麦克风关闭 false:麦克风打开 |
/// isMute true:micphone will be closed  false:micphone will be open
- (void)setMicMute:(BOOL)isMute
NS_SWIFT_NAME(setMicMute(isMute:));

/// isHandsFree true:开启免提 false:关闭免提 |
/// isHandsFree true:Hands Free false:Headset
- (void)setHandsFree:(BOOL)isHandsFree
NS_SWIFT_NAME(setHandsFree(isHandsFree:));

@end

NS_ASSUME_NONNULL_END
