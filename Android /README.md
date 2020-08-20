## 目录结构说明

该目录存放了 TRTC 旧版的 audiocall/videocall 两个组件，这两个组件和新的 TRTCCalling 组件不能互通

```
├─ TRTCScenesDemo // TRTC场景化Demo，包括视频通话、语音通话
|  ├─ app                   // 程序入口界面
|  ├─ debug                 // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig
|  ├─ login                 // 一个演示性质的简单登录界面
|  ├─ trtcaudiocalldemo     // 场景：音频通话，展示双人音频通话，有离线通知能力
|  ├─ trtcvideocalldemo     // 场景：视频通话，展示双人视频通话，有离线通知能力
```

doc 目录下存放了 旧版的 audiocall/videocall 两个组件的接入文档和 API 文档

## SDK 分类和下载

腾讯云 TRTC SDK 基于 LiteAVSDK 统一框架设计和实现，该框架包含直播、点播、短视频、RTC、AI美颜在内的多项功能：
- 如果您追求最小化体积增量，可以下载 TRTC 精简版：[TXLiteAVSDK_TRTC.zip](https://cloud.tencent.com/document/product/647/32689#TRTC)
- 如果您需要使用多个功能而不希望打包多个 SDK，可以下载专业版：[TXLiteAVSDK_Professional.zip](https://cloud.tencent.com/document/product/647/32689#Professional)
- 如果您已经通过腾讯云商务购买了 AI 美颜 License，可以下载企业版：[TXLiteAVSDK_Enterprise.zip](https://cloud.tencent.com/document/product/647/32689#Enterprise)

## 相关文档链接

- [SDK 的版本更新历史](https://github.com/tencentyun/TRTCSDK/releases)
- [SDK 的 API 文档](http://doc.qcloudtrtc.com/md_introduction_trtc_Android_%E6%A6%82%E8%A7%88.html)