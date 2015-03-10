//
//  FullKeyboardFuzzyMatchEngine.h
//  classifyWords
//
//  Created by fengjian on 15/2/3.
//  Copyright (c) 2015年 ziipin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FullKeyboardFuzzyMatchEngine : NSObject
- (NSArray *)searchWithString:(NSString *)string;
@end
