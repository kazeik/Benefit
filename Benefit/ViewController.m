//
//  ViewController.m
//  Benefit
//
//  Created by kazeik on 2016/12/5.
//  Copyright © 2016年 kazeik. All rights reserved.
//

#import "ViewController.h"
#import "MenuListModel.h"
#import "MenuSubListModel.h"
#import "YCXMenu.h"

#define IOS9_WIDTH 640/2
#define IOS9_HIGHT 1136/2
#define MENU_HIGHT  50
#define ACTIONBAR_HIGHT 20
@interface ViewController ()
 //<UIWebViewDelegate>
@property( nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong) MenuListModel *listModel;
@end

@implementation ViewController

@synthesize webView;

@synthesize listModel;

NSString *pageIndex = @"appindex.php";
NSString *menuList = @"appmenu.php";
NSString *versionUpdate = @"getmbVersionInfo.php";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, ACTIONBAR_HIGHT, IOS9_WIDTH, IOS9_HIGHT-ACTIONBAR_HIGHT-MENU_HIGHT)];
    webView.scalesPageToFit=YES;//自动对页面进行缩放以适应屏幕
    webView.delegate = self;
    [self.view addSubview:webView];
    
    
    [self netRequest:pageIndex];
    [self netRequest:menuList];
    
}
/**
 * 打开网页
 */
