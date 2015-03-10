//
//  NSFileHandle+KBAdditions.m
//  KeyboardApp
//
//  Created by Li ChangMing on 14-8-16.
//  Copyright (c) 2014年 ziipin. All rights reserved.
//

#import "NSFileHandle+KBAdditions.h"

#define CONN_TIMEOUT 5
#define BUFFER_SIZE 256

@implementation NSFileHandle (KBAdditions)
- (NSString *)kb_readLine {
    @autoreleasepool {
        // If the socket is closed, return an empty string
        if ([self fileDescriptor] <= 0)
            return nil;
        
        int fd = [self fileDescriptor];
        
        // Allocate BUFFER_SIZE bytes to store the line
        int bufferSize = BUFFER_SIZE;
        char *buffer = (char*)malloc(bufferSize + 1);
        if (buffer == NULL)
            [[NSException exceptionWithName:@"No memory left" reason:@"No more memory for allocating buffer" userInfo:nil] raise];
        
        ssize_t bytesReceived = 0, n = 1;
        
        while (n > 0) {
            n = read(fd, buffer + bytesReceived++, 1);
            
            if (n < 0)
                [[NSException exceptionWithName:@"Socket error" reason:@"Remote host closed connection" userInfo:nil] raise];
            
            if (bytesReceived >= bufferSize) {
                // Make buffer bigger
                bufferSize += BUFFER_SIZE;
                buffer = (char*)realloc(buffer, bufferSize + 1);
                if (buffer == NULL)
                    [[NSException exceptionWithName:@"No memory left" reason:@"No more memory for allocating buffer" userInfo:nil] raise];
            }
            
            switch (*(buffer + bytesReceived - 1)) {
                case '\n': {
                    buffer[bytesReceived-1] = '\0';
                    NSString* s = [NSString stringWithCString: buffer encoding: NSUTF8StringEncoding];
                    if ([s length] == 0)
                        s = [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding];
                    return s;
                }
                case '\r':
                    bytesReceived--;
            }
        }
        if (n == 0) {
            return nil;
        }
        
        buffer[bytesReceived-1] = '\0';
        NSString *retVal = [NSString stringWithCString: buffer  encoding: NSUTF8StringEncoding];
        if ([retVal length] == 0)
            retVal = [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding];
        
        free(buffer);
        return retVal;
    }
}


- (NSString *)kb_readTrimmedLine {
  return [[self kb_readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block {
  NSString * line = nil;
  BOOL stop = NO;
  while (stop == NO && (line = [self kb_readLine])) {
    block(line, &stop);
  }
}

- (void) enumerateTrimmedLinesUsingBlock:(void(^)(NSString*, BOOL*))block {
  NSString * line = nil;
  BOOL stop = NO;
  while (stop == NO && (line = [self kb_readTrimmedLine])) {
    block(line, &stop);
  }
}
@end