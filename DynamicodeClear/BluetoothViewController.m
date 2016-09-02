//
//  BluetoothViewController.m
//  DynamicodeClear
//
//  Created by Bingo on 16/6/2.
//  Copyright © 2016年 Bingo. All rights reserved.
//

#import "BluetoothViewController.h"
#import <DCSwiperAPI/DCSwiperAPI.h>

#define  PERIPHERAL_IDENTIFER  @"identifier"
#define  PERIPHERAL_NAME       @"Name"

#define screenWidth [UIScreen mainScreen].applicationFrame.size.width
#define screenHeight [UIScreen mainScreen].applicationFrame.size.height

@interface BluetoothViewController ()<DCSwiperAPIDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) DCSwiperAPI * dcSwiper;
@property (nonatomic, strong) NSMutableArray * deviceArray;
@property (nonatomic, strong) NSMutableArray * logArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BluetoothViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.dcSwiper = [DCSwiperAPI shareInstance];
    
    [self.dcSwiper setDelegate:self];
    
    _deviceArray = [NSMutableArray array];
    
    _logArray = [NSMutableArray array];
    
    //[self search];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 30;
    
    self.tableView.sectionHeaderHeight = 30;
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
}

- (IBAction)disconnectionClick:(id)sender {
    [self disConnection];
}

- (IBAction)searchClick:(id)sender {
    [self search];
}
#pragma mark - 搜索蓝牙
/**
 *	@brief	搜索蓝牙
 */
- (void)search {
    
    if ([_dcSwiper isConnectBlue]) {
        [self performSelector:@selector(operationalInformationDisplay:) withObject:@"设备已连接"];
        return;
    }
    [self performSelector:@selector(operationalInformationDisplay:) withObject:@"搜索设备"];
    [_deviceArray removeAllObjects];
    [_logArray removeAllObjects];
    [_tableView reloadData];
    [self.dcSwiper scanBlueDevice];
}
#pragma mark - 停止搜索
/**
 *	@brief	停止搜索
 */
- (void)stopSearch {
    
    if ([_dcSwiper isConnectBlue]) {
        [self.dcSwiper stopScanBlueDevice];
        [self performSelector:@selector(operationalInformationDisplay:) withObject:@"停止搜索"];
    } else {
        [self performSelector:@selector(operationalInformationDisplay:) withObject:@"蓝牙未连接"];
    }
}
/**
 *  扫描到蓝牙设备后的回调:每发现一个蓝牙设备回调一次,将新发现的设备返回
 */
//扫描设备结果
-(void)onFindBlueDevice:(CBPeripheral *)cbPeripheral{
    //显示
    NSLog(@"扫描到设备-->%@",cbPeripheral.name);
    if (![_deviceArray containsObject:cbPeripheral] ) {
        [_deviceArray addObject:cbPeripheral];
        [_tableView reloadData];
    }
}

/**
 *	@brief	断开
 */
- (void)disConnection {
    if ([_dcSwiper isConnectBlue]) {
        [self.dcSwiper disConnect];
    } else {
        [self performSelector:@selector(operationalInformationDisplay:) withObject:@"蓝牙未连接"];
    }
}

/*
 * 断开连接后的回调
 */
-(void)onDisconnectBlueDevice:(CBPeripheral *)cbPeripheral {
    NSLog(@"断开连接 -- >%@",cbPeripheral.name);
    [self performSelector:@selector(operationalInformationDisplay:) withObject:@"断开连接成功"];
    [self waringView:@"断开成功"];
}

/*
 * 连接后的回调
 */
-(void)onDidConnectBlueDevice:(CBPeripheral *)cbPeripheral {
    NSLog(@"连接成功");
    [self.dcSwiper stopScanBlueDevice];
    [self performSelector:@selector(operationalInformationDisplay:) withObject:[NSString stringWithFormat:@"连接成功 当前连接:%@",cbPeripheral.name]];
    [self waringView:@"连接成功"];
}

//展示操作信息
- (void)operationalInformationDisplay:(NSString *)text {
    NSDate * senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * locationString=[dateformatter stringFromDate:senddate];
    
    [_logArray addObject:[NSString stringWithFormat:@"%@\n%@",locationString,text]];
    [_tableView reloadData];
    
    //滚动至当前行
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_logArray.count - 1 inSection:1];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

/**
 *  @brief 0 发生错误的回调
 *
 *  @param errmsg 错误信息
 */
-(void)onResponse:(int)type :(int)status {
    NSLog(@"Type:%d Status:%d",type,status);
    [self performSelector:@selector(operationalInformationDisplay:) withObject:[NSString stringWithFormat:@"Type:%d Status:%d",type,status ]];
}


#pragma mark - UI部分

-(void)alertView:(NSString *)string{
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:string preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, screenWidth-10, 30)];
    label.backgroundColor = [UIColor colorWithRed:21/255.0 green:126/255.0 blue:251/255.0 alpha:1];
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(0, 0, tableView.frame.size.width, 30);
    button.tag = section;
    [view addSubview:button];
    if (section == 0) {
        label.text = @" 终端设备";
    }
    if (section == 1) {
        button.frame = CGRectMake(tableView.frame.size.width - 90, 0, 90, 30);
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        label.text = @" 日志打印";
        [button setTitle:@"清空日志" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return view;
}
- (void)buttonClick:(UIButton *)button {
    
    NSLog(@"清空日志");
    
    [_logArray removeAllObjects];
    [_tableView reloadData];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _deviceArray.count;
    } else {
        return _logArray.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 40.0;
    } else {
        return 60.0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ID"];
    }
    if (indexPath.section == 0) {
        CBPeripheral * peripheral = _deviceArray[indexPath.row];
        cell.textLabel.text = peripheral.name;
        cell.detailTextLabel.text = [peripheral.identifier UUIDString];
    } else {
        cell.textLabel.text = _logArray[indexPath.row];
        cell.detailTextLabel.text = @"";
    }
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        //连接设备
        [self performSelector:@selector(operationalInformationDisplay:) withObject:@"连接设备"];
        CBPeripheral * peripheral = _deviceArray[indexPath.row];
        [self.dcSwiper connectBlueDevice:peripheral];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)waringView:(NSString *)string {
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
