//
//  BUM3U8ListFile.m
//  M3U8Demo
//
//  Created by bytedance on 2020/8/20.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "BUM3U8ListFile.h"

@interface BUM3U8ListFile ()
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) NSFileManager *fileM;
@property (nonatomic, copy) NSString *filePath;
@property (atomic, assign) BOOL needRefreshFile;
@end

@implementation BUM3U8ListFile

- (instancetype)initWithM3u8Header:(NSString *)m3u8Header name:(NSString *)name tsDuration:(NSString *)tsDuration {
    if (self = [super init]) {
        _m3u8Header = m3u8Header;
        _name = name;
        _tsDuration = tsDuration;
        NSString *regex = @"#EXT-X-MEDIA-SEQUENCE:.*\n";
        NSRange range = [_m3u8Header rangeOfString:regex options:NSRegularExpressionSearch];
        if (range.location == NSNotFound) {
            _m3u8Header = [_m3u8Header stringByAppendingString:@"\n#EXT-X-MEDIA-SEQUENCE:1\n"];
        }
        
        _ioQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.M3U8FILE.Queue.%@",kBUM3U8Downloader,_name]cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT_WITH_AUTORELEASE_POOL);
        
        _fileM = [NSFileManager defaultManager];
        NSString *firstPath = [KBUM3U8SaveMainPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",kBUM3U8Downloader]];
        NSString *secondPath = [firstPath stringByAppendingPathComponent:self.name];
        NSString *thirdPath = [secondPath stringByAppendingPathComponent:kBUM3U8Playlist];
        _filePath = thirdPath;
        if (![_fileM fileExistsAtPath:firstPath]) {
            [_fileM createDirectoryAtPath:firstPath withIntermediateDirectories:YES attributes:@{NSFileCreationDate:[NSDate date]} error:nil];
        }
        if (![_fileM fileExistsAtPath:secondPath]) {
            [_fileM createDirectoryAtPath:secondPath withIntermediateDirectories:YES attributes:@{NSFileCreationDate:[NSDate date]} error:nil];
        }
        if (![_fileM fileExistsAtPath:thirdPath]) {
            [_fileM createFileAtPath:thirdPath contents:[[_m3u8Header copy] dataUsingEncoding:NSUTF8StringEncoding] attributes:@{NSFileCreationDate:[NSDate date]}];
        }
        
        _needRefreshFile = NO;
        return self;
    }
    return nil;
}
//z新增
- (void)addNewM3U8tsfile:(NSString *)tsName isEndTs:(BOOL)isEndTs {
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(_ioQueue, ^{
        NSData *data = [NSData dataWithContentsOfFile:weakSelf.filePath];
        if (!self.needRefreshFile) {
            NSMutableString *m3u8String = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [weakSelf appendFileIsEndTs:isEndTs tsName:tsName headerString:m3u8String];
        } else {
            [weakSelf updateHeader];
            NSMutableString *m3u8String = [[NSMutableString alloc]initWithString:self.m3u8Header];
            [weakSelf appendFileIsEndTs:isEndTs tsName:tsName headerString:m3u8String];
        }
        self.needRefreshFile = NO;;
    });
}
//更新header
- (void)updateHeader {
    NSString *regex = @"#EXT-X-MEDIA-SEQUENCE:.*\n";
    NSRange range = [self.m3u8Header rangeOfString:regex options:NSRegularExpressionSearch];
    int a = 0;
    if (range.location != NSNotFound) {
        a = [[self.m3u8Header substringWithRange:NSMakeRange(range.location+regex.length-3, range.length-regex.length+2)] intValue];
    }
    [self.m3u8Header stringByReplacingCharactersInRange:NSMakeRange(range.location+regex.length-3, range.length-regex.length+2) withString:[NSString stringWithFormat:@"%d",++a]];
}
//拼接
- (void)appendFileIsEndTs:(BOOL)isEndTs tsName:(NSString *)tsName headerString:(NSMutableString *)m3u8String {
    [m3u8String appendFormat:@"\n#EXTINF:%@,\n%@",self.tsDuration?self.tsDuration:@"8.0",tsName];
    if (isEndTs) {
        [m3u8String appendString:@"#EXT-X-ENDLIST"];
    }
    [[m3u8String copy] writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
//获取
- (NSData *)getM3U8FileData {
    self.needRefreshFile = YES;
    __weak typeof(self) weakSelf = self;
    __block NSData *data = nil;
    dispatch_sync(self.ioQueue, ^{
        data = [NSData dataWithContentsOfFile:weakSelf.filePath];
    });
    return data;
}
@end
