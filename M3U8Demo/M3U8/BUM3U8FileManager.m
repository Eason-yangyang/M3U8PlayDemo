//
//  BUM3U8Object.m
//  M3U8Demo
//
//  Created by bytedance on 2020/8/20.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "BUM3U8FileManager.h"

@interface BUM3U8FileManager ()<BUM3U8DownloaderDelegate>

@end

@implementation BUM3U8FileManager
- (instancetype)initM3U8FileDomain:(NSString *)domain name:(NSString *)name tsArray:(NSArray *)tsArray m3u8Header:(NSString *)m3u8Header tsDuration:(NSString *)tsDuration {
    if (self = [super init]) {
        _listFile = [[BUM3U8ListFile alloc]initWithM3u8Header:m3u8Header name:name tsDuration:tsDuration];
        _downloader = [[BUM3U8Downloader alloc]initWithDomain:domain name:name tsArray:tsArray];
        _downloader.delegate = self;
        [_downloader downlodFirstTSFile];
        return self;
    }
    return nil;
}
- (NSData *)getM3U8FileData {
    [_downloader downlodAllTSFile];
    return _listFile.getM3U8FileData;
}
- (void)buM3U8downloader:(BUM3U8Downloader *)downloader tsFileDownloadSuccess:(NSString *)ts {
    NSLog(@"下载完成----------------------%@--------------------是最后一个片吗%@---",ts,[_downloader.tsArray.lastObject isEqualToString:ts]?@"yes":@"no");
    [_listFile addNewM3U8tsfile:ts isEndTs:[_downloader.tsArray.lastObject isEqualToString:ts]];
    if ([downloader.tsArray.firstObject isEqualToString:ts]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(buM3U8FileManager:tsFileDownloadSuccess:)]) {
            [self.delegate buM3U8FileManager:self tsFileDownloadSuccess:ts];
        }
    }
}
- (void)buM3U8downloader:(BUM3U8Downloader *)downloader tsFileDownloadFailed:(NSString *)ts {
    if (self.delegate && [self.delegate respondsToSelector:@selector(buM3U8FileManager:tsFileDownloadFailed:)]) {
        [self.delegate buM3U8FileManager:self tsFileDownloadFailed:ts];
    }
}
- (void)buM3U8downloader:(BUM3U8Downloader *)downloader
                  tsFile:(NSString *)ts
            didWriteData:(int64_t)bytesWritten
       totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"开始下载----------------------%@-----------------------",ts);
    if (self.delegate && [self.delegate respondsToSelector:@selector(buM3U8FileManager:tsFile:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate buM3U8FileManager:self tsFile:ts didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}
@end
