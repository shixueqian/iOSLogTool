//
//  SQFloatWindow.m
//  iOS10LogTool
//
//  Created by 石学谦 on 17/4/11.
//  Copyright © 2017年 shixueqian. All rights reserved.
//

#import "SQFloatWindow.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define animateDuration 0.3       //位置改变动画时间
#define showDuration 0.1          //展开动画时间
#define statusChangeDuration  3.0    //状态改变时间
#define normalAlpha  0.8           //正常状态时背景alpha值
#define sleepAlpha  0.3           //隐藏到边缘时的背景alpha值
#define myBorderWidth 1.0         //外框宽度
#define marginWith  5             //间隔

@interface SQFloatWindow()

@property(nonatomic)NSInteger frameWidth;
@property(nonatomic)BOOL  isShowTab;
@property(nonatomic,strong)UIPanGestureRecognizer *pan;
@property(nonatomic,strong)UITapGestureRecognizer *tap;
@property(nonatomic,strong)UIButton *mainBtn;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)NSArray *titles;
@property(nonatomic,strong)UIColor *bgcolor;


@end

@implementation SQFloatWindow
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame mainBtnName:(NSString*)mainBtnName titles:(NSArray *)titles bgcolor:(UIColor *)bgcolor{
    if(self = [super initWithFrame:frame])
    {
        NSAssert(mainBtnName != nil, @"mainBtnName can't be nil !");
        NSAssert(titles != nil, @"titles can't be nil !");
        
        _isShowTab = FALSE;
        
        UIWindow *preKeyWindow = [UIApplication sharedApplication].keyWindow;
        
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert + 1;
        self.rootViewController = [UIViewController new];
        [self makeKeyAndVisible];
        
        //还回keyWindow
        if (preKeyWindow) {
            [preKeyWindow makeKeyWindow];
        }
        
        _bgcolor = bgcolor;
        _frameWidth = frame.size.width;
        _titles = titles;
        
        //加边框
        [self drawBorderLineWithView:self borderWidth:1 color:[UIColor whiteColor]];
        
        //内容view
        [self setupContentView];
        
        //添加按钮
        [self setupButtons];
        
        //主按钮
        [self setupMainBtnWithName:mainBtnName];
        
        //手势
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        _pan.delaysTouchesBegan = NO;
        [self addGestureRecognizer:_pan];
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:_tap];
        
        //设备旋转的时候收回按钮
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
    
}

- (void)setupMainBtnWithName:(NSString *)mainBtnName
{
    _mainBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [_mainBtn setFrame:(CGRect){0, 0,self.frame.size.width, self.frame.size.height}];
    
    _mainBtn.alpha = sleepAlpha;
    _mainBtn.backgroundColor = [UIColor brownColor];
    [_mainBtn setTitle:mainBtnName forState:UIControlStateNormal];
    _mainBtn.titleLabel.font = [UIFont systemFontOfSize: self.frameWidth/5];
    [_mainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self drawBorderLineWithView:_mainBtn borderWidth:1 color:[UIColor whiteColor]];
    
    [_mainBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_mainBtn];
}

- (void)setupContentView
{
    _contentView = [[UIView alloc] initWithFrame:(CGRect){_frameWidth ,0,_titles.count * (_frameWidth),_frameWidth}];
    _contentView.alpha  = 0;
    //    _contentView.backgroundColor = [UIColor redColor];
    [self addSubview:_contentView];
}

- (void)setupButtons{
    
    for (int i = 0; i < _titles.count; ++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame: CGRectMake(self.frameWidth * i , marginWith/2, self.frameWidth-marginWith , self.frameWidth-marginWith )];
        [button setBackgroundColor:[UIColor clearColor]];
        
        [button setTitle:_titles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize: self.frameWidth/5];
        button.layer.cornerRadius = button.frame.size.width/2;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor brownColor];
        
        button.tag = i;
        
        [button addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
    }
    
}

#pragma mark ------- contentview 操作 --------------------
//按钮在屏幕右边时，左移contentview
- (void)moveContentviewLeft{
    _contentView.frame = (CGRect){marginWith, 0 ,_contentView.frame.size.width,_contentView.frame.size.height};
}

//按钮在屏幕左边时，contentview恢复默认
- (void)resetContentview{
    _contentView.frame = (CGRect){self.frameWidth + marginWith,0,_contentView.frame.size.width,_contentView.frame.size.height};
}


//改变位置
- (void)locationChange:(UIPanGestureRecognizer*)p
{
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(p.state == UIGestureRecognizerStateBegan)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
        _mainBtn.alpha = normalAlpha;
    }
    if(p.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded)
    {
        [self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];
        
        if(panPoint.x <= kScreenWidth/2)
        {
            if(panPoint.y <= 40+HEIGHT/2 && panPoint.x >= 20+WIDTH/2)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2);
                }];
            }
            else if(panPoint.y >= kScreenHeight-HEIGHT/2-40 && panPoint.x >= 20+WIDTH/2)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-HEIGHT/2);
                }];
            }
            else if (panPoint.x < WIDTH/2+20 && panPoint.y > kScreenHeight-HEIGHT/2)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(WIDTH/2, kScreenHeight-HEIGHT/2);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y < HEIGHT/2 ? HEIGHT/2 :panPoint.y;
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(WIDTH/2, pointy);
                }];
            }
        }
        else if(panPoint.x > kScreenWidth/2)
        {
            if(panPoint.y <= 40+HEIGHT/2 && panPoint.x < kScreenWidth-WIDTH/2-20 )
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2);
                }];
            }
            else if(panPoint.y >= kScreenHeight-40-HEIGHT/2 && panPoint.x < kScreenWidth-WIDTH/2-20)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-HEIGHT/2);
                }];
            }
            else if (panPoint.x > kScreenWidth-WIDTH/2-20 && panPoint.y < HEIGHT/2)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(kScreenWidth-WIDTH/2, HEIGHT/2);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y > kScreenHeight-HEIGHT/2 ? kScreenHeight-HEIGHT/2 :panPoint.y;
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(kScreenWidth-WIDTH/2, pointy);
                }];
            }
        }
    }
}

