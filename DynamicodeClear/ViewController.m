//
//  ViewController.m
//  DynamicodeClear
//
//  Created by Bingo on 16/6/2.
//  Copyright © 2016年 Bingo. All rights reserved.
//

#import "ViewController.h"
#import <DCSwiperAPI/DCSwiperAPI.h>

@interface ViewController ()<DCSwiperAPIDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) DCSwiperAPI * dcSwiper;//SDK 单例对象

@property (weak, nonatomic) IBOutlet UITableView *tableView; //表格 通过storyboard创建

@property (strong,nonatomic) NSMutableArray *dataArray; //数据源 （功能）

@property (strong,nonatomic) UIActivityIndicatorView *activity; //菊花控件

@end

@implementation ViewController

//视图即将显示
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //写在此方法里是为了防止在切换控制器的时候delegate被销毁
    self.dcSwiper = [DCSwiperAPI shareInstance];
    
    [self.dcSwiper setDelegate:self];
}
/**
 *  视图已经加载
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化圈圈
    [self ActivityIndicatorView];

    //删除表格多余分割线
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    _dataArray = [NSMutableArray arrayWithObjects:
                  @[@"获取KSN",@"update"],
                  @[@"刷卡或插卡",@"update"],
                  @[@"Pin加密（P27）",@"update"],
                  @[@"从POS输入密码(P84)",@"update"],
                  @[@"计算Mac",@"update"],
                  @[@"写入主密钥",@"update"],
                  @[@"更新工作密钥",@"update"],
                  @[@"取消/复位",@"fuwei"],
                  nil];
}

#pragma mark - DCSwiperAPIDelegate
/**
 *  设备按取消键返回
 */
-(void)onPressCancleKey {
    [_activity stopAnimating];
    
    [self alertView:@"用户按取消键"];
}

/**
 *  取消、复位的回调
 */
-(void)onDidCancelCard {
    
    [_activity stopAnimating];

    [self alertView:@"取消复位成功"];
}

/**
 *  获取KSN的回调
 *
 *  @param dic dic[@"6"]
 */
-(void)onDidGetDeviceKsn:(NSDictionary *)dic {
    
    [_activity stopAnimating];

    [self alertView:[NSString stringWithFormat:@"KSN:%@",dic[@"6"]]];
}

/**
 *  刷卡或插卡的回调
 *
 *  @param dic
 */
-(void)onDidReadCardInfo:(NSDictionary *)dic {
    
    [_activity stopAnimating];

    NSMutableArray * infos = [NSMutableArray array];
    
    if (_dcSwiper.currentCardType == card_mc) {//磁条卡信息
        //卡号
        NSString *accountNum = [@"账户:" stringByAppendingString:dic[@"5"]];
        [infos addObject:accountNum];
        //磁道2
        NSString *track2Info = [@"磁道2信息:" stringByAppendingString:dic[@"A"]];
        [infos addObject:track2Info];
        //磁道3
        NSString *track3Info = [@"磁道3信息:" stringByAppendingString:dic[@"B"]];
        [infos addObject:track3Info];
        //有效期
        NSString *expiryDate = [@"有效期:" stringByAppendingString:dic[@"6"]];
        [infos addObject:expiryDate];
    }else{//ic卡信息
        //卡号
        NSString *accountNum = [@"账户:" stringByAppendingString:dic[@"5A"]];
        [infos addObject:accountNum];
        //55域信息
        NSString *str55 = [@"55域信息:" stringByAppendingString:dic[@"55"]];
        [infos addObject:str55];
        //二磁道等效信息
        NSString *trackInfo = [@"二磁道等效信息:" stringByAppendingString:dic[@"57"]];
        [infos addObject:trackInfo];
        //卡片序列号
        NSString *cardNum = [@"卡片序列号:" stringByAppendingString:dic[@"5F34"]];
        [infos addObject:cardNum];
        //有效期
        NSString *expiryDate = [@"有效期:" stringByAppendingString:dic[@"5F24"]];
        [infos addObject:expiryDate];
    }
    
    NSString *info = [infos componentsJoinedByString:@"\n"];
    
    [self alertView:info];
}

/**
 *  计算Mac的回调
 *
 *  @param strmac
 */
-(void)onDidGetMac:(NSString *)strmac {
    
    [_activity stopAnimating];
    
    [self alertView:[NSString stringWithFormat:@"Mac:%@",strmac]];
}

/**
 *  加密Pin的回调
 *
 *  @param encPINblock
 */
