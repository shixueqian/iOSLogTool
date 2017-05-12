# iOS10LogTool
一个解决iOS10在发布环境下无法查看调试log的小工具

简书介绍地址：[【iOS开发】iOS10 Log调试小工具](http://www.jianshu.com/p/23011d141622)

### 出发点
由于iOS10系统，在发布环境下（打成ipa包安装测试或者发布之后从App Store下载安装的包），使用Xcode已经无法查看我们自己打印的log。所以就做了一个小工具，查看log，便于调试。
楼主的需求是，在安装了APP之后查看log，验证程序是否正常运行。除了在调试的时候用到，在线上包出问题之后，也能通过查看log来定位问题。

### 效果
楼主将该工具分成了3种模式

* 不显示log模式
这个是默认的模式。默认初始化之后是不显示任何log的。也就是说不做任何操作。
* Xcode控制台显示log模式
这个模式只在Xcode控制台显示log。这就是我们iOS10出来之前用的模式。通过控制台查看log。但是由于iOS10的时候，真机查看log时候会冒出一大坨没用的log，然后我们自己的log又看不见（好像Xocde8.2.1可以看见，但是还是会有很多无用的log），所以在iOS10下这个模式不好用
* 将log写入到文件并显示(悬浮窗模式)
这个模式将log显示在Xcode控制台，同时将log写入到沙盒中。我们可以通过读取沙盒的log文件来查看log。并且log文件还可以通过邮件、QQ、微信等方式发送。这个模式就是我们这个小工具主要实现的功能了。值的一说的是，这个模式我们会有一个悬浮窗，用来随时查看沙盒的log文件内容。

废话少说，上图：
![CSDN图标](http://imgtech.gmw.cn/attachement/jpg/site2/20111223/f04da22d7ba7105e1d7507.jpg "这是CSDN的图标")
![悬浮窗模式](http://upload-images.jianshu.io/upload_images/1818095-76de7fbeaaa4b9ac.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![预览界面](http://upload-images.jianshu.io/upload_images/1818095-db84e9dea191a8de.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![分享界面](http://upload-images.jianshu.io/upload_images/1818095-4e96f83587792f76.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 第一幅图就是悬浮窗模式。图中为浮窗展开时的界面。3个按钮分别对应着上面说的悬浮窗模式、Xcode控制台显示log模式、不显示log模式。
* 第二幅图是点击在浮窗上的【预览】之后显示的界面，这些就是我们在程序中打印的log。
* 第三幅图是点击第二幅图右上角的分享之后的界面。如果手机安装了QQ微信Facebook等软件，可以通过这些软件来分享这个log文件。


![效果示例](http://upload-images.jianshu.io/upload_images/1818095-f1ee4433f5e0e9d7.gif?imageMogr2/auto-orient/strip)

* 默认情况下，我们的小工具什么都不做。
* 当我们手动触发某个开关之后，悬浮窗就显示出来。并自动在沙盒创建log文件，之后就可以使用log写入功能。
* 悬浮窗是可以一直漂浮在APP的上方的，便于我们随时点击浮窗，查看log
* 点击悬浮窗上的【预览】按钮就可以以界面的形式显示沙盒文件的log，并且可以选择已邮件QQ微信等形式发送log文件
* 点击悬浮窗上的【Xcode】按钮，悬浮窗会消失，并且只会在Xcode控制台显示log。不会写入到文件。
* 点击悬浮窗上的【关闭】按钮，悬浮窗会消失，并且log不会再打印。
* 重启APP之后，会根据之前的模式来决定是否显示浮窗和打印log。

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
