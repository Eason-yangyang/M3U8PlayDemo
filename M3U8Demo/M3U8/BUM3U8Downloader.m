//
//  BUM3U8DownloaderModel.m
//  M3U8Demo
//
//  Created by bytedance on 2020/8/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "BUM3U8Downloader.h"

@interface BUM3U8Downloader ()<NSURLSessionDownloadDelegate>

@property (nonatomic, copy) NSString *domain;
@property (nonatomic, strong) dispatch_queue_t downloadQueue;
@property (nonatomic, strong) NSURLSession  *session;
@property (nonatomic, strong) NSMutableArray *unDownloadedArray;

@end

@implementation BUM3U8Downloader

- (instancetype)initWithDomain:(NSString *)domain name:(NSString *)name tsArray:(NSArray *)tsArray {
    if (tsArray && (self = [super init])) {
        _domain = domain;
        _name = name;
        _tsArray = [[NSArray alloc]initWithArray:tsArray];
        _downloadedNumber = 0;
        _downloadingNumber = 0;
        _downloadFailedNumber = 0;
        self.unDownloadedArray = [[NSMutableArray alloc]initWithArray:tsArray];
        return self;
    }
    return nil;
}

- (dispatch_queue_t)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.Queue.%@",kBUM3U8Downloader,self.name] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL);
    }
    return _downloadQueue;
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    }
    return _session;
}

- (void)downlodFirstTSFile {
    @synchronized (self) {
        NSString *ts = self.tsArray.firstObject;
        if ([self.unDownloadedArray containsObject:ts]) {
            [self.unDownloadedArray removeObject:ts];
            _downloadingNumber++;
            dispatch_async(self.downloadQueue, ^{
                NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.domain,ts]]];
                [task resume];
            });
        }
    }
}

- (void)downlodAllTSFile {
    @synchronized (self) {
        for (int i = 0;i < _tsArray.count; i++) {
            NSString *ts = [_tsArray objectAtIndex:i];
            if ([self.unDownloadedArray containsObject:ts]) {
                [self.unDownloadedArray removeObject:ts];
                _downloadingNumber++;
                dispatch_async(self.downloadQueue, ^{
                    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.domain,ts]]];
                    [task resume];
                });
            }
        }
    }
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (error) {
        _downloadFailedNumber++;
        NSString *ts = [task.originalRequest.URL.absoluteString lastPathComponent];
        if (self.delegate && [self.delegate respondsToSelector:@selector(buM3U8downloader:tsFileDownloadFailed:)]) {
            [self.delegate buM3U8downloader:self tsFileDownloadFailed:ts];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    _downloadedNumber++;
    NSString *ts = [downloadTask.originalRequest.URL.absoluteString lastPathComponent];
    NSString *path = [KBUM3U8SaveMainPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kBUM3U8Downloader,self.name,ts]];
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(buM3U8downloader:tsFileDownloadSuccess:)]) {
        [self.delegate buM3U8downloader:self tsFileDownloadSuccess:ts];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSString *ts = [downloadTask.originalRequest.URL.absoluteString lastPathComponent];
    if (self.delegate && [self.delegate respondsToSelector:@selector(buM3U8downloader:tsFile:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate buM3U8downloader:self tsFile:ts didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                      didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

@end
