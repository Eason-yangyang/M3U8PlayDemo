//
//  BUM3U8ListFile.h
//  M3U8Demo
//
//  Created by bytedance on 2020/8/20.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BUM3U8ListFile : NSObject
@property (nonatomic, copy, readonly) NSString *m3u8Header;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *tsDuration;
- (instancetype)initWithM3u8Header:(NSString *)m3u8Header name:(NSString *)name tsDuration:(nonnull NSString *)tsDuration;
- (void)addNewM3U8tsfile:(NSString *)tsName isEndTs:(BOOL)isEndTs;
- (NSData *)getM3U8FileData;
@end

NS_ASSUME_NONNULL_END
