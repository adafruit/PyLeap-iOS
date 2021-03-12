//
//  NUSCBUUID.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/4/21.
//

import Foundation
import CoreBluetooth

struct NUSCBUUID{
//6E400001-B5A3-F393-E0A9-E50E24DCCA9E

//nrf 52 Service: 00001523-1212-EFDE-1523-785FEABCD123

    static let kBLEService_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    static let kBLE_Characteristic_uuid_Tx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    static let kBLE_Characteristic_uuid_Rx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    static let MaxCharacters = 20

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

}