//点击事件
- (void)click:(UITapGestureRecognizer*)p
{
    
    _mainBtn.alpha = normalAlpha;
    
    //拉出悬浮窗
    if (self.center.x == 0) {
        self.center = CGPointMake(WIDTH/2, self.center.y);
    }else if (self.center.x == kScreenWidth) {
        self.center = CGPointMake(kScreenWidth - WIDTH/2, self.center.y);
    }else if (self.center.y == 0) {
        self.center = CGPointMake(self.center.x, HEIGHT/2);
    }else if (self.center.y == kScreenHeight) {
        self.center = CGPointMake(self.center.x, kScreenHeight - HEIGHT/2);
    }
    //展示按钮列表
    if (!self.isShowTab) {
        self.isShowTab = TRUE;
        
        [UIView animateWithDuration:showDuration animations:^{
            
            _contentView.alpha  = 1;
            
            if (self.frame.origin.x <= kScreenWidth/2) {
                [self resetContentview];
                
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, WIDTH + _titles.count * (self.frameWidth + marginWith/2) ,self.frameWidth);
            }else{
                
                [self moveContentviewLeft];
                
                self.mainBtn.frame = CGRectMake((_titles.count * (self.frameWidth + marginWith/2)), 0, self.frameWidth, self.frameWidth);
                self.frame = CGRectMake(self.frame.origin.x  - _titles.count * (self.frameWidth + marginWith/2), self.frame.origin.y, (WIDTH + _titles.count * (self.frameWidth + marginWith/2)) ,self.frameWidth);
            }
            if (_bgcolor) {
                self.backgroundColor = _bgcolor;
            }else{
                self.backgroundColor = [UIColor grayColor];
            }
            
        }];
        //移除pan手势
        if (_pan) {
            [self removeGestureRecognizer:_pan];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
    }else{
        self.isShowTab = FALSE;
        
        //添加pan手势
        if (_pan) {
            [self addGestureRecognizer:_pan];
        }
        
        [UIView animateWithDuration:showDuration animations:^{
            
            _contentView.alpha  = 0;
            
            if (self.frame.origin.x + self.mainBtn.frame.origin.x <= kScreenWidth/2) {
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frameWidth ,self.frameWidth);
            }else{
                self.mainBtn.frame = CGRectMake(0, 0, self.frameWidth, self.frameWidth);
                self.frame = CGRectMake(self.frame.origin.x + _titles.count * (self.frameWidth + marginWith/2), self.frame.origin.y, self.frameWidth ,self.frameWidth);
            }
            self.backgroundColor = [UIColor clearColor];
        }];
        [self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];
    }
}

- (void)changeStatus
{
    [UIView animateWithDuration:1.0 animations:^{
        _mainBtn.alpha = sleepAlpha;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat x = self.center.x < 20+WIDTH/2 ? 0 :  self.center.x > kScreenWidth - 20 -WIDTH/2 ? kScreenWidth : self.center.x;
        CGFloat y = self.center.y < 40 + HEIGHT/2 ? 0 : self.center.y > kScreenHeight - 40 - HEIGHT/2 ? kScreenHeight : self.center.y;
        
        //禁止停留在4个角
        if((x == 0 && y ==0) || (x == kScreenWidth && y == 0) || (x == 0 && y == kScreenHeight) || (x == kScreenWidth && y == kScreenHeight)){
            y = self.center.y;
        }
        self.center = CGPointMake(x, y);
    }];
}

//加圆形边框
- (void)drawBorderLineWithView:(UIView *)view borderWidth:(CGFloat)width color:(UIColor *)color{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = view.frame.size.width/2;
    view.layer.borderWidth = width;
    if (!color) {
        view.layer.borderColor = [UIColor whiteColor].CGColor;
    }else{
        view.layer.borderColor = color.CGColor;
    }
}


#pragma mark  ------- button事件 ---------
- (void)itemsClick:(id)sender{
    if (self.isShowTab){
        [self click:nil];
    }
    
    UIButton *button = (UIButton *)sender;
    if (self.clickBlocks) {
        self.clickBlocks(button.tag);
    }
}

- (void)dissmissWindow{
    self.hidden = YES;
}
- (void)showWindow{
    self.hidden = NO;
}


#pragma mark  ------- 设备旋转 -----------
- (void)orientChange:(NSNotification *)notification{
    
    //旋转前要先改变frame，否则坐标有问题（临时办法）
    self.frame = CGRectMake(0, kScreenHeight - self.frame.origin.y - self.frame.size.height, self.frame.size.width,self.frame.size.height);
    
    if (self.isShowTab) {
        [self click:nil];
    }
}


@end
