//
//  BUM3U8Object.h
//  M3U8Demo
//
//  Created by bytedance on 2020/8/20.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUM3U8Downloader.h"
#import "BUM3U8ListFile.h"

NS_ASSUME_NONNULL_BEGIN
@class BUM3U8FileManager;
@protocol BUM3U8FileManagerDelegate <NSObject>
@optional
- (void)buM3U8FileManager:(BUM3U8FileManager *)fileManager tsFileDownloadSuccess:(NSString *)ts;
- (void)buM3U8FileManager:(BUM3U8FileManager *)fileManager tsFileDownloadFailed:(NSString *)ts;
- (void)buM3U8FileManager:(BUM3U8FileManager *)fileManager
                  tsFile:(NSString *)ts
            didWriteData:(int64_t)bytesWritten
       totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
@end

@interface BUM3U8FileManager : NSObject
@property (nonatomic, weak) id<BUM3U8FileManagerDelegate> delegate;
@property (nonatomic, strong, readonly) BUM3U8ListFile *listFile;
@property (nonatomic, strong, readonly) BUM3U8Downloader *downloader;
- (instancetype)initM3U8FileDomain:(nonnull NSString *)domain name:(nonnull NSString *)name tsArray:(nonnull NSArray *)tsArray m3u8Header:(nonnull NSString *)m3u8Header tsDuration:(nonnull NSString *)tsDuration;
- (NSData *)getM3U8FileData;
@end

NS_ASSUME_NONNULL_END
