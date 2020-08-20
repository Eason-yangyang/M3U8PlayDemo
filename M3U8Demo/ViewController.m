//
//  ViewController.m
//  M3U8Demo
//
//  Created by bytedance on 2020/8/10.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "ViewController.h"
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "M3U8Demo-Swift.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "FFmpegManager.h"
#import "HTTPServer.h"
#import "BUM3U8ListAnalysis.h"

//#define kM3U8Domain @"http://pull-hls-f5.douyincdn.com/stage/stream-683688517054759013_or4"
//playlist.m3u8
#define kM3U8Domain @"http://ivi.bupt.edu.cn/hls"
#define kM3U8URI    @"cctv6hd.m3u8"


@interface ViewController ()<NSURLSessionDownloadDelegate,AVAssetDownloadDelegate,NSURLSessionDelegate>
@property (nonatomic, strong) GCDWebServer *webServer;
@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, strong) HTTPServer *httpServer2;
@property (nonatomic, copy) NSString *ts;

@property (nonatomic, strong) AVAssetDownloadURLSession *downloadSession;
@property (nonatomic, strong) AVAggregateAssetDownloadTask *downloadTask;
@property (nonatomic, strong) HLSDownloadTool *t;
@property (nonatomic, strong) NSURL *location;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UILabel *tsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) NSString *locationPath;
@property (nonatomic, assign) NSTimeInterval startInterval;

@property (nonatomic, strong) NSMutableString *m3u8HeaderString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.m3u8HeaderString = [NSMutableString new];
    //创建m3u8文件
    NSFileManager *fileM = [NSFileManager defaultManager];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bufile.m3u8"];
    if (![fileM fileExistsAtPath:path]) {
        [fileM createFileAtPath:path contents:nil attributes:nil];
    }
    //
    AVAsset *liveAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",kM3U8Domain,kM3U8URI]] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];

    _player = [AVPlayer playerWithPlayerItem:playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 9.0*[UIScreen mainScreen].bounds.size.width/16.0);
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:_playerLayer];
    [_player play];
    // Do any additional setup after loading the view.
}
- (IBAction)getTSAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [BUM3U8ListAnalysis analysisWithUrlString:[NSString stringWithFormat:@"%@/%@",kM3U8Domain,kM3U8URI] targetDuration:15 block:^(NSArray * _Nonnull data,NSString *m3u8HeaderString) {
        if (data.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tsLabel.text = data.firstObject;
            });
            [weakSelf daownloadTS:data.firstObject];
            [weakSelf.m3u8HeaderString setString:m3u8HeaderString];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakSelf daownloadTS:data.lastObject];
//            });
        }
    }];
}

- (NSString *)findTs:(NSString *)dataString {
    NSString *ts = nil;
    NSArray *arr = [dataString componentsSeparatedByString:@"\n"];
    for (NSString *str in arr) {
        if ([str containsString:@".ts"]) {
            ts = str;
            break;
        }
    }
    return ts;
}

- (void)daownloadTS:(NSString *)ts {
    _ts = ts;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.statusLabel.text = @"downloading";
    });
//    _t = [[HLSDownloadTool alloc]init];
//    [t startDownloadHLSFile:@""];
    _startInterval = [NSDate date].timeIntervalSince1970;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",kM3U8Domain,ts]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
    [task resume];
    
//    AVAssetDownloadStorageManager *manager = [AVAssetDownloadStorageManager sharedDownloadStorageManager];
//    [manager storageManagementPolicyForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ivi.bupt.edu.cn/hls/%@",@"cctv6hd.m3u8"]]];
//
//
//
//    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ivi.bupt.edu.cn/hls/%@",@"cctv6hd.m3u8"]] options:nil];
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"assetDownloadConfigurationIdentifier"];
//    _downloadSession = [AVAssetDownloadURLSession sessionWithConfiguration:config assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    _downloadTask = [_downloadSession aggregateAssetDownloadTaskWithURLAsset:asset mediaSelections:@[asset.preferredMediaSelection] assetTitle:[ts stringByDeletingPathExtension] assetArtworkData:nil options:nil];
//    [_downloadTask resume];
}

