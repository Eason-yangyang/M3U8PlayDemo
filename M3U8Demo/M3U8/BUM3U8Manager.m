//
//  BUM3U8Downloader.m
//  M3U8Demo
//
//  Created by bytedance on 2020/8/19.
//  Copyright © 2020 bytedance. All rights reserved.
//



#import "BUM3U8Manager.h"

@interface BUM3U8Manager ()<BUM3U8FileManagerDelegate>
@property (nonatomic, strong) NSMutableDictionary *m3u8Datas;
@end

@implementation BUM3U8Manager

+ (instancetype)shareLoader {
    static BUM3U8Manager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        shareManager = [[super allocWithZone:NULL] init];
        shareManager.m3u8Datas = [[NSMutableDictionary alloc]init];
    });
    return shareManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [BUM3U8Manager shareLoader];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [BUM3U8Manager shareLoader];
}

- (void)creatNewM3U8FileDomain:(NSString *)domain name:(NSString *)name tsArray:(NSArray *)tsArray m3u8Header:(NSString *)m3u8Header tsDuration:(NSString *)tsDuration {
    BUM3U8FileManager *objc = [[BUM3U8FileManager alloc]initM3U8FileDomain:domain name:name tsArray:tsArray m3u8Header:m3u8Header tsDuration:tsDuration];
    objc.delegate = self;
    [_m3u8Datas setValue:objc forKey:name];
}

- (NSData *)getM3U8FileDataWithName:(NSString *)name {
    if (!name) {
        return nil;
    }
    BUM3U8FileManager *manager = [_m3u8Datas valueForKey:name];
    return manager.getM3U8FileData;
}

- (NSData *)getM3U8TSFileDataWithPath:(NSString *)path {
    NSString *tsPath = [KBUM3U8SaveMainPath stringByAppendingString:path];
    
    return [NSData dataWithContentsOfFile:tsPath];
}

- (void)buM3U8FileManager:(BUM3U8FileManager *)fileManager tsFileDownloadSuccess:(NSString *)ts {
    if (self.delegate && [self.delegate respondsToSelector:@selector(m3u8FileCouldPlay:)]) {
        [self.delegate m3u8FileCouldPlay:fileManager.listFile.name];
    }
}
- (void)buM3U8FileManager:(BUM3U8FileManager *)fileManager tsFileDownloadFailed:(NSString *)ts {
    
}
- (void)buM3U8FileManager:(BUM3U8FileManager *)fileManager
                  tsFile:(NSString *)ts
            didWriteData:(int64_t)bytesWritten
       totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

@end
