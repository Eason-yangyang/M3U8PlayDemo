//
//  BUM3U8ListAnalysis.h
//  M3U8Demo
//
//  Created by bytedance on 2020/8/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AnalysisBlock)(NSArray *data,NSString *m3u8HeaderString);

@interface BUM3U8ListAnalysis : NSObject
+ (void)analysisWithUrlString:(NSString *)urlString targetDuration:(NSInteger)targetDuration block:(AnalysisBlock)block;
@end

NS_ASSUME_NONNULL_END
