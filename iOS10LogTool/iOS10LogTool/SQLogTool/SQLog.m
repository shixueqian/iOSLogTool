//
//  SQLog.m
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//

#import "SQLog.h"
#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>

//设置默认记录的日志等级为LOGLEVELD。
static SQLogLevel LogLevel = LOGLEVELD;

//log文件路径
static NSString *logFilePath = nil;
//log目录路径
static NSString *logDir      = nil;


// 打印队列
static dispatch_once_t logQueueCreatOnce;
static dispatch_queue_t k_operationQueue;


@interface SQLog(privatedMethod)
+ (void)logvLevel:(SQLogLevel)level Format:(NSString*)format VaList:(va_list)args;
+ (NSString*)SQLogFormatPrefix:(SQLogLevel)logLevel;
@end



@implementation SQLog

#pragma mark - 初始化

+ (void)logIntial
{
    if (!logFilePath)
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *logDirectory       = [documentsDirectory stringByAppendingString:@"/log/"];
        
        //创建log文件夹
        if (![[NSFileManager defaultManager] fileExistsAtPath:logDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:logDirectory
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        logDir   = logDirectory;
        
        NSString *fileName = [NSString stringWithFormat:@"SQ_log.txt"];
        NSString *filePath = [logDirectory stringByAppendingPathComponent:fileName];
        
        logFilePath = filePath;
#if DEBUG
        NSLog(@"LogPath: %@", logFilePath);
#endif
        
        //创建log文件
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            NSString *initString = @"log初始化。。。\n";
            [initString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }
        
    }
    
    dispatch_once(&logQueueCreatOnce, ^{
        //创建串行队列
        k_operationQueue =  dispatch_queue_create("com.shixueqian.app.operationqueue", DISPATCH_QUEUE_SERIAL);
    });
}

#pragma mark -  获取log文件的路径

+ (NSString *)getLogFilePath
{
    return logFilePath;
}

#pragma mark -  设置要记录的log级别

+ (void)setLogLevel:(SQLogLevel)level
{
    LogLevel = level;
}

#pragma mark -  获取log文件的路径
//根据logLevel返回前缀
+ (NSString*)SQLogFormatPrefix:(SQLogLevel)logLevel
{
    NSString *logLevelString = @"";
    switch (logLevel)
    {
        case LOGLEVELV: logLevelString = @"VEND";   break;
        case LOGLEVELD: logLevelString = @"DEBUG";  break;
        case LOGLEVELI: logLevelString = @"INFO";   break;
        case LOGLEVELW: logLevelString = @"WARNING";break;
        case LOGLEVELE: logLevelString = @"ERROR";  break;
    }
    
    return [NSString stringWithFormat:@"[%@] ", logLevelString];
}

#pragma mark - 写入log文件

+ (void)logvLevel:(SQLogLevel)level Format:(NSString *)format VaList:(va_list)args
{
    __block NSString *formatTmp = format;
    
    dispatch_async(k_operationQueue, ^{//异步串行队列
        
        if (level >= LogLevel)//只有大于当前LogLevel级别的log才会进行操作
        {
            formatTmp = [[SQLog SQLogFormatPrefix:level] stringByAppendingString:formatTmp];
            //写入log文件的同时，在控制台打印出来
            NSLog(@"%@",formatTmp);
            
            NSString *contentStr = [[NSString alloc] initWithFormat:formatTmp arguments:args];
            NSString *contentN = [contentStr stringByAppendingString:@"\n"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            //设置为北京时间
            NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];//直接指定时区，这里是东8区
            NSInteger seconds = [timeZone secondsFromGMTForDate: [NSDate date]];
            NSDate *beiJingDate = [NSDate dateWithTimeInterval: seconds sinceDate: [NSDate date]];
            
            //这里是最终打印出来的字符串，可以根据需要加一些参数进去
            NSString *content = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:beiJingDate], contentN];
            
            //使用NSFileHandle来写入数据
            NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath];
            [file seekToEndOfFile];
            [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            [file closeFile];
            
            formatTmp = nil;
        }
        
    });
}


+ (void)logLevel:(SQLogLevel)level LogInfo:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [SQLog logvLevel:level Format:format VaList:args];
    va_end(args);
}

+ (void)logV:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [SQLog logvLevel:LOGLEVELV Format:format VaList:args];
    va_end(args);
}

+ (void)logD:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [SQLog logvLevel:LOGLEVELD Format:format VaList:args];
    va_end(args);
}

+ (void)logI:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [SQLog logvLevel:LOGLEVELI Format:format VaList:args];
    va_end(args);
}

+ (void)logW:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [SQLog logvLevel:LOGLEVELW Format:format VaList:args];
    va_end(args);
}

+ (void)logE:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [SQLog logvLevel:LOGLEVELE Format:format VaList:args];
    va_end(args);
}

@end
