//
//  TRTCAudioCallModelDef.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/16.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCAudioCallModelDef.h"
#import <MJExtension/MJExtension.h>

@implementation AudioCallModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.version = audioCallVersion;
        self.calltype = AudioCallTypeUnknown;
        self.groupid = nil;
        self.callid = @"";
        self.roomid = 0;
        self.action = AudioCallActionUnknown;
        self.code = 0;
        self.invitedList = @[];
    }
    return self;
}

- (id)copy {
    AudioCallModel *model = [[AudioCallModel alloc] init];
    model.version = self.version;
    model.calltype = self.calltype;
    model.groupid = self.groupid;
    model.callid = self.callid;
    model.roomid = self.roomid;
    model.action = self.action;
    model.code = self.code;
    model.invitedList = self.invitedList;
    return model;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"calltype" : @"call_type",
        @"groupid" : @"group_id",
        @"callid" : @"call_id",
        @"roomid" : @"room_id",
        @"invitedList" : @"invited_list"
    };
}

@end