-(void) openUrl:(NSString *)url
{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

/**
 *
 */
- (void) netRequest:(NSString *)tag
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",@"http://appmenu.yishengsz.net/",tag];
    NSLog(@"%@" ,requestUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    NSURLResponse *respone ;
    NSError *nsError;
    NSData *nsData = [NSURLConnection sendSynchronousRequest:request returningResponse:&respone error:&nsError];
    if(nsError){
        NSLog(@"error :%@",[nsError localizedDescription]);
    }else{
        if([tag isEqualToString:pageIndex]){
            NSDictionary *dictory = [NSJSONSerialization JSONObjectWithData:nsData options:kNilOptions error:&nsError];
            NSString *va = dictory[@"url"];
            [self openUrl:va];   // 暂时注释
        }else if([tag isEqualToString:menuList]){
            NSArray *json = [NSJSONSerialization JSONObjectWithData:nsData options:kNilOptions error:&nsError];
            listModel  =[[MenuListModel alloc]init];
            listModel.item = [[NSMutableArray alloc]init];
            listModel.subList = [[NSMutableArray alloc]init];
            for(int i=0;i<[json count];i++){
                NSData *subData = [NSJSONSerialization dataWithJSONObject:[json objectAtIndex:i] options:NSJSONWritingPrettyPrinted error:nil];
                
                NSDictionary *subDict = [NSJSONSerialization JSONObjectWithData:subData options:kNilOptions error:nil];
                [listModel.item addObject:subDict[@"item"]];
                
                NSMutableArray *tempMenuArr = [[NSMutableArray alloc]init];
                
                NSData *tempData = [NSJSONSerialization dataWithJSONObject:subDict[@"value"] options:NSJSONWritingPrettyPrinted error:nil];
                NSArray *tempArr = [NSJSONSerialization JSONObjectWithData:tempData options:kNilOptions error:nil];
                for(int i=0;i<[tempArr count];i++){
                    NSData *tempData = [NSJSONSerialization dataWithJSONObject:[tempArr objectAtIndex:i] options:NSJSONWritingPrettyPrinted error:nil];
                    NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:tempData options:kNilOptions error:nil ];
                    MenuSubListModel *subMenu = [[MenuSubListModel alloc]init];
                    subMenu.subMenuUrl = tempDic[@"subMenuUrl"];
                    subMenu.subMenuName = tempDic[@"subMenuName"];
                    [tempMenuArr addObject:subMenu];
                }
                [listModel.subList addObject:tempMenuArr];
            }
            [self menuView:listModel];
        }
    }
}
#pragma -添加菜单
-(void) menuView:(MenuListModel *)mode
{
    NSInteger len = [mode.item count];
    NSInteger buttonWidth = IOS9_WIDTH/len;
    for(int i=0;i<len;i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame =CGRectMake(i*buttonWidth, IOS9_HIGHT-MENU_HIGHT,buttonWidth+1.5 , MENU_HIGHT); //定位
        [button setTitleColor: [UIColor blackColor] forState:(UIControlStateNormal)]; //设置文字颜色
        button.titleLabel.font=[UIFont systemFontOfSize:15];    //设置字体大小
        [button setTitle:[mode.item objectAtIndex:i] forState:UIControlStateNormal]; //设置用于显示的文字
        
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:1];//设置矩形四角半径
        [button.layer setBorderWidth:0.5]; //边框宽度
        button.layer.borderColor=[UIColor grayColor].CGColor; //设置边框颜色
        
        button.tag=10000+i;
        [button addTarget:self action:(@selector(btnDownEvent:)) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
    }
}
/***按钮按下事件***/
-(void) btnDownEvent:(id)sender
{
    UIButton *btn = sender;
    
    NSMutableArray *value;
    NSInteger btnIndex;
    switch (btn.tag) {
        case 10000:
            btnIndex = 0;
           value = [self subMenu:[[listModel subList] objectAtIndex:0]];
            break;
        case 10001:
           value = [self subMenu:[[listModel subList] objectAtIndex:1]];
            btnIndex  =1;
            break;
        case 10002:
          value =  [self subMenu:[[listModel subList] objectAtIndex:2]];
            btnIndex =2;
            break;
        default:
            break;
    }
    [YCXMenu setBackgrounColorEffect:YCXMenuBackgrounColorEffectSolid];
    [YCXMenu setTintColor:[UIColor whiteColor]];
    
    [YCXMenu showMenuInView:self.view fromRect:btn.frame menuItems:value selected:^(NSInteger index, YCXMenuItem *item) {
//        NSLog(@"%@",[[[[listModel subList] objectAtIndex:btnIndex] objectAtIndex:index] subMenuUrl]);
        [self openUrl:[[[[listModel subList] objectAtIndex:btnIndex] objectAtIndex:index] subMenuUrl]];
    }];
}
#pragma mark - setter/getter
- (NSMutableArray *)subMenu:(NSMutableArray *)menuModel
{
      NSMutableArray *_items = [[NSMutableArray alloc]init];
        for(int i=0;i<[menuModel  count];i++){
            MenuSubListModel *subModel= [menuModel  objectAtIndex:i] ;
            YCXMenuItem *menuTitle = [YCXMenuItem menuItem:[subModel subMenuName]  image:nil target:self action:@selector(self)];
            menuTitle.foreColor = [UIColor blackColor];
            menuTitle.titleFont = [UIFont boldSystemFontOfSize:13.0f];
            
            [_items addObject:menuTitle];
        }

    return _items;
}


/**构建POST请求***/
-(void)postNetRequest:(NSString *)tag
{
    NSString *baseUrl = @"http://appmenu.yishengsz.net/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",baseUrl,tag];
    NSURL *url = [NSURL URLWithString:requestUrl];
    NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval=15.0;//设置15秒超时
    request.HTTPMethod=@"POST";//设置请求方法
    
    //    NSString *param =[NSString stringWithFormat:@""];
    //把拼接后的字符串转换为data，设置请求体
    //    request.HTTPBody=[param dataUsingEncoding:NSUTF8StringEncoding];
    //    3.发送请求
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)webViewDidStartLoad:(UIWebView *)webView
//{
//    NSLog(@"即将加载网页");
//}
//-(void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    //    调整字体大小
//    //    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='50%'"];
//    NSLog(@"网页加载完成");
//}
//-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//    NSLog(@"网页加载错误");
////    NSLog(@"%@",[error localizedDescription]);
//}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
@end
