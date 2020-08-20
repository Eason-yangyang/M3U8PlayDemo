//
//  BUM3U8Downloader.m
//  M3U8Demo
//
//  Created by bytedance on 2020/8/19.
//  Copyright © 2020 bytedance. All rights reserved.
//



#import "BUM3U8DownloaderManager.h"

@interface BUM3U8DownloaderManager ()

@end

@implementation BUM3U8DownloaderManager

+ (instancetype)shareLoader {
    static BUM3U8DownloaderManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        shareManager = [[super allocWithZone:NULL] init];
    });
    return shareManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [BUM3U8DownloaderManager shareLoader];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [BUM3U8DownloaderManager shareLoader];
}

//- (void)


@end
