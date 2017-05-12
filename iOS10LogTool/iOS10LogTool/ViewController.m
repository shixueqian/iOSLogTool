//
//  ViewController.m
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//  github地址：https://github.com/shixueqian/iOS10LogDebugTool
//  简书介绍地址：http://www.jianshu.com/p/23011d141622
//

#import "ViewController.h"
//需要导入头文件
#import "SQLogToolManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)onClickNone:(UIButton *)sender
{
    //设置成SQLogToolManagerLevelNone模式
    [SQLogToolManager shareManager].logLevel = SQLogToolManagerLevelNone;
    
    //调用看看效果
    for (int i = 0; i < 10; ++i)
    {
        NSLogD(@"这里是None模式。%@：%d",@"第一个参数",i);
    }
}

- (IBAction)onClickXcodeLog:(UIButton *)sender
{
    //设置成SQLogToolManagerLevelLog模式
    [SQLogToolManager shareManager].logLevel = SQLogToolManagerLevelLog;
    
    //调用看看效果
    for (int i = 0; i < 10; ++i)
    {
        NSLogD(@"这里是Xcode Log模式。%@：%d",@"第一个参数",i);
    }
}

- (IBAction)onClickWriteToTextAndShowFloatWindow:(UIButton *)sender
{
    //设置成SQLogToolManagerLevelText模式
    [SQLogToolManager shareManager].logLevel = SQLogToolManagerLevelText;
    
    //调用看看效果
    for (int i = 0; i < 1; ++i)
    {
        NSLogD(@"这里是Log写入模式。%@：%d",@"第一个参数",i);
    }
}


//测试
- (IBAction)onClickTest:(UIButton *)sender
{
    //调用看看效果
    for (int i = 0; i < 10; ++i)
    {
        NSLogD(@"这里是测试。%@：%d",@"第一个参数",i);
    }
}

@end
