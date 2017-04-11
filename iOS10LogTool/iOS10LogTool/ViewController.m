//
//  ViewController.m
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//

#import "ViewController.h"
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
    [SQLogToolManager shareManager].logLevel = SQLogToolManagerLevelNone;
    for (int i = 0; i < 10; ++i) {
        NSLogD(@"这里是None模式。%@：%d",@"第一个参数",i);
    }
}

- (IBAction)onClickXcodeLog:(UIButton *)sender
{
    [SQLogToolManager shareManager].logLevel = SQLogToolManagerLevelLog;
    for (int i = 0; i < 10; ++i) {
        NSLogD(@"这里是Xcode Log模式。%@：%d",@"第一个参数",i);
    }
}

- (IBAction)onClickWriteToTextAndShowFloatWindow:(UIButton *)sender
{
    [SQLogToolManager shareManager].logLevel = SQLogToolManagerLevelText;
    for (int i = 0; i < 1; ++i) {
        NSLogD(@"这里是Log写入模式。%@：%d",@"第一个参数",i);
    }
}

- (IBAction)onClickTest:(UIButton *)sender
{
    for (int i = 0; i < 10; ++i) {
        NSLogD(@"这里是测试。%@：%d",@"第一个参数",i);
    }
}

@end
