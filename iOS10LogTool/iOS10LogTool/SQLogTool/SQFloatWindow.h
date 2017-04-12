//
//  SQFloatWindow.h
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQFloatWindow : UIWindow

/**
 点击事件block
 */
@property (nonatomic,copy) void(^clickBlocks)(NSInteger i);

/**
 悬浮窗初始化
 warning: frame的长宽必须相等
 
 @param frame       frame
 @param mainBtnName 主按钮name
 @param titles      数组，子按钮的name
 @param bgcolor     颜色
 @return            SQFloatWindow
 */
- (instancetype)initWithFrame:(CGRect)frame mainBtnName:(NSString*)mainBtnName titles:(NSArray *)titles bgcolor:(UIColor *)bgcolor;

/**
 显示悬浮窗
 */
- (void)showWindow;

/**
 隐藏悬浮窗
 */
- (void)dissmissWindow;



@end
