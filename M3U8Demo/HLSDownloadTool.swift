//
//  HLSDownloadTool.swift
//  M3U8Demo
//
//  Created by bytedance on 2020/8/14.
//  Copyright © 2020 bytedance. All rights reserved.
//

import Foundation
import AVFoundation

class HLSDownloadTool:NSObject {
    private var downloadSession:AVAssetDownloadURLSession!
    private var downloadTask:AVAggregateAssetDownloadTask!
    override init() {
        super.init();
    }
    
    init(ts:String) {
        super.init();
        let assetURL = URL(string: "http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8");
        let asset = AVURLAsset(url: assetURL!);
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "assetDownloadConfigurationIdentifier");
        downloadSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main);
        downloadTask = downloadSession.aggregateAssetDownloadTask(with: asset, mediaSelections: asset.allMediaSelections, assetTitle: ts, assetArtworkData: nil, options: nil);
        startDownloadHLSFile(url: "");
    }
    init (a:String,b:String) {
        super.init();
    }
    
    func startDownloadHLSFile(url:String) -> Void {
        downloadTask.resume();
    }
    func hahaha() -> Void {
        
    }
}
extension HLSDownloadTool: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL){
        NSLog("");
    }
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange){
        NSLog("");
    }
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didResolve resolvedMediaSelection: AVMediaSelection){
        NSLog("");
    }
    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, willDownloadTo location: URL){
        NSLog("");
    }
    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, didCompleteFor mediaSelection: AVMediaSelection){
        NSLog("");
    }
    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange, for mediaSelection: AVMediaSelection){
        NSLog("");
    }
}

