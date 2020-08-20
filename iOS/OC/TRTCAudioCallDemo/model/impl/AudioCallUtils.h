//
//  AudioCallUtils.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/16.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AudioCallModel;
@interface AudioCallUtils : NSObject

+ (AudioCallModel * _Nullable)dataToCallModel:(NSData *)data;

+ (NSData *)callModelToData:(AudioCallModel *)model;

+ (NSString *)randomStr:(NSInteger)len;

+ (NSString *)curUserId;

+ (NSString *)generateCallID;

+ (UInt32)generateRoomID;

@end

NS_ASSUME_NONNULL_END
