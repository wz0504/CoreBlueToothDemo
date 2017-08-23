//
//  ViewController.m
//  CoreBlueToothDemo1
//
//  Created by Apple on 2017/8/22.
//  Copyright © 2017年 Apple. All rights reserved.
//

/*
 1.建立中心设备
 2.扫描外设(Discover Peripheral)
 3.连接外设(Connect Peripheral)
 4.扫描外设中的服务和特征(Discover Services  And Characteristics)
 5.利用特征与外设做数据交互(Explore And Interact)
 6.断开连接(Disconnect)
 */
#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property(nonatomic,strong)CBCentralManager *manager;//中心管理者

@property(nonatomic,strong)NSMutableArray *peripheralArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.建立中心设备
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];//参数2传入nil　代表在主队列中
    
    
}

#pragma mark ---　CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    /*
     //未知
     CBCentralManagerStateUnknown = CBManagerStateUnknown=0,
     //重置
     CBCentralManagerStateResetting = CBManagerStateResetting,
     //不支持
     CBCentralManagerStateUnsupported = CBManagerStateUnsupported,
     //未授权
     CBCentralManagerStateUnauthorized = CBManagerStateUnauthorized,
     //未启动
     CBCentralManagerStatePoweredOff = CBManagerStatePoweredOff,
     //开启
     CBCentralManagerStatePoweredOn = CBManagerStatePoweredOn,
     */
    NSLog(@"state = %zd",central.state);
    // 如果开启状态
    if (central.state == CBManagerStatePoweredOn) {
        // 2.扫描外设(Discover Peripheral)
        [self.manager scanForPeripheralsWithServices:nil options:nil];//参数1传nil代表扫描所有的外设，传入指定的CBUUID,扫描特定的服务
    }
}

/*
 发现外设后会调用这个方法
 peripheral：外围设备
 advertisementData：相关数据
 RSSI：信号强度
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    //１.记录外设，防到数组中
    if (![self.peripheralArray containsObject:peripheral]) {
        [self.peripheralArray addObject:peripheral];
    }
    
    //２.隐藏功能，可以写一个列表　扫描的外设都展示的列表中
    
    //３. 连接外设
    [self.manager connectPeripheral:peripheral options:nil];
    
    //4 设置外设的代理，管理外设,管理服务和特征
    peripheral.delegate = self;
    
}

//连接成功后，会调用这个代理
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //扫描服务　参数传空代表扫描所有的服务
    [peripheral discoverServices:nil];
}
#pragma mark ---　CBPeripheralDelegate
//扫描到服务后，会走这个代理
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    //扫描到外设里面的服务
    for (CBService *services in peripheral.services) {
        //获取指定的服务
        if ([services.UUID.UUIDString isEqualToString:@"UUID"]) {
            //扫描特征  传nil扫描这个服务的所有特征
            [peripheral discoverCharacteristics:nil forService:services];
        }
    }
}

//扫描特征后，会走这个代理方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error  {
    
    //获取服务里面的指定特征
    for (CBCharacteristic * characteristics in service.characteristics) {
        //获取指定的特征
        if ([characteristics.UUID.UUIDString isEqualToString:@"UUID"]) {
            //读
            //[peripheral readValueForCharacteristic:<#(nonnull CBCharacteristic *)#>];
            //写
            //[peripheral writeValue:<#(nonnull NSData *)#> forCharacteristic:<#(nonnull CBCharacteristic *)#> type:<#(CBCharacteristicWriteType)#>];
        }
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.manager stopScan]; //停止连接
}
#pragma mark ---懒加载
-(NSMutableArray *)peripheralArray {
    if (!_peripheralArray) {
        _peripheralArray = [[NSMutableArray alloc] init];
    }
    return _peripheralArray;
}
@end