- (IBAction)playTSAction:(UIButton *)sender {
    if (!_webServer) {
        _webServer = [[GCDWebServer alloc] init];
        [_webServer addHandlerForMethod:@"GET" pathRegex:@".*pangle.*ts" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
            NSString *sub = [request.URL.absoluteString lastPathComponent];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:sub];
            return [GCDWebServerDataResponse responseWithData:[NSData dataWithContentsOfFile:path] contentType:[NSString stringWithFormat:@".%@",sub.pathExtension]];
        }];
        [_webServer addHandlerForMethod:@"GET" pathRegex:@".*m3u8" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
            NSString *sub = [request.URL.absoluteString lastPathComponent];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:sub];
            return [GCDWebServerDataResponse responseWithData:[NSData dataWithContentsOfFile:path] contentType:[NSString stringWithFormat:@".%@",sub.pathExtension]];
        }];
        [_webServer startWithPort:1111 bonjourName:@""];
    }
    AVAsset *liveAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/pangle/pangle/%@",_webServer.serverURL.absoluteString,@"bufile.m3u8"]] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
    [_player replaceCurrentItemWithPlayerItem:playerItem];
    [_player play];
}
- (IBAction)playLocalServer:(UIButton *)sender {
    if (!_httpServer) {
        _httpServer = [[HTTPServer alloc]init];
        [_httpServer setPort:1111];
        [_httpServer setDocumentRoot:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
        NSError *error;
        if(![_httpServer start:&error])
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
    }
    AVAsset *liveAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",@"http://localhost:1111",@"bufile.m3u8"]] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
    [_player replaceCurrentItemWithPlayerItem:playerItem];
    [_player play];
}
- (IBAction)playLocalServer2:(UIButton *)sender {
    if (!_httpServer2) {
        _httpServer2 = [[HTTPServer alloc]init];
        [_httpServer2 setPort:1111];
        [_httpServer2 setDocumentRoot:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
        [_httpServer2 setDomain:@"https://pangle.BU2.com"];
        NSError *error;
        if(![_httpServer2 start:&error])
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
    }
    AVAsset *liveAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",@"http://localhost:1111",@"bufile.m3u8"]] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
    [_player replaceCurrentItemWithPlayerItem:playerItem];
    [_player play];
}
- (IBAction)playAfterConvert:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    //    ffmpeg转码
    NSString *toPath = [[self.locationPath stringByDeletingPathExtension] stringByAppendingString:@".mp4"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [[FFmpegManager sharedManager]converWithInputPath:self.locationPath outputPath:toPath processBlock:^(float process) {

    } completionBlock:^(NSError *error) {
        NSLog(@"%@", [NSString stringWithFormat:@"--------%f----",[[NSDate date] timeIntervalSince1970]-time]);
        AVAsset *liveAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:toPath]];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
        [weakSelf.player replaceCurrentItemWithPlayerItem:playerItem];
        [weakSelf.player play];
    }];
}
#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"----------%s",__FUNCTION__);
    self.location = location;
//    session.
    self.locationPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:_ts];
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.locationPath] error:nil];
//    NSFileManager *fileM = [NSFileManager defaultManager];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bufile.m3u8"];
    NSString *s = [self.m3u8HeaderString copy];
    NSString *regex = @"#EXT-X-MEDIA-SEQUENCE:.*\n";
    NSRange range = [s rangeOfString:regex options:NSRegularExpressionSearch];
    int a = 0;
    if (range.location != NSNotFound) {
        a = [[s substringWithRange:NSMakeRange(range.location+regex.length-3, range.length-regex.length+2)] floatValue];
    }
    s = [s stringByReplacingCharactersInRange:NSMakeRange(range.location+regex.length-3, range.length-regex.length+2) withString:[NSString stringWithFormat:@"%d",++a]];
    
    NSString *regexD = @"#EXT-X-TARGETDURATION:.*\n";
    NSString *duration = nil;
    NSRange rangeD = [s rangeOfString:regexD options:NSRegularExpressionSearch];
    if (rangeD.location != NSNotFound) {
        // 找到
        duration = [s substringWithRange:NSMakeRange(rangeD.location+regexD.length-3, rangeD.length-regexD.length+2)];
    }
    s = [s stringByAppendingFormat:@"#EXTINF:%@,\n%@\n",duration?duration:@"8.0",_ts];
    [s writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"----------%s",__FUNCTION__);
    NSTimeInterval tt = [NSDate date].timeIntervalSince1970;
    if (totalBytesWritten == totalBytesExpectedToWrite) {
        self.statusLabel.text = [NSString stringWithFormat:@"downloaded \n%.3f s\n %lld/%lld",tt-_startInterval,totalBytesWritten,totalBytesExpectedToWrite];
    } else {
        self.statusLabel.text = [NSString stringWithFormat:@"downloading \n%.3f s\n %lld/%lld",tt-_startInterval,totalBytesWritten,totalBytesExpectedToWrite];
    }

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                      didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"----------%s",__FUNCTION__);
}




















- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location API_AVAILABLE(macos(10.15), ios(10.0)) API_UNAVAILABLE(tvos, watchos) {
    NSLog(@"----------%s",__FUNCTION__);
}
- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad API_AVAILABLE(macos(10.15), ios(9.0)) API_UNAVAILABLE(tvos, watchos) {
    NSLog(@"----------%s",__FUNCTION__);
}
- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didResolveMediaSelection:(AVMediaSelection *)resolvedMediaSelection API_AVAILABLE(macos(10.15), ios(9.0)) API_UNAVAILABLE(tvos, watchos) {
   NSLog(@"----------%s",__FUNCTION__);
}
- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask willDownloadToURL:(NSURL *)location API_AVAILABLE(macos(10.15), ios(11.0)) API_UNAVAILABLE(tvos, watchos) {
    NSLog(@"----------%s",__FUNCTION__);
    _location = location;
}
- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask didCompleteForMediaSelection:(AVMediaSelection *)mediaSelection API_AVAILABLE(macos(10.15), ios(11.0)) API_UNAVAILABLE(tvos, watchos) {
    
    NSLog(@"----------%s",__FUNCTION__);
//    AVURLAsset *a = [[AVURLAsset alloc]initWithURL:_location options:nil];
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:a];
//    _player = [AVPlayer playerWithPlayerItem:playerItem];
//    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//    _playerLayer.frame = CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 9.0*[UIScreen mainScreen].bounds.size.width/16.0);
//    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    [self.view.layer addSublayer:_playerLayer];
//    [_player play];
}
- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad forMediaSelection:(AVMediaSelection *)mediaSelection API_AVAILABLE(macos(10.15), ios(11.0)) API_UNAVAILABLE(tvos, watchos) {
 NSLog(@"----------%s",__FUNCTION__);
}


@end
