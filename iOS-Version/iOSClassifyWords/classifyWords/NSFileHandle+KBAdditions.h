//
//  NSFileHandle+KBAdditions.h
//  KeyboardApp
//
//  Created by Li ChangMing on 14-8-16.
//  Copyright (c) 2014年 ziipin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileHandle (KBAdditions)
- (NSString *)kb_readLine;
- (NSString *)kb_readTrimmedLine;
- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block;
- (void) enumerateTrimmedLinesUsingBlock:(void(^)(NSString*, BOOL*))block;
@end