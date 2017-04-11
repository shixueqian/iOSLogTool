//
//  SQLog.h
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

//目前只用到了SQLogD
//Debug
#define SQLogD(...) [SQLog logD:[NSString stringWithFormat:__VA_ARGS__],@""];
//Info
#define SQLogI(...) [SQLog logI:[NSString stringWithFormat:__VA_ARGS__],@""];
//Warning
#define SQLogW(...) [SQLog logW:[NSString stringWithFormat:__VA_ARGS__],@""];
//Error
#define SQLogE(desStr) [SQLog logE:[NSString stringWithFormat:@"Function:%s Line:%d Des:%@",__func__,__LINE__,desStr],@""];


//日志等级
typedef enum
{
    LOGLEVELV = 0,  //wend
    LOGLEVELD = 1,  //Debug
    LOGLEVELI = 2,  //Info
    LOGLEVELW = 3,  //Warning
    LOGLEVELE = 4,  //Error
} SQLogLevel;

@interface SQLog : NSObject




/**
 *  log初始化函数，在系统启动时调用
 */
+ (void)logIntial;

/**
 *  设置要记录的log级别(log显示的最低级别，低于这个级别的log不显示)
 *
 *  @param level level 要设置的log级别
 */
+ (void)setLogLevel:(SQLogLevel)level;


/**
 获取log文件的路径
 
 @return log文件的路径
 */
+ (NSString *)getLogFilePath;


///////////////////////////////////////////////////////
/**
 *  log记录函数
 *
 *  @param level  log所属的等级
 *  @param format 具体记录log的格式以及内容
 */
+ (void)logLevel:(SQLogLevel)level LogInfo:(NSString*)format,... NS_FORMAT_FUNCTION(2,3);

/**
 *  LOGLEVELV级Log记录函数
 *
 *  @param format format 具体记录log的格式以及内容
 */
+ (void)logV:(NSString*)format,... NS_FORMAT_FUNCTION(1,2);

/**
 *  LOGLEVELD级Log记录函数
 *
 *  @param format 具体记录log的格式以及内容
 */
+ (void)logD:(NSString*)format,... NS_FORMAT_FUNCTION(1,2);

/**
 *  LOGLEVELI级Log记录函数
 *
 *  @param format 具体记录log的格式以及内容
 */
+ (void)logI:(NSString*)format,... NS_FORMAT_FUNCTION(1,2);

/**
 *  LOGLEVELW级Log记录函数
 *
 *  @param format 具体记录log的格式以及内容
 */
+ (void)logW:(NSString*)format,... NS_FORMAT_FUNCTION(1,2);

/**
 *  LOGLEVELE级Log记录函数
 *
 *  @param format 具体记录log的格式以及内容
 */
+ (void)logE:(NSString*)format,... NS_FORMAT_FUNCTION(1,2);

@end
