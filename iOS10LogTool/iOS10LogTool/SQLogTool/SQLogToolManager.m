//
//  SQLogToolManager.m
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//

#import "SQLogToolManager.h"
#import "SQLog.h"
#import "SQFloatWindow.h"


#define SQ_LogLevel_UserDefalut @"SQLogToolManagerLevel"

@interface SQLogToolManager ()<UIDocumentInteractionControllerDelegate>

/**
 悬浮窗
 */
@property (nonatomic, strong) SQFloatWindow *floatWindow;

/**
 documentInteractionController，用来显示或者分享log文件内容
 */
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController ;

@end

@implementation SQLogToolManager

//单例
+ (instancetype)shareManager
{
    static SQLogToolManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQLogToolManager alloc] init];
    });
    return manager;
}



//初始化log类型
- (void)logIntial
{
    NSInteger logLevel = [[NSUserDefaults standardUserDefaults] integerForKey:SQ_LogLevel_UserDefalut];
    
    self.logLevel = (SQLogToolManagerLevel)logLevel;
}



#pragma mark - setter

- (void)setLogLevel:(SQLogToolManagerLevel)logLevel
{
    _logLevel = logLevel;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    switch (logLevel) {
        case SQLogToolManagerLevelNone://不打印log
        {
            //处理userDefault中的level值及floatWindow显示
            [userDefault setInteger:SQLogToolManagerLevelNone forKey:SQ_LogLevel_UserDefalut];
            [userDefault synchronize];
            if (_floatWindow)
            {
                [_floatWindow dissmissWindow];
                _floatWindow = nil;
            }
        }
            break;
        case SQLogToolManagerLevelLog://只在控制台显示log
        {
            [userDefault setInteger:SQLogToolManagerLevelLog forKey:SQ_LogLevel_UserDefalut];
            [userDefault synchronize];
            
            if (_floatWindow)
            {
                [_floatWindow dissmissWindow];
                _floatWindow = nil;
            }
        }
            break;
        case SQLogToolManagerLevelText://在控制台显示log及在本地写入log
        {
            [userDefault setInteger:SQLogToolManagerLevelText forKey:SQ_LogLevel_UserDefalut];
            [userDefault synchronize];
            
            [self.floatWindow showWindow];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - getter

- (SQFloatWindow *)floatWindow
{
    if (_floatWindow == nil)
    {
        //log初始化
        [SQLog logIntial];
        //        [SQLog setLogLevel:LOGLEVELD];
        
        //floatWindow 初始化
        _floatWindow = [[SQFloatWindow alloc] initWithFrame:CGRectMake(0, 200, 50, 50) mainBtnName:@"调试log" titles:@[@"预览",@"Xcode",@"关闭"] bgcolor:[UIColor blackColor]];
        
        __weak typeof(self) weakSelf = self;
        
        //点击事件处理
        _floatWindow.clickBlocks = ^(NSInteger i){
            
            switch (i)
            {
                case 0:
                {
                    //显示沙盒本地log
                    [weakSelf displayLocalLog];
                }
                    break;
                case 1:
                {
                    //Xcode显示log
                    weakSelf.logLevel = SQLogToolManagerLevelLog;
                }
                    break;
                case 2:
                {
                    //隐藏log
                    weakSelf.logLevel = SQLogToolManagerLevelNone;
                }
                    break;
                default:
                    break;
            }
            
        };
    }
    return _floatWindow;
}

//显示沙盒本地log
- (void)displayLocalLog
{
    if (![SQLog getLogFilePath])
    {
        return;
    }
    
    //由文件路径初始化UIDocumentInteractionController
    UIDocumentInteractionController *documentInteractionController  = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[SQLog getLogFilePath]]];
    self.documentInteractionController  = documentInteractionController ;
    documentInteractionController.delegate = self;
    
//    //显示分享文档界面
//    [documentInteractionController  presentOptionsMenuFromRect:[UIScreen mainScreen].bounds inView:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:YES];
    
    //直接显示预览界面
    [documentInteractionController  presentPreviewAnimated:YES];
}

#pragma mark - UIDocumentInteractionControllerDelegate

//在哪个控制器显示预览界面
-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
