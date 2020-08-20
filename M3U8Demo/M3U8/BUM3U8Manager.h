//
//  BUM3U8Downloader.h
//  M3U8Demo
//
//  Created by bytedance on 2020/8/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUM3U8FileManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BUM3U8ManagerDelegate <NSObject>
@optional
- (void)m3u8FileCouldPlay:(NSString *)name;
@end

@interface BUM3U8Manager : NSObject
@property (nonatomic, weak) id<BUM3U8ManagerDelegate> delegate;
+ (instancetype)shareLoader;
- (void)creatNewM3U8FileDomain:(NSString *)domain
                          name:(NSString *)name
                       tsArray:(NSArray *)tsArray
                    m3u8Header:(NSString *)m3u8Header
                    tsDuration:(NSString *)tsDuration;
- (NSData *)getM3U8FileDataWithName:(NSString *)name;
- (NSData *)getM3U8TSFileDataWithPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
