//
//  BUM3U8DownloaderModel.h
//  M3U8Demo
//
//  Created by bytedance on 2020/8/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kBUM3U8Downloader @"BUM3U8Downloader"

@class BUM3U8Downloader;

@protocol BUM3U8DownloaderDelegate <NSObject>
@optional
- (void)buM3U8downloader:(BUM3U8Downloader *)downloader tsFileDownloadSuccess:(NSString *)ts;
- (void)buM3U8downloader:(BUM3U8Downloader *)downloader tsFileDownloadFailed:(NSString *)ts;
- (void)buM3U8downloader:(BUM3U8Downloader *)downloader
                  tsFile:(NSString *)ts
            didWriteData:(int64_t)bytesWritten
       totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
@end

@interface BUM3U8Downloader : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *tsArray;
@property (nonatomic, weak) id<BUM3U8DownloaderDelegate> delegate;
- (instancetype)initWithDomain:(NSString *)domain name:(NSString *)name tsArray:(NSArray *)tsArray;
- (void)downlodFirstTSFile;
- (void)downlodAllTSFile;
@end

NS_ASSUME_NONNULL_END
