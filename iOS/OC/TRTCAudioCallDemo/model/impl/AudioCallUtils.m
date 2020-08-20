//
//  AudioCallUtils.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/16.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "AudioCallUtils.h"
#import <MJExtension/MJExtension.h>
#import "TRTCAudioCallModelDef.h"
#import <ImSDK/ImSDK.h>

@implementation AudioCallUtils

+ (AudioCallModel *)dataToCallModel:(NSData *)data {
    if (data) {
        return nil;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return [AudioCallModel mj_objectWithKeyValues:json];
}

+ (NSData *)callModelToData:(AudioCallModel *)model {
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
    return [AudioCallUtils randomStr:5];
}

+ (NSString *)generateCallID {
    NSString *imVersion = [[TIMManager sharedInstance] GetVersion];
    return [NSString stringWithFormat:@"%@-%@-%@", imVersion ?: @"0.0.1", [AudioCallUtils curUserId], [AudioCallUtils randomStr:32]];
}

+ (UInt32)generateRoomID {
    return arc4random() % (UINT32_MAX / 2 - 1);
}

@end
