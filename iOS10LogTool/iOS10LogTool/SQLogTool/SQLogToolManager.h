//
//  SQLogToolManager.h
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//  github地址：https://github.com/shixueqian/iOS10LogDebugTool
//  简书介绍地址：http://www.jianshu.com/p/23011d141622
//  本工具的管理类，使用的时候就用这个类即可。

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
} SQLogToolManagerLevel;//log模式

@interface SQLogToolManager : NSObject


/**
 单例
 */
+ (instancetype)shareManager;

/**
 初始化
 */
- (void)logIntial;


/**
 logLevel，log模式，通过这个属性设置log的模式
 */
@property (nonatomic, assign) SQLogToolManagerLevel logLevel;

@end

