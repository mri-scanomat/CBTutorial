//
//  CBPeripheralViewController.m
//  CBTutorial
//
//  Created by Orlando Pereira on 10/8/13.
//  Copyright (c) 2013 Mobiletuts. All rights reserved.
//

#import "CBPeripheralViewController.h"

@interface CBPeripheralViewController (){
    NSUInteger maximumUpdateValueLength;
}

@end

@implementation CBPeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    maximumUpdateValueLength = 20;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
        
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        
        transferService.characteristics = @[_transferCharacteristic];
        
        [_peripheralManager addService:transferService];
        
        [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    if ([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]){
        NSData *data = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];

        NSData *chunk = [data subdataWithRange:NSMakeRange(request.offset, data.length-request.offset)];
        request.value = chunk;
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [peripheral respondToRequest:request withResult:CBATTErrorInvalidPdu];
    }
}

@end
