//
//  VideoCallUtils.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/22.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "VideoCallUtils.h"
#import <MJExtension/MJExtension.h>
#import "TRTCVideoCallModelDef.h"
#import <ImSDK/ImSDK.h>

@implementation VideoCallUtils

+ (VideoCallModel *)dataToCallModel:(NSData *)data {
    if (!data) {
        return nil;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return [VideoCallModel mj_objectWithKeyValues:json];
}

+ (NSData *)callModelToData:(VideoCallModel *)model {
    return [model mj_JSONData];
}

+ (NSString *)randomStr:(NSInteger)len {
    NSString *sourceStr = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    for (int i = 0; i < len; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

+ (NSString *)curUserId {
    NSString* userID = [[V2TIMManager sharedInstance] getLoginUser];
    if (userID) {
        return userID;
    }
    return [VideoCallUtils randomStr:5];
}

+ (NSString *)generateCallID {
    NSString *imVersion = [[TIMManager sharedInstance] GetVersion];
    return [NSString stringWithFormat:@"%@-%@-%@", imVersion ?: @"0.0.1", [VideoCallUtils curUserId], [VideoCallUtils randomStr:32]];
}

+ (UInt32)generateRoomID {
    return arc4random() % (UINT32_MAX / 2 - 1);
}

@end
