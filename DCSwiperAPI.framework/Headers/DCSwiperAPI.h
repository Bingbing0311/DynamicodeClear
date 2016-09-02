//
//  DCSwiperAPI.h
//  DCSwiperAPI
//
//  Created by Bingo on 16/6/17.
//  Copyright © 2016年 Bingo. All rights reserved.
//  P27/P84通用

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define  ERROR_OK 0
#define  ERROR_FAIL_CONNECT_DEVICE 0x0001
#define  ERROR_FAIL_GET_KSN  0x0002
#define  ERROR_FAIL_READCARD 0x0003
#define  ERROR_FAIL_ENCRYPTPIN 0x0004
#define  ERROR_FAIL_GETMAC     0x0005
#define  ERROR_FAIL_TIMEOUT   0x0006
#define  ERROR_FAIL_MCCARD   0x0007
#define  ERROR_FAIL_DATA          0x0008
#define  ERROR_FAIL_NEEDIC      0x0009
#define  ERROR_FAIL_DATAEXIST 0x000a
#define  ERROR_FAIL_SWIPINGCARD 0x000b


typedef enum
{
    STATE_ACTIVE = 0,
    STATE_IDLE = 1,
    STATE_BUSY = 2,
    STATE_UNACTIVE = -1
}DeviceBlueState;

typedef enum
{
    card_mc = 1,        //磁条卡
    card_ic = 2,        //IC卡
    card_all = 3        //非接卡
}cardType;              //银行卡类型

@protocol DCSwiperAPIDelegate <NSObject>

@optional


/**
 *  扫描设备结果
 *
 *  @param dic 蓝牙信息
 */
-(void)onFindBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 *  连接设备结果
 *
 *  @param dic 蓝牙信息
 */
-(void)onDidConnectBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 *  失去连接到设备
 *
 *  @param dic 蓝牙信息
 */
-(void)onDisconnectBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 *  读取ksn结果
 *
 *  @param dic[@"6"]
 */
-(void)onDidGetDeviceKsn:(NSDictionary *)dic;

/**
 *  导入主密钥返回
 *
 *  @param isSuccess YES OR NO
 */
-(void)onDidLoadMainKey:(BOOL)isSuccess;

/**
 *  签到回调（更新工作秘钥）
 *
 *  @param isSuccess  YES 成功
 */
-(void)onDidUpdateKey:(BOOL)isSuccess;

/**
 *  识别到卡
 */
-(void)onDetectCard;

/**
 *  刷卡、插卡信息回调
 *
 *  @param dic 卡信息
 */
-(void)onDidReadCardInfo:(NSDictionary *)dic;

/**
 *  pin加密返回 p27
 *
 *  @param encPINblock 加密后的Pin
 */
-(void)onEncryptPinBlock:(NSString *)encPINblock;

/**
 *  获取POS输入密码的回调函数  p84
 *
 *  @param pinBlock
 */
-(void)onReturnPinBlock:(NSString *)pinBlock;

/**
 *  设备按取消键返回
 */
-(void)onPressCancleKey;

/**
 *   mac计算结果
 *
 *  @param strmac mac
 */
-(void)onDidGetMac:(NSString *)strmac;

/**
 *  错误返回
 *
 *  @param type
 *  @param status
 */
-(void)onResponse:(int)type :(int)status;

/**
 *  取消/复位回调
 */
-(void)onDidCancelCard;

@end

@interface DCSwiperAPI : NSObject
@property (nonatomic, weak)    id<DCSwiperAPIDelegate> delegate;//代理
@property (nonatomic, assign)  int intDeviceBlueState;//蓝牙状态
@property (nonatomic, assign)  BOOL isConnectBlue; //蓝牙是否连接
@property (nonatomic) cardType  currentCardType;


/**
 *  SDK初始化
 *
 *  @return SDK单例对象
 */
+(DCSwiperAPI *)shareInstance;

/**
 *  搜索蓝牙设备
 */
-(void)scanBlueDevice;

/**
 *  停止扫描蓝牙
 */
-(void)stopScanBlueDevice;

/**
 *  连接蓝牙
 *
 *  @param cbPeripheral 蓝牙外设
 */
-(void)connectBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 *  断开蓝牙设备
 */
-(void)disConnect;

/**
 *  获取ksn编号
 */
-(void)getDeviceKsn;

/**
 *  写入主密钥
 *
 *  @param mainKey
 */
-(void)loadMainKey:(NSString *)mainKey;

/**
 *   写入工作密钥
 *
 *  @param keyDic (密钥指：签到之后，后台下发的三组
 *  DESKey、（32位密钥 + 8位checkValue = 40位）
 *  PINKey、（32位密钥 + 8位checkValue = 40位）
 *  MACKey、（16位密钥 + 8位checkValue = 24位）
 */
-(void)updateKey:(NSDictionary *)keyDic;

/**
 *  (读磁条卡、IC卡需使用同一接口，app代码无需做刷卡类型区分。
 *  需返回数据：
 *  1. 磁卡：卡号（明）、track2（密）、track3（可选）等
 *  2.IC卡：卡号（明）、track2（密）、track3（可选）、IC卡标识、icdata（55)
 *
 *  @param type 消费类型
 *              1: 消费
 *              2: 查余
 *  @param dbmoney 金额
 */

-(void)readCard:(int)type  money:(double)dbmoney;

/**
 *  pin加密 P27专用
 *
 *  @param Pin
 */
-(void)encryptPin:(NSString *)Pin;

/**
 *  从POS获取输入密码 (必须先执行读取卡片的操作) P84专用
 */
-(void)getPinFromPOS;

/**
 *  计算mac
 *  @param data 
 */
-(void)getMacValue:(NSString *)data;

/**
 *  取消复位
 */
-(void)cancelCard;


@end