-(void)onEncryptPinBlock:(NSString *)encPINblock {
    
    [_activity stopAnimating];
    
    [self alertView:[NSString stringWithFormat:@"Pin:%@",encPINblock]];
}

/**
 *  获取POS输入密码的回调函数
 *
 *  @param pinBlock
 */
-(void)onReturnPinBlock:(NSString *)pinBlock {
    [_activity stopAnimating];
    
    [self alertView:[NSString stringWithFormat:@"POS获取Pin:%@",pinBlock]];
}

/**
 *  导入主密钥返回
 *
 *  @param isSuccess YES OR NO
 */
-(void)onDidLoadMainKey:(BOOL)isSuccess {
    [_activity stopAnimating];
    
    [self alertView:isSuccess ? @"写入主密钥成功" : @"写入主密钥失败"];
}

/**
 *  更新工作密钥回调
 *
 *  @param isSuccess
 */
-(void)onDidUpdateKey:(BOOL)isSuccess{
    
    [_activity stopAnimating];
    
    [self alertView:isSuccess ? @"更新工作秘钥成功" : @"更新工作秘钥失败"];
}

/**
 *  @brief 0 发生错误的回调
 *
 *  @param errmsg 错误信息
 */
-(void)onResponse:(int)type :(int)status {
    
    
    NSLog(@"错误回调返回:%d,",status);
    
    [_activity stopAnimating];
    
    switch (type) {
        case ERROR_FAIL_NEEDIC:
            [self waringView:@"请插入ic卡"];
            break;
        case ERROR_FAIL_MCCARD:
            [self waringView:@"读磁条卡失败"];
            break;
        case ERROR_FAIL_TIMEOUT:
            [self waringView:@"超时"];
            break;
        case ERROR_FAIL_GET_KSN:
            [self waringView:@"获取ksn失败"];
            break;
        case ERROR_FAIL_DATA:
            [self waringView:@"数据域错误"];
            break;
        case ERROR_FAIL_SWIPINGCARD:
            [self waringView:@"请先刷卡"];
            break;
        default:
            break;
    }

}

#pragma mark - UITableViewDelegate
/**
 *  cell点击事件
 *
 *  @param tableView
 *  @param indexPath
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //选中cell效果消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
#pragma mark - SDK执行方法
    
    if (!_dcSwiper.isConnectBlue) {
        [self alertView:@"蓝牙未连接"];
        return;
    }
    
    [_activity startAnimating];//转圈圈

    switch (indexPath.row) {
        case 0://获取KSN
            [self.dcSwiper getDeviceKsn];
            break;
        case 1://刷卡或插卡
            [self.dcSwiper readCard:1 money:100];
            break;
        case 2://加密Pin
            [self.dcSwiper encryptPin:@"123456"];
            break;
        case 3://获取POS输入密码
            [self.dcSwiper getPinFromPOS];//必须先执行刷卡
            break;
        case 4://计算mac
            [self.dcSwiper getMacValue:@"1990050000000100000000010455421206313031303130303030313736"];
            break;
        case 5://写入主密钥
            [self.dcSwiper loadMainKey:@"27B3AA3E4ABFED56000000000000000082E13665"];
            break;
        case 6://更新工作密钥
            [self.dcSwiper updateKey:@{@"PINKey":@"950973182317F80B950973182317F80B00962B60",@"MACKey":@"",@"DESKey":@""}];
            break;
        case 7://取消/复位
            [self.dcSwiper cancelCard];
            break;
        default:
            [self alertView:@"暂未实现"];
            [_activity stopAnimating];//转圈圈
            break;
    }
}
/**
 *  行高
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return height
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

/**
 *  cell个数
 *
 *  @param tableView
 *  @param section   分区
 *
 *  @return count
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

/**
 *  cell实现
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return cell
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    cell.textLabel.text = _dataArray[indexPath.row][0];
    cell.imageView.image = [UIImage imageNamed:_dataArray[indexPath.row][1]];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
 
    return cell;
}
/**
 *  弹框
 *
 *  @param string 信息
 */
-(void)alertView:(NSString *)string{
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:string preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)waringView:(NSString *)string {
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"错误" message:string delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

/**
 *  显示活动指示器
 */
-(void)ActivityIndicatorView {
    _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activity.center = self.view.center;
    _activity.color = [UIColor colorWithRed:21/255.0 green:126/255.0 blue:251/255.0 alpha:1];
    [self.view addSubview:_activity];
}

@end
