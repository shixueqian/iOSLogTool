# iOS10LogDebugTool
一个解决iOS10在发布环境下log太多无法查看log的小工具
简书介绍地址：


### 出发点
由于iOS10系统，在发布环境下（打成ipa包安装测试或者发布之后从App Store下载安装的包），使用Xcode已经无法查看我们自己打印的log。所以就做了一个小工具，查看log，便于调试。
主要是楼主由于一些原因，需要在安装了软件之后看一下log，验证程序是否正常运行。除了在调试的时候用到，在线上出问题出问题之后，也能看到我们打印的log。
### 效果
楼主将该工具分成了3种模式
* 不显示log
这个是默认的模式。默认初始化之后是不显示任何log的。也就是说不做任何操作。
* 在Xcode控制台显示log
这个模式只在Xocde控制台显示log。这就是我们iOS10出来之前用的模式。通过控制台查看log。但是由于iOS10的时候，真机查看log时候会冒出一大坨没用的log，然后我们自己的log又看不见（好像Xocde8.2.1可以看见，但是还是会有很多无用的log）
* 将log写入到文件并显示(悬浮窗模式)
这个模式将log显示在Xcode控制台，同时将log写入到沙盒中。我们可以通过读取沙盒的log文件来查看log。并且log文件还可以通过邮件、QQ、微信等方式发送。这个模式就是我们这个小工具要实现的功能了。值的一说的是，这个模式我们会有一个悬浮窗，用来随时显示沙盒的log。

废话少说，上图：
![点击悬浮窗上的预览之后就可以显示沙盒文件的log](http://upload-images.jianshu.io/upload_images/1818095-2536f1ff0c137ea7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
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
* 在应用的某个界面上设置一个开关，点击这个开关就将log工具设置到悬浮窗模式（楼主设置的是在登录界面上连续点击10次触发方法）
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

### 项目解析
介绍下项目用到的几个类和主要的技术点

![项目文件结构](http://upload-images.jianshu.io/upload_images/1818095-1fe8803516a0b512.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* SQFloatWindow 悬浮窗功能类。
继承UIWindow，将windowLevel设置为UIWindowLevelAlert + 1 来使window浮窗悬浮在APP上方。
```
        UIWindow *preKeyWindow = [UIApplication sharedApplication].keyWindow;
        
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert + 1;
        self.rootViewController = [UIViewController new];
        [self makeKeyAndVisible];
        
        //还回keyWindow
        if (preKeyWindow) {
            [preKeyWindow makeKeyWindow];
        }
```
值得注意的是，我们的悬浮窗不需要作为keyWindow（不然会带来很多麻烦的），所以需要将keyWindow还给之前的window。

给悬浮窗加了一个主按钮和若干个子按钮，用来点击
```
//添加按钮
[self setupButtons];
//主按钮
[self setupMainBtnWithName:mainBtnName];

```
定义一个block属性来处理子按钮的点击事件，具体的子按钮由按钮的tag来区分
```
/**
 点击事件block
 */
@property (nonatomic,copy) void(^clickBlocks)(NSInteger i);
```
浮窗还做了一些点击展开，点击关闭，拖拽，靠边等操作，具体请查看源代码

* SQLog  log打印和写入文件类。
当调用 ``SQLogD(...)``时，会将log显示在Xcode控制台，并且将log写入到沙盒文件中。
```
//目前只用到了SQLogD
//Debug
#define SQLogD(...) [SQLog logD:[NSString stringWithFormat:__VA_ARGS__],@""];
```
调用``logIntial``初始化方法时，会在沙盒创建log.txt文件（如果已创建就清空文件内容）。

当调用``SQLogD(...)``打印log时，会创建一个异步的串行队列来进行打印并写入log。
```
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

```

* SQLogToolManager  本小工具的管理类。用来整合SQLog和SQFloatWindow 并处理对外的接口和使用逻辑。

```
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
```
``NSLogD(...)``宏定义中，使用logLevel属性来控制log的类型。用户改变了logLevel就改变了打印的类型。

悬浮窗子按钮的点击事件，分为三个。【预览】，【Xcode】和【关闭】。
```
//点击事件处理
        _floatWindow.clickBolcks = ^(NSInteger i){
            
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

```
其中，【Xcode】【关闭】只是设置了logLevel，而【预览】使用了iOS提供的预览和分享的类``UIDocumentInteractionController``
```
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

```

### 参考
* [KKLog](https://github.com/Coneboy-k/KKLog):一个不错的log小工具
* [DYYFloatWindow](https://github.com/shanghaiMichael/DYYFloatWindow):这是一个iOS上的悬浮窗
* 本项目github地址：https://github.com/shixueqian/iOS10LogDebugTool

### 谦言万语
