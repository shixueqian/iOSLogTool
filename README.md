# iOS10LogTool
一个解决iOS10在发布环境下无法查看调试log的小工具

简书介绍地址：[【iOS开发】iOS10 Log调试小工具](http://www.jianshu.com/p/23011d141622)

### 出发点
由于iOS10系统，在发布环境下（打成ipa包安装测试或者发布之后从App Store下载安装的包），使用Xcode已经无法查看我们自己打印的log。所以就做了一个小工具，查看log，便于调试。
楼主的需求是，在安装了APP之后查看log，验证程序是否正常运行。除了在调试的时候用到，在线上包出问题之后，也能通过查看log来定位问题。

### 使用

* 项目github地址：https://github.com/shixueqian/iOS10LogDebugTool
* 将SQLogTool文件夹中的几个文件拖到工程中
* 在didFinishLaunchingWithOptions方法中进行初始化
代码示例：

```
//需要导入头文件  #import "SQLogToolManager.h"
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    [[SQLogToolManager shareManager] logIntial];
    return YES;
}
```

* 在应用的某个界面上设置一个开关，点击这个开关就将log工具设置到悬浮窗模式（楼主设置的是在登录界面上连续点击10次就触发方法）
代码示例：


```
- (IBAction)onClickWriteToTextAndShowFloatWindow:(UIButton *)sender
{
    [SQLogToolManager shareManager].logLevel = SQLogToolManagerLevelText;
}
```

* 在需要打印Log的地方使用 ``NSLogD()``来替换平常用的``NSLog()``
代码示例：

```
- (IBAction)onClickTest:(UIButton *)sender
{
    for (int i = 0; i < 10; ++i)
    {
        NSLogD(@"这里是测试。%@：%d",@"第一个参数",i);
    }
}
```

### 不足之处&需改进的地方

这个只是一个小工具，所以只做了几个我认为比较重要的功能。。主要缺陷：

* 界面长得不是很好看（管他呢）
* 不能显示系统的log。只能显示使用``NSLogD()``方法打印的log。也就是说，苹果的警告log无法通过这个小工具得到。（当前，这也避免了iOS10上那些恶心的无用log）
* 无法显示崩溃log。楼主认为这个功能不是那么重要，就没做了。
