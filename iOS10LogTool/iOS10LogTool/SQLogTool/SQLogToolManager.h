//
//  SQLogToolManager.h
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLog.h"

/**
 log显示宏定义。
 
 @param ... 可变参数，跟NSLog一致
 */
#define NSLogD(...) do{\
                        switch ([SQLogToolManager shareManager].logLevel) {\
                            case SQLogToolManagerLevelNone:{} break;\
                            case SQLogToolManagerLevelLog:{\
                                NSLog(__VA_ARGS__);} break;\
                            case SQLogToolManagerLevelText:{\
                                SQLogD(__VA_ARGS__);} break;\
                            default: break;}\
                    } while (0);


typedef enum
{
    SQLogToolManagerLevelNone = 0,     //不打印log
    SQLogToolManagerLevelLog = 1,      //只在控制台显示log
    SQLogToolManagerLevelText = 2      //在控制台显示log及在本地写入log
} SQLogToolManagerLevel;

@interface SQLogToolManager : NSObject

/**
 logLevel
 */
@property (nonatomic, assign) SQLogToolManagerLevel logLevel;

/**
 单例
 */
+ (instancetype)shareManager;

/**
 初始化
 */
- (void)logIntial;

@end

