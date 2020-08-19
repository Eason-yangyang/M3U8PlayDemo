//
//  BUM3U8ListAnalysis.m
//  M3U8Demo
//
//  Created by bytedance on 2020/8/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "BUM3U8ListAnalysis.h"

@implementation BUM3U8ListAnalysis

+ (void)analysisWithUrlString:(NSString *)urlString targetDuration:(NSInteger)targetDuration block:(nonnull AnalysisBlock)block {
    __weak typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [weakSelf findTs:dataStr targetDuration:targetDuration block:block];
    }];
    [task resume];
}

+ (void)findTs:(NSString *)dataString targetDuration:(NSInteger)targetDuration block:(AnalysisBlock)block {
    //获取单片长度
    float tsDuration = (float)targetDuration;
    NSString *regex = @"#EXT-X-TARGETDURATION:.*\n";
    NSRange range = [dataString rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        // 找到
        tsDuration = [[dataString substringWithRange:NSMakeRange(range.location+regex.length-3, range.length-regex.length+2)] floatValue];
    }else{
        //未找到
        NSString *regex = @"#EXTINF:.*,";
        NSRange range = [dataString rangeOfString:regex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            tsDuration = [[dataString substringWithRange:NSMakeRange(range.location+regex.length-3, range.length-regex.length+2)] floatValue];
        }
    }
    //限制片数
    NSMutableString *m3u8String = [[NSMutableString alloc]init];
    NSMutableArray *tsArr = [[NSMutableArray alloc]init];
    NSArray *arr = [dataString componentsSeparatedByString:@"\n"];
    NSInteger number = (NSInteger)roundf(targetDuration/tsDuration);
    for (int i = 0; i < arr.count; i++) {
        NSString *str = [arr objectAtIndex:i];
        if ([str containsString:@".ts"]) {
            [tsArr addObject:str];
        } else if ([str hasPrefix:@"#"] && ![str hasPrefix:@"#EXTINF"]) {
            [m3u8String appendString:str];
            [m3u8String appendString:@"\n"];
        }
    }
    [tsArr sortUsingComparator:^NSComparisonResult(NSString *_Nonnull obj1, NSString *_Nonnull obj2) {
        return[obj1 compare:obj2];
    }];
    if (number < tsArr.count) {
        [tsArr removeObjectsInRange:NSMakeRange(number, tsArr.count-number)];
    }
//    for (int i = 0; i < tsArr.count; i++) {
//        [m3u8String appendFormat:@"#EXTINF:%f,\n%@\n",tsDuration,[tsArr objectAtIndex:i]];
//    }
//    [m3u8String appendString:@"#EXT-X-ENDLIST"];
    block([tsArr copy],[m3u8String copy]);
}

@end
